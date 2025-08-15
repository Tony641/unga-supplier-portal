import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onGallery;
  final bool isFlashOn;
  final bool isCapturing;
  final int capturedCount;

  const CameraControlsWidget({
    super.key,
    this.onCapture,
    this.onFlashToggle,
    this.onGallery,
    this.isFlashOn = false,
    this.isCapturing = false,
    this.capturedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGalleryButton(context),
            _buildCaptureButton(context),
            _buildFlashButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onGallery?.call();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                child: CustomIconWidget(
                  iconName: 'photo_library',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
            ),
          ),
        ),
        if (capturedCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                minWidth: 5.w,
                minHeight: 5.w,
              ),
              child: Text(
                capturedCount.toString(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCaptureButton(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing
          ? null
          : () {
              HapticFeedback.heavyImpact();
              onCapture?.call();
            },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCapturing
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: isCapturing
            ? Container(
                padding: EdgeInsets.all(4.w),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              )
            : Container(
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: Colors.white,
                  size: 8.w,
                ),
              ),
      ),
    );
  }

  Widget _buildFlashButton(BuildContext context) {
    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        color: isFlashOn
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8)
            : Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFlashOn
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onFlashToggle?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            child: CustomIconWidget(
              iconName: isFlashOn ? 'flash_on' : 'flash_off',
              color: Colors.white,
              size: 6.w,
            ),
          ),
        ),
      ),
    );
  }
}