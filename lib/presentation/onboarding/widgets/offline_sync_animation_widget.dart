import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OfflineSyncAnimationWidget extends StatefulWidget {
  const OfflineSyncAnimationWidget({Key? key}) : super(key: key);

  @override
  State<OfflineSyncAnimationWidget> createState() =>
      _OfflineSyncAnimationWidgetState();
}

class _OfflineSyncAnimationWidgetState extends State<OfflineSyncAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _syncController;
  late AnimationController _cloudController;
  late Animation<double> _syncAnimation;
  late Animation<double> _cloudAnimation;

  bool isOnline = true;

  @override
  void initState() {
    super.initState();

    _syncController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _cloudController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _syncAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _syncController,
      curve: Curves.easeInOut,
    ));

    _cloudAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _cloudController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() {
    _syncController.repeat();
    _cloudController.repeat(reverse: true);

    // Toggle online/offline state every 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          isOnline = !isOnline;
        });
        _startAnimation();
      }
    });
  }

  @override
  void dispose() {
    _syncController.dispose();
    _cloudController.dispose();
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
          // Cloud
          AnimatedBuilder(
            animation: _cloudAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_cloudAnimation.value, 0),
                child: Container(
                  width: 25.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -3.w,
                        left: 5.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -2.w,
                        right: 6.w,
                        child: Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: CustomIconWidget(
                          iconName: isOnline ? 'cloud_done' : 'cloud_off',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 8.w,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Sync Arrows
          Positioned(
            bottom: 15.h,
            child: AnimatedBuilder(
              animation: _syncAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    // Upload Arrow
                    Transform.translate(
                      offset: Offset(0, -_syncAnimation.value * 5.h),
                      child: Opacity(
                        opacity: 1 - _syncAnimation.value,
                        child: CustomIconWidget(
                          iconName: 'arrow_upward',
                          color: isOnline
                              ? AppTheme.successLight
                              : AppTheme.warningLight,
                          size: 8.w,
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Download Arrow
                    Transform.translate(
                      offset: Offset(0, _syncAnimation.value * 5.h),
                      child: Opacity(
                        opacity: 1 - _syncAnimation.value,
                        child: CustomIconWidget(
                          iconName: 'arrow_downward',
                          color: isOnline
                              ? AppTheme.successLight
                              : AppTheme.warningLight,
                          size: 8.w,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Device
          Positioned(
            bottom: 5.h,
            child: Container(
              width: 20.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'phone_android',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    width: 3.w,
                    height: 0.5.w,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? AppTheme.successLight
                          : AppTheme.warningLight,
                      borderRadius: BorderRadius.circular(0.25.w),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status Badge
          Positioned(
            top: 5.h,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppTheme.successLight.withValues(alpha: 0.1)
                    : AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color:
                      isOnline ? AppTheme.successLight : AppTheme.warningLight,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: isOnline ? 'wifi' : 'wifi_off',
                    color: isOnline
                        ? AppTheme.successLight
                        : AppTheme.warningLight,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    isOnline ? 'Online Sync' : 'Offline Mode',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isOnline
                          ? AppTheme.successLight
                          : AppTheme.warningLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}