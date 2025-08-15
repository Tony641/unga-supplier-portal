import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_integration_widget.dart';
import './widgets/invoice_form_widget.dart';
import './widgets/line_items_widget.dart';
import './widgets/progress_indicator_widget.dart';

class InvoiceSubmission extends StatefulWidget {
  const InvoiceSubmission({super.key});

  @override
  State<InvoiceSubmission> createState() => _InvoiceSubmissionState();
}

class _InvoiceSubmissionState extends State<InvoiceSubmission>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  int _currentStep = 1;
  final int _totalSteps = 4;
  bool _isFormValid = false;
  bool _isLoading = false;
  bool _isDraftSaving = false;
  bool _isLightTheme = true; // Store theme brightness

  // Form data
  Map<String, dynamic> _invoiceData = {};
  List<Map<String, dynamic>> _lineItems = [];
  List<XFile> _selectedImages = [];

  // Auto-save timer
  DateTime _lastSaveTime = DateTime.now();

  final List<String> _stepLabels = [
    'Invoice Details',
    'Add Documents',
    'Review & Submit',
    'Confirmation'
  ];

  // Mock data for form initialization
  final Map<String, dynamic> _mockInvoiceData = {
    'invoiceNumber': '',
    'invoiceDate': null,
    'dueDate': null,
    'amount': '',
    'description': '',
    'isValid': false,
  };

  @override
  void initState() {
    super.initState();
    _invoiceData = Map.from(_mockInvoiceData);
    _startAutoSave();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store theme brightness when dependencies change
    _isLightTheme = Theme.of(context).brightness == Brightness.light;
  }

  void _startAutoSave() {
    // Auto-save every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _saveDraft();
        _startAutoSave();
      }
    });
  }

  Future<void> _saveDraft() async {
    if (_isDraftSaving) return;

    setState(() {
      _isDraftSaving = true;
    });

    // Simulate draft saving
    await Future.delayed(const Duration(milliseconds: 500));

    _lastSaveTime = DateTime.now();

    if (mounted) {
      setState(() {
        _isDraftSaving = false;
      });

      // Show toast notification
      Fluttertoast.showToast(
        msg: "Draft Saved",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.getSuccessColor(_isLightTheme),
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  void _onFormChanged(Map<String, dynamic> formData) {
    setState(() {
      _invoiceData = formData;
      _isFormValid = formData['isValid'] ?? false;
    });
  }

  void _onLineItemsChanged(List<Map<String, dynamic>> lineItems) {
    setState(() {
      _lineItems = lineItems;
    });
  }

  void _onImagesSelected(List<XFile> images) {
    setState(() {
      _selectedImages = images;
    });
  }

  Future<void> _nextStep() async {
    if (_currentStep < _totalSteps) {
      // Add haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _isLoading = true;
      });

      // Simulate validation/processing
      await Future.delayed(const Duration(milliseconds: 800));

      if (_currentStep == 1 && !_isFormValid) {
        _showValidationError();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _currentStep++;
        _isLoading = false;
      });

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill in all required fields correctly'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentStep > 1) {
      _previousStep();
      return false;
    }

    // Show confirmation dialog for unsaved changes
    if (_hasUnsavedChanges()) {
      return await _showExitConfirmationDialog() ?? false;
    }

    return true;
  }

  bool _hasUnsavedChanges() {
    return _invoiceData['invoiceNumber']?.isNotEmpty == true ||
        _invoiceData['description']?.isNotEmpty == true ||
        _selectedImages.isNotEmpty;
  }

  Future<bool?> _showExitConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Unsaved Changes',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'You have unsaved changes. Do you want to save as draft before leaving?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Discard',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _saveDraft();
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text('Save Draft'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme),
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              ProgressIndicatorWidget(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                stepLabels: _stepLabels,
              ),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(theme),
                    _buildStep2(theme),
                    _buildStep3(theme),
                    _buildStep4(theme),
                  ],
                ),
              ),

              // Bottom navigation
              _buildBottomNavigation(theme),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        'Invoice Submission',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        onPressed: () async {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        },
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      actions: [
        if (_isDraftSaving)
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Center(
              child: SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          )
        else
          TextButton(
            onPressed: _saveDraft,
            child: Text(
              'Save Draft',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      systemOverlayStyle: theme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Fill in the basic invoice information. All fields marked with * are required.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),

          InvoiceFormWidget(
            onFormChanged: _onFormChanged,
            initialData: _invoiceData,
          ),

          SizedBox(height: 3.h),

          LineItemsWidget(
            onLineItemsChanged: _onLineItemsChanged,
            initialLineItems: _lineItems,
          ),

          SizedBox(height: 10.h), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Documents',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Capture or select supporting documents for your invoice. You can add multiple documents.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),

          CameraIntegrationWidget(
            onImagesSelected: _onImagesSelected,
            initialImages: _selectedImages,
          ),

          SizedBox(height: 10.h), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildStep3(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Please review all information before submitting your invoice.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),

          _buildReviewSection(theme),

          SizedBox(height: 10.h), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildStep4(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.getSuccessColor(
                    theme.brightness == Brightness.light),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: Colors.white,
                size: 48,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Invoice Submitted Successfully!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getSuccessColor(
                    theme.brightness == Brightness.light),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Your invoice has been submitted and is now being processed. You will receive notifications about status updates.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/invoice-status-tracking',
                      (route) => false,
                    ),
                    child: Text('Track Invoice Status'),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard',
                      (route) => false,
                    ),
                    child: Text('Back to Dashboard'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Invoice details card
        Card(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildReviewItem(theme, 'Invoice Number',
                    _invoiceData['invoiceNumber'] ?? 'Not provided'),
                _buildReviewItem(theme, 'Invoice Date',
                    _formatDate(_invoiceData['invoiceDate'])),
                _buildReviewItem(
                    theme, 'Due Date', _formatDate(_invoiceData['dueDate'])),
                _buildReviewItem(
                    theme, 'Amount', _invoiceData['amount'] ?? 'Not provided'),
                _buildReviewItem(theme, 'Description',
                    _invoiceData['description'] ?? 'Not provided'),
              ],
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Line items card (if any)
        if (_lineItems.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Line Items (${_lineItems.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ..._lineItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Item ${index + 1}: ${item['description'] ?? 'No description'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Qty: ${item['quantity'] ?? '0'} × KES ${item['unitPrice'] ?? '0.00'} = KES ${(item['total'] ?? 0.0).toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],

        // Documents card
        Card(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documents (${_selectedImages.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                if (_selectedImages.isEmpty)
                  Text(
                    'No documents attached',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  )
                else
                  SizedBox(
                    height: 20.w,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: 2.w),
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomIconWidget(
                              iconName: 'image',
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    if (_currentStep == _totalSteps) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 1) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: Text('Previous'),
                ),
              ),
              SizedBox(width: 4.w),
            ],
            Expanded(
              flex: _currentStep > 1 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                child: _isLoading
                    ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_getNextButtonText()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 1:
        return 'Next: Add Documents';
      case 2:
        return 'Next: Review';
      case 3:
        return 'Submit Invoice';
      default:
        return 'Next';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not selected';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
