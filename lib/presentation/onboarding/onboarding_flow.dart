import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import './widgets/biometric_animation_widget.dart';
import './widgets/document_scanner_animation_widget.dart';
import './widgets/invoice_status_animation_widget.dart';
import './widgets/offline_sync_animation_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 5;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Welcome to Unga Supplier Portal",
      "description":
          "Streamline your invoice management with our mobile-first platform integrated with SAP systems.",
      "imageUrl":
          "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "hasAnimation": false,
    },
    {
      "title": "Smart Document Scanning",
      "description":
          "Capture invoices instantly with AI-powered document detection and OCR text extraction.",
      "imageUrl": "",
      "hasAnimation": true,
      "animationType": "scanner",
    },
    {
      "title": "Real-time Invoice Tracking",
      "description":
          "Monitor your invoice status from submission to payment with live updates and notifications.",
      "imageUrl": "",
      "hasAnimation": true,
      "animationType": "status",
    },
    {
      "title": "Secure Biometric Access",
      "description":
          "Protect your business data with Touch ID, Face ID, and enterprise-grade security.",
      "imageUrl": "",
      "hasAnimation": true,
      "animationType": "biometric",
    },
    {
      "title": "Work Anywhere, Anytime",
      "description":
          "Continue working offline with automatic sync when connection is restored.",
      "imageUrl": "",
      "hasAnimation": true,
      "animationType": "offline",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Haptic feedback for page changes
    HapticFeedback.lightImpact();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.selectionClick();
    } else {
      _getStarted();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.selectionClick();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    _getStarted();
  }

  void _getStarted() async {
    // Mark onboarding as completed
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    // Navigate to login screen
    Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
  }

  Widget _buildAnimationWidget(String animationType) {
    switch (animationType) {
      case 'scanner':
        return const DocumentScannerAnimationWidget();
      case 'status':
        return const InvoiceStatusAnimationWidget();
      case 'biometric':
        return const BiometricAnimationWidget();
      case 'offline':
        return const OfflineSyncAnimationWidget();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Skip Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo or Brand
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'business',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 5.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Unga',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Skip Button
                  _currentPage < _totalPages - 1
                      ? TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            'Skip',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];

                  return OnboardingPageWidget(
                    title: data["title"] as String,
                    description: data["description"] as String,
                    imageUrl: data["imageUrl"] as String,
                    animationWidget: (data["hasAnimation"] as bool? ?? false)
                        ? _buildAnimationWidget(
                            data["animationType"] as String? ?? "")
                        : null,
                  );
                },
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Column(
                children: [
                  // Page Indicator
                  PageIndicatorWidget(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                  ),

                  SizedBox(height: 4.h),

                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      _currentPage > 0
                          ? OutlinedButton(
                              onPressed: _previousPage,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'arrow_back',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Back',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(width: 100),

                      // Next/Get Started Button
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _totalPages - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            CustomIconWidget(
                              iconName: _currentPage == _totalPages - 1
                                  ? 'rocket_launch'
                                  : 'arrow_forward',
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              size: 5.w,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}