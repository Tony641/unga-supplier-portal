import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/batch_scanning_widget.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/image_preview_widget.dart';
import './widgets/ocr_processing_widget.dart';
import './widgets/scanner_settings_widget.dart';
import 'widgets/batch_scanning_widget.dart';
import 'widgets/camera_controls_widget.dart';
import 'widgets/camera_overlay_widget.dart';
import 'widgets/image_preview_widget.dart';
import 'widgets/ocr_processing_widget.dart';
import 'widgets/scanner_settings_widget.dart';

enum ScannerMode {
  single,
  batch,
}

enum ScannerState {
  camera,
  preview,
  processing,
  batchView,
  settings,
}

class DocumentScanner extends StatefulWidget {
  const DocumentScanner({super.key});

  @override
  State<DocumentScanner> createState() => _DocumentScannerState();
}

class _DocumentScannerState extends State<DocumentScanner>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Camera related
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isCapturing = false;

  // Scanner state
  ScannerState _currentState = ScannerState.camera;
  ScannerMode _scannerMode = ScannerMode.single;

  // Document detection
  bool _isDocumentDetected = false;
  int _detectionStableCount = 0;
  static const int _requiredStableFrames = 60; // 2 seconds at 30fps

  // Captured images
  List<String> _capturedImages = [];
  String? _currentImagePath;
  String? _extractedText;

  // Settings
  bool _showGrid = false;
  bool _autoCapture = false;
  String _imageQuality = 'High';

  // Animation controllers
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;

  // Mock data for extracted text examples
  final List<Map<String, dynamic>> _mockExtractedTexts = [
    {
      "documentType": "Invoice",
      "text":
          """UNGA HOLDINGS LIMITED Invoice No: INV-2024-001234 Date: 15/08/2024 Supplier: Maize Farmers Cooperative Amount: KES 125,000.00 Description: Premium maize grain supply Payment Terms: Net 30 days""",
    },
    {
      "documentType": "Receipt",
      "text":
          """PAYMENT RECEIPT Receipt No: RCP-2024-005678 Date: 15/08/2024 From: Agricultural Supplies Ltd Amount Paid: KES 75,500.00 Payment Method: Bank Transfer Reference: TXN789456123""",
    },
    {
      "documentType": "Purchase Order",
      "text":
          """PURCHASE ORDER PO Number: PO-2024-009876 Date: 15/08/2024 Vendor: Farm Equipment Suppliers Total Value: KES 250,000.00 Delivery Date: 22/08/2024 Items: Harvesting equipment rental""",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _countdownController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _countdownAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _countdownController,
      curve: Curves.linear,
    ));

    _initializeCamera();
    _startDocumentDetectionSimulation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        _showPermissionDeniedDialog();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showNoCameraDialog();
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      _showCameraErrorDialog();
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);

      if (!kIsWeb) {
        await _cameraController!
            .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      }
    } catch (e) {
      debugPrint('Settings application error: $e');
    }
  }

  void _startDocumentDetectionSimulation() {
    // Simulate document detection for demo purposes
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _currentState == ScannerState.camera) {
        setState(() {
          _isDocumentDetected = true;
        });

        if (_autoCapture) {
          _startCountdown();
        }
      }
    });
  }

  void _startCountdown() {
    _countdownController.forward().then((_) {
      if (mounted && _autoCapture && _isDocumentDetected) {
        _capturePhoto();
      }
      _countdownController.reset();
    });
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      HapticFeedback.heavyImpact();

      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _currentImagePath = photo.path;
        _currentState = ScannerState.preview;
        _isCapturing = false;
      });
    } catch (e) {
      debugPrint('Photo capture error: $e');
      setState(() {
        _isCapturing = false;
      });
      _showErrorSnackBar('Failed to capture photo. Please try again.');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: _getImageQuality(),
      );

      if (image != null) {
        setState(() {
          _currentImagePath = image.path;
          _currentState = ScannerState.preview;
        });
      }
    } catch (e) {
      debugPrint('Gallery selection error: $e');
      _showErrorSnackBar('Failed to select image from gallery.');
    }
  }

  int _getImageQuality() {
    switch (_imageQuality) {
      case 'Low':
        return 25;
      case 'Medium':
        return 50;
      case 'High':
        return 75;
      case 'Ultra':
        return 100;
      default:
        return 75;
    }
  }

  void _processImage() {
    setState(() {
      _currentState = ScannerState.processing;
    });

    // Simulate OCR processing
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        final randomText = _mockExtractedTexts[
            DateTime.now().millisecond % _mockExtractedTexts.length];

        setState(() {
          _extractedText = randomText['text'] as String;
          _currentState = ScannerState.processing;
        });
      }
    });
  }

  void _retakePhoto() {
    setState(() {
      _currentImagePath = null;
      _currentState = ScannerState.camera;
      _isDocumentDetected = false;
    });

    // Restart document detection simulation
    _startDocumentDetectionSimulation();
  }

  void _usePhoto() {
    if (_currentImagePath != null) {
      if (_scannerMode == ScannerMode.batch) {
        _capturedImages.add(_currentImagePath!);
        setState(() {
          _currentState = ScannerState.batchView;
        });
      } else {
        _processImage();
      }
    }
  }

  void _toggleFlash() {
    if (kIsWeb) return; // Flash not supported on web

    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _applySettings();
  }

  void _showSettings() {
    setState(() {
      _currentState = ScannerState.settings;
    });
  }

  void _closeSettings() {
    setState(() {
      _currentState = ScannerState.camera;
    });
  }

  void _switchToBatchMode() {
    setState(() {
      _scannerMode = ScannerMode.batch;
      _currentState = ScannerState.batchView;
    });
  }

  void _addAnotherDocument() {
    setState(() {
      _currentState = ScannerState.camera;
      _isDocumentDetected = false;
    });
    _startDocumentDetectionSimulation();
  }

  void _completeBatchScanning() {
    // Process all captured images
    _showSuccessDialog(
        'Batch scanning completed! ${_capturedImages.length} documents processed.');
  }

  void _removeImageFromBatch(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  void _previewBatchImage(int index) {
    setState(() {
      _currentImagePath = _capturedImages[index];
      _currentState = ScannerState.preview;
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Camera Permission Required'),
          content: Text(
              'Please grant camera permission to use the document scanner.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showNoCameraDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Camera Available'),
          content: Text('No camera was found on this device.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showCameraErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Camera Error'),
          content: Text('Failed to initialize camera. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initializeCamera();
              },
              child: Text('Retry'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text('Success'),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case ScannerState.camera:
        return _buildCameraView();
      case ScannerState.preview:
        return _buildPreviewView();
      case ScannerState.processing:
        return _buildProcessingView();
      case ScannerState.batchView:
        return _buildBatchView();
      case ScannerState.settings:
        return _buildSettingsView();
    }
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return _buildLoadingView();
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // Camera overlay
        CameraOverlayWidget(
          isDocumentDetected: _isDocumentDetected,
          showGrid: _showGrid,
          onCancel: () => Navigator.pop(context),
          onSettings: _showSettings,
        ),

        // Countdown overlay
        if (_autoCapture && _isDocumentDetected) _buildCountdownOverlay(),

        // Camera controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CameraControlsWidget(
            onCapture: _capturePhoto,
            onFlashToggle: _toggleFlash,
            onGallery: _selectFromGallery,
            isFlashOn: _isFlashOn,
            isCapturing: _isCapturing,
            capturedCount: _capturedImages.length,
          ),
        ),

        // Batch mode toggle
        if (_scannerMode == ScannerMode.single)
          Positioned(
            top: 15.h,
            right: 4.w,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton.icon(
                  onPressed: _switchToBatchMode,
                  icon: CustomIconWidget(
                    iconName: 'collections',
                    color: Colors.white,
                    size: 4.w,
                  ),
                  label: Text(
                    'Batch',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCountdownOverlay() {
    return AnimatedBuilder(
      animation: _countdownAnimation,
      builder: (context, child) {
        final countdown = (_countdownAnimation.value * 2).ceil();
        if (countdown <= 0) return SizedBox.shrink();

        return Center(
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                countdown.toString(),
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewView() {
    if (_currentImagePath == null) {
      return _buildErrorView('No image to preview');
    }

    return ImagePreviewWidget(
      imagePath: _currentImagePath!,
      onRetake: _retakePhoto,
      onUsePhoto: _usePhoto,
      onCancel: () => Navigator.pop(context),
    );
  }

  Widget _buildProcessingView() {
    return OcrProcessingWidget(
      extractedText: _extractedText,
      isProcessing: _extractedText == null,
      onContinue: () {
        _showSuccessDialog('Document processed successfully!');
      },
      onCancel: () => Navigator.pop(context),
      onTextChanged: (text) {
        setState(() {
          _extractedText = text;
        });
      },
    );
  }

  Widget _buildBatchView() {
    return BatchScanningWidget(
      capturedImages: _capturedImages,
      onAddAnother: _addAnotherDocument,
      onComplete: _completeBatchScanning,
      onRemoveImage: _removeImageFromBatch,
      onPreviewImage: _previewBatchImage,
    );
  }

  Widget _buildSettingsView() {
    return Stack(
      children: [
        // Camera preview background
        if (_isCameraInitialized && _cameraController != null)
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

        // Settings overlay
        ScannerSettingsWidget(
          showGrid: _showGrid,
          autoCapture: _autoCapture,
          flashEnabled: _isFlashOn,
          imageQuality: _imageQuality,
          onGridToggle: (value) {
            setState(() {
              _showGrid = value;
            });
          },
          onAutoCaptureToggle: (value) {
            setState(() {
              _autoCapture = value;
            });
          },
          onFlashToggle: (value) {
            setState(() {
              _isFlashOn = value;
            });
            _applySettings();
          },
          onQualityChanged: (value) {
            setState(() {
              _imageQuality = value;
            });
          },
          onClose: _closeSettings,
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Initializing camera...',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 15.w,
          ),
          SizedBox(height: 3.h),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }
}