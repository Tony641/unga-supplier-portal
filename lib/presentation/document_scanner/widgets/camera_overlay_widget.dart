import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class CameraOverlayWidget extends StatelessWidget {
  final bool isDocumentDetected;
  final VoidCallback? onCancel;
  final VoidCallback? onSettings;
  final bool showGrid;

  const CameraOverlayWidget({
    super.key,
    required this.isDocumentDetected,
    this.onCancel,
    this.onSettings,
    this.showGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Document detection overlay
        _buildDocumentDetectionOverlay(context),

        // Grid lines overlay
        if (showGrid) _buildGridOverlay(context),

        // Top controls
        _buildTopControls(context),

        // Document detection indicator
        _buildDetectionIndicator(context),
      ],
    );
  }

  Widget _buildDocumentDetectionOverlay(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: DocumentDetectionPainter(
          isDetected: isDocumentDetected,
          color: isDocumentDetected
              ? AppTheme.lightTheme.colorScheme.tertiary
              : AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildGridOverlay(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: GridPainter(
          color: Colors.white.withValues(alpha: 0.3),
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
              onTap: onCancel,
              tooltip: 'Cancel',
            ),
            _buildControlButton(
              context: context,
              icon: 'settings',
              onTap: onSettings,
              tooltip: 'Settings',
            ),
          ],
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

  Widget _buildDetectionIndicator(BuildContext context) {
    if (!isDocumentDetected) return SizedBox.shrink();

    return Positioned(
      top: 15.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Document Detected',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentDetectionPainter extends CustomPainter {
  final bool isDetected;
  final Color color;

  DocumentDetectionPainter({
    required this.isDetected,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Calculate document detection rectangle
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    // Draw corner brackets
    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );

    // Draw dashed border if document detected
    if (isDetected) {
      final dashedPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      _drawDashedRect(canvas, rect, dashedPaint);
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;

    // Top edge
    double startX = rect.left;
    while (startX < rect.right) {
      canvas.drawLine(
        Offset(startX, rect.top),
        Offset((startX + dashWidth).clamp(rect.left, rect.right), rect.top),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Right edge
    double startY = rect.top;
    while (startY < rect.bottom) {
      canvas.drawLine(
        Offset(rect.right, startY),
        Offset(rect.right, (startY + dashWidth).clamp(rect.top, rect.bottom)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // Bottom edge
    startX = rect.right;
    while (startX > rect.left) {
      canvas.drawLine(
        Offset(startX, rect.bottom),
        Offset((startX - dashWidth).clamp(rect.left, rect.right), rect.bottom),
        paint,
      );
      startX -= dashWidth + dashSpace;
    }

    // Left edge
    startY = rect.bottom;
    while (startY > rect.top) {
      canvas.drawLine(
        Offset(rect.left, startY),
        Offset(rect.left, (startY - dashWidth).clamp(rect.top, rect.bottom)),
        paint,
      );
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is DocumentDetectionPainter &&
        (oldDelegate.isDetected != isDetected || oldDelegate.color != color);
  }
}

class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is GridPainter && oldDelegate.color != color;
  }
}