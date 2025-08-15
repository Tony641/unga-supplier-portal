import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InvoiceStatusAnimationWidget extends StatefulWidget {
  const InvoiceStatusAnimationWidget({Key? key}) : super(key: key);

  @override
  State<InvoiceStatusAnimationWidget> createState() =>
      _InvoiceStatusAnimationWidgetState();
}

class _InvoiceStatusAnimationWidgetState
    extends State<InvoiceStatusAnimationWidget> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  int currentStep = 0;
  final List<String> steps = ['Submitted', 'Processing', 'Approved', 'Paid'];
  final List<String> stepIcons = [
    'upload',
    'hourglass_empty',
    'check_circle',
    'payment'
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() {
    _progressController.addListener(() {
      int newStep = (_progressAnimation.value * (steps.length - 1)).floor();
      if (newStep != currentStep && newStep < steps.length) {
        setState(() {
          currentStep = newStep;
        });
        _pulseController.forward().then((_) => _pulseController.reverse());
      }
    });

    _progressController.repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: 80.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Timeline
          Container(
            height: 25.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(steps.length, (index) {
                bool isActive = index <= currentStep;
                bool isCurrent = index == currentStep;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Step Circle
                    AnimatedBuilder(
                      animation: isCurrent
                          ? _pulseAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isCurrent ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.outline,
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: stepIcons[index],
                                color: isActive
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                size: 6.w,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Step Label
                    Text(
                      steps[index],
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: isActive
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }),
            ),
          ),

          SizedBox(height: 4.h),

          // Current Status Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Status: ${steps[currentStep]}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 