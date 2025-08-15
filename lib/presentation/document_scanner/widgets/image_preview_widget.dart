import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ImagePreviewWidget extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onRetake;
  final VoidCallback? onUsePhoto;
  final VoidCallback? onCancel;

  const ImagePreviewWidget({
    super.key,
    required this.imagePath,
    this.onRetake,
    this.onUsePhoto,
    this.onCancel,
  });

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  final TransformationController _transformationController =
      TransformationController();
  bool _showCropHandles = true;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildImagePreview(context),
          _buildTopControls(context),
          _buildBottomControls(context),
          if (_showCropHandles) _buildCropHandles(context),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 3.0,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 90.w,
            maxHeight: 80.h,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'error_outline',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 12.w,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildControlButton(
              context: context,
              icon: 'close',
              onTap: widget.onCancel,
              tooltip: 'Cancel',
            ),
            _buildControlButton(
              context: context,
              icon: _showCropHandles ? 'crop_free' : 'crop',
              onTap: () {
                setState(() {
                  _showCropHandles = !_showCropHandles;
                });
                HapticFeedback.lightImpact();
              },
              tooltip: _showCropHandles ? 'Hide Crop' : 'Show Crop',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context: context,
                label: 'Retake',
                icon: 'camera_alt',
                onTap: widget.onRetake,
                isPrimary: false,
              ),
              _buildActionButton(
                context: context,
                label: 'Use Photo',
                icon: 'check',
                onTap: widget.onUsePhoto,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required String icon,
    VoidCallback? onTap,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 6.w,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required String icon,
    VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          icon: CustomIconWidget(
            iconName: icon,
            color: isPrimary
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
          label: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isPrimary
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.transparent,
            foregroundColor: isPrimary
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.primary,
            side: isPrimary
                ? null
                : BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2,
                  ),
            padding: EdgeInsets.symmetric(vertical: 3.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCropHandles(BuildContext context) {
    return Positioned.fill(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        child: Stack(
          children: [
            // Corner handles
            _buildCornerHandle(Alignment.topLeft),
            _buildCornerHandle(Alignment.topRight),
            _buildCornerHandle(Alignment.bottomLeft),
            _buildCornerHandle(Alignment.bottomRight),

            // Edge handles
            _buildEdgeHandle(Alignment.topCenter),
            _buildEdgeHandle(Alignment.bottomCenter),
            _buildEdgeHandle(Alignment.centerLeft),
            _buildEdgeHandle(Alignment.centerRight),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerHandle(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEdgeHandle(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: alignment == Alignment.centerLeft ||
                alignment == Alignment.centerRight
            ? 4.w
            : 8.w,
        height: alignment == Alignment.topCenter ||
                alignment == Alignment.bottomCenter
            ? 4.w
            : 8.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}