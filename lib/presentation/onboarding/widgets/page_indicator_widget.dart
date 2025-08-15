import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicatorWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          height: 1.h,
          width: currentPage == index ? 8.w : 2.w,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
            borderRadius: BorderRadius.circular(0.5.h),
          ),
        ),
      ),
    );
  }
} 