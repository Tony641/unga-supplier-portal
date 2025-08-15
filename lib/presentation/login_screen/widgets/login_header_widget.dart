import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Login Header Widget displays the Unga logo and tagline at the top of the login screen
class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo container
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryLight.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: SvgPicture.asset(
              'assets/images/img_app_logo.svg',
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                AppTheme.primaryLight,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App title
        Text(
          'UNGA',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryLight,
            letterSpacing: 1.5,
          ),
        ),

        SizedBox(height: 0.5.h),

        // Tagline
        Text(
          'Supplier Portal',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}