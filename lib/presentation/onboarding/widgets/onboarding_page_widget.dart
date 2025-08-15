import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final Widget? animationWidget;

  const OnboardingPageWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.animationWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image or Animation Section
            Container(
              height: 40.h,
              width: 80.w,
              child: animationWidget ??
                  CustomImageWidget(
                    imageUrl: imageUrl,
                    width: 80.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
            ),

            SizedBox(height: 6.h),

            // Title
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 