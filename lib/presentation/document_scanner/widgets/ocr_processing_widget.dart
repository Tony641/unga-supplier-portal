import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class OcrProcessingWidget extends StatefulWidget {
  final String? extractedText;
  final bool isProcessing;
  final VoidCallback? onEditText;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;
  final Function(String)? onTextChanged;

  const OcrProcessingWidget({
    super.key,
    this.extractedText,
    this.isProcessing = false,
    this.onEditText,
    this.onContinue,
    this.onCancel,
    this.onTextChanged,
  });

  @override
  State<OcrProcessingWidget> createState() => _OcrProcessingWidgetState();
}

class _OcrProcessingWidgetState extends State<OcrProcessingWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    if (widget.isProcessing) {
      _progressController.repeat();
    } else if (widget.extractedText != null) {
      _textController.text = widget.extractedText!;
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(OcrProcessingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isProcessing != oldWidget.isProcessing) {
      if (widget.isProcessing) {
        _progressController.repeat();
      } else {
        _progressController.stop();
      }
    }

    if (widget.extractedText != oldWidget.extractedText &&
        widget.extractedText != null) {
      _textController.text = widget.extractedText!;
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: widget.isProcessing
            ? _buildProcessingView(context)
            : _buildResultView(context),
      ),
    );
  }

  Widget _buildProcessingView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Processing animation
        Container(
          width: 30.w,
          height: 30.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _progressAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: CustomPaint(
                        painter: ProgressRingPainter(
                          progress: _progressAnimation.value,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Center icon
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'text_fields',
                  color: Colors.white,
                  size: 8.w,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 4.h),

        // Processing text
        Text(
          'Extracting text...',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Please wait while we process your document',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 6.h),

        // Cancel button
        TextButton(
          onPressed: widget.onCancel,
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Extracted Text',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Success indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
                    'Text extracted successfully',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Text preview/editor
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isEditing
                    ? _buildTextEditor(context)
                    : _buildTextPreview(context),
              ),
            ),

            SizedBox(height: 3.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: _isEditing ? 'visibility' : 'edit',
                      color: Colors.white,
                      size: 5.w,
                    ),
                    label: Text(
                      _isEditing ? 'Preview' : 'Edit Text',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 2),
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_isEditing) {
                        widget.onTextChanged?.call(_textController.text);
                      }
                      widget.onContinue?.call();
                    },
                    icon: CustomIconWidget(
                      iconName: 'arrow_forward',
                      color: Colors.white,
                      size: 5.w,
                    ),
                    label: Text(
                      'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextPreview(BuildContext context) {
    return SingleChildScrollView(
      child: Text(
        _textController.text.isEmpty
            ? 'No text extracted'
            : _textController.text,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color:
              _textController.text.isEmpty ? Colors.grey[600] : Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextEditor(BuildContext context) {
    return TextField(
      controller: _textController,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Enter or edit extracted text...',
        hintStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.grey[600],
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: widget.onTextChanged,
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  ProgressRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      2 * 3.14159 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ProgressRingPainter &&
        oldDelegate.progress != progress;
  }
}