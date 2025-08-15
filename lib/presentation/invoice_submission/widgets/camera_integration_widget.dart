import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraIntegrationWidget extends StatefulWidget {
  final Function(List<XFile>) onImagesSelected;
  final List<XFile> initialImages;

  const CameraIntegrationWidget({
    super.key,
    required this.onImagesSelected,
    required this.initialImages,
  });

  @override
  State<CameraIntegrationWidget> createState() =>
      _CameraIntegrationWidgetState();
}

class _CameraIntegrationWidgetState extends State<CameraIntegrationWidget> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedImages = List.from(widget.initialImages);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Request camera permission
      if (!await _requestCameraPermission()) {
        setState(() {
          _errorMessage = 'Camera permission is required to capture documents';
          _isInitializing = false;
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device';
          _isInitializing = false;
        });
        return;
      }

      // Select appropriate camera
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Apply camera settings (skip unsupported features on web)
      await _applyCameraSettings();

      setState(() {
        _isCameraInitialized = true;
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        _isInitializing = false;
      });
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true; // Browser handles permissions

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applyCameraSettings() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);

      // Skip flash settings on web as they're not supported
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Flash not supported, continue without it
        }
      }
    } catch (e) {
      // Settings not supported, continue without them
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _selectedImages.add(photo);
      });
      widget.onImagesSelected(_selectedImages);

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document captured successfully'),
            backgroundColor: AppTheme.getSuccessColor(
                Theme.of(context).brightness == Brightness.light),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
        widget.onImagesSelected(_selectedImages);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }

  void _showCameraBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCameraBottomSheet(),
    );
  }

  Widget _buildCameraBottomSheet() {
    final theme = Theme.of(context);

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Capture Document',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Camera preview
          Expanded(
            child: _buildCameraPreview(theme),
          ),

          // Controls
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  theme,
                  'photo_library',
                  'Gallery',
                  _pickFromGallery,
                ),
                _buildCaptureButton(theme),
                _buildControlButton(
                  theme,
                  'flip_camera_ios',
                  'Flip',
                  _flipCamera,
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(ThemeData theme) {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Initializing camera...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: theme.colorScheme.error,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Text(
          'Camera not available',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          CameraPreview(_cameraController!),

          // Document detection overlay
          CustomPaint(
            painter: DocumentOverlayPainter(theme.colorScheme.primary),
            size: Size.infinite,
          ),

          // Instructions
          Positioned(
            top: 2.h,
            left: 4.w,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Position document within the frame',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      ThemeData theme, String iconName, String label, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: theme.dividerColor),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: CustomIconWidget(
              iconName: iconName,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCaptureButton(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: IconButton(
            onPressed: _capturePhoto,
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Capture',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;

    final currentCamera = _cameraController?.description;
    final newCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection != currentCamera?.lensDirection,
      orElse: () => _cameras.first,
    );

    await _cameraController?.dispose();
    _cameraController = CameraController(
      newCamera,
      kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _applyCameraSettings();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),

        // Camera integration button
        GestureDetector(
          onTap: _showCameraBottomSheet,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'camera_alt',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capture or Select Documents',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Take photos or select from gallery',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_forward_ios',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),

        // Selected images preview
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            'Selected Documents (${_selectedImages.length})',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 25.w,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 2.w),
                  child: Stack(
                    children: [
                      Container(
                        width: 25.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImages[index].path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: theme.colorScheme.surface,
                                      child: CustomIconWidget(
                                        iconName: 'image',
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                        size: 32,
                                      ),
                                    );
                                  },
                                )
                              : Image.network(
                                  _selectedImages[index].path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: theme.colorScheme.surface,
                                      child: CustomIconWidget(
                                        iconName: 'image',
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      Positioned(
                        top: 1.w,
                        right: 1.w,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

// Custom painter for document detection overlay
class DocumentOverlayPainter extends CustomPainter {
  final Color color;

  DocumentOverlayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    // Draw corner brackets
    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
