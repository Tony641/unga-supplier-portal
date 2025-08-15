import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Splash Logo Widget displays the Unga logo with tagline in a branded format
/// optimized for the splash screen experience.
class SplashLogoWidget extends StatelessWidget {
  const SplashLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Unga logo
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: SvgPicture.asset(
              'assets/images/img_app_logo.svg',
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFF7F00),
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
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),

        SizedBox(height: 0.5.h),

        // Tagline
        Text(
          'Supplier Portal',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
} 