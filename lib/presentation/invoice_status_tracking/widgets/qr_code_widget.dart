import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QrCodeWidget extends StatelessWidget {
  final String invoiceNumber;
  final String qrData;
  final VoidCallback? onShare;

  const QrCodeWidget({
    super.key,
    required this.invoiceNumber,
    required this.qrData,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QR Code Reference',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onShare?.call();
                },
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'share',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
            child: Center(
              child: Container(
                width: 35.w,
                height: 35.w,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomPaint(
                  painter: QRCodePainter(qrData),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Scan to track invoice: $invoiceNumber',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: qrData));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('QR code data copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'content_copy',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Copy Reference',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
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

class QRCodePainter extends CustomPainter {
  final String data;

  QRCodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Simple QR code pattern simulation
    final blockSize = size.width / 21;

    // Create a simple pattern based on the data
    final pattern = _generatePattern(data);

    for (int i = 0; i < 21; i++) {
      for (int j = 0; j < 21; j++) {
        if (pattern[i][j]) {
          canvas.drawRect(
            Rect.fromLTWH(
              j * blockSize,
              i * blockSize,
              blockSize,
              blockSize,
            ),
            paint,
          );
        }
      }
    }
  }

  List<List<bool>> _generatePattern(String data) {
    final pattern = List.generate(21, (i) => List.generate(21, (j) => false));

    // Add finder patterns (corners)
    _addFinderPattern(pattern, 0, 0);
    _addFinderPattern(pattern, 0, 14);
    _addFinderPattern(pattern, 14, 0);

    // Add some data pattern based on hash
    final hash = data.hashCode;
    for (int i = 0; i < 21; i++) {
      for (int j = 0; j < 21; j++) {
        if (!_isFinderPattern(i, j)) {
          pattern[i][j] = ((i + j + hash) % 3) == 0;
        }
      }
    }

    return pattern;
  }

  void _addFinderPattern(List<List<bool>> pattern, int startRow, int startCol) {
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        if (startRow + i < 21 && startCol + j < 21) {
          pattern[startRow + i][startCol + j] =
              (i == 0 || i == 6 || j == 0 || j == 6) ||
                  (i >= 2 && i <= 4 && j >= 2 && j <= 4);
        }
      }
    }
  }

  bool _isFinderPattern(int row, int col) {
    return (row < 7 && col < 7) ||
        (row < 7 && col >= 14) ||
        (row >= 14 && col < 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
