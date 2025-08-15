import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricAnimationWidget extends StatefulWidget {
  const BiometricAnimationWidget({Key? key}) : super(key: key);

  @override
  State<BiometricAnimationWidget> createState() =>
      _BiometricAnimationWidgetState();
}

class _BiometricAnimationWidgetState extends State<BiometricAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _rotationController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _rippleController.repeat();
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _rotationController.dispose();
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
          // Ripple Effect
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Container(
                width: 40.w * (1 + _rippleAnimation.value),
                height: 40.w * (1 + _rippleAnimation.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 1 - _rippleAnimation.value,
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),

          // Outer Ring
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 1.w,
                        left: 50.w / 2 - 1.w,
                        child: Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Center Fingerprint Icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'fingerprint',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 10.w,
              ),
            ),
          ),

          // Security Icons
          Positioned(
            top: 8.h,
            left: 15.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.successLight,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'security',
                color: Colors.white,
                size: 4.w,
              ),
            ),
          ),

          Positioned(
            top: 8.h,
            right: 15.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'lock',
                color: Colors.white,
                size: 4.w,
              ),
            ),
          ),

          Positioned(
            bottom: 8.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              child: Text(
                'Touch ID / Face ID',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 