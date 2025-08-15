import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DocumentScannerAnimationWidget extends StatefulWidget {
  const DocumentScannerAnimationWidget({Key? key}) : super(key: key);

  @override
  State<DocumentScannerAnimationWidget> createState() =>
      _DocumentScannerAnimationWidgetState();
}

class _DocumentScannerAnimationWidgetState
    extends State<DocumentScannerAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scanLineController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: 80.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Document background
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 60.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4.w),
                    border: Border.all(
                      color: AppTheme.successLight,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successLight.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 3.h),
                      Container(
                        width: 45.w,
                        height: 1.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          borderRadius: BorderRadius.circular(0.5.h),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 40.w,
                        height: 1.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          borderRadius: BorderRadius.circular(0.5.h),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 35.w,
                        height: 1.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          borderRadius: BorderRadius.circular(0.5.h),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scanning line
          AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, child) {
              return Positioned(
                top: 5.h + (_scanLineAnimation.value * 20.h),
                child: Container(
                  width: 60.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successLight.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Camera icon
          Positioned(
            top: 2.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 