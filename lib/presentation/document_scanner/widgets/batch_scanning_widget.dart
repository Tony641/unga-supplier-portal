import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class BatchScanningWidget extends StatefulWidget {
  final List<String> capturedImages;
  final VoidCallback? onAddAnother;
  final VoidCallback? onComplete;
  final Function(int)? onRemoveImage;
  final Function(int)? onPreviewImage;

  const BatchScanningWidget({
    super.key,
    required this.capturedImages,
    this.onAddAnother,
    this.onComplete,
    this.onRemoveImage,
    this.onPreviewImage,
  });

  @override
  State<BatchScanningWidget> createState() => _BatchScanningWidgetState();
}

class _BatchScanningWidgetState extends State<BatchScanningWidget>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildImageGrid(context),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Batch Scanning',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${widget.capturedImages.length} document${widget.capturedImages.length != 1 ? 's' : ''} captured',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'close',
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: widget.capturedImages.isEmpty
            ? _buildEmptyState(context)
            : GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 3.w,
                  childAspectRatio: 0.75,
                ),
                itemCount: widget.capturedImages.length,
                itemBuilder: (context, index) {
                  return _buildImageThumbnail(context, index);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'document_scanner',
              color: Colors.white.withValues(alpha: 0.5),
              size: 10.w,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'No documents captured yet',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap the camera button to start scanning',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPreviewImage?.call(index);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[800],
                child: CustomImageWidget(
                  imageUrl: widget.capturedImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),

            // Page number
            Positioned(
              top: 2.w,
              left: 2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Remove button
            Positioned(
              top: 2.w,
              right: 2.w,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showRemoveDialog(context, index);
                },
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 4.w,
                  ),
                ),
              ),
            ),

            // Status indicator
            Positioned(
              bottom: 2.w,
              right: 2.w,
              child: Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check',
                  color: Colors.white,
                  size: 3.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          // Add another button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onAddAnother?.call();
              },
              icon: CustomIconWidget(
                iconName: 'add_a_photo',
                color: Colors.white,
                size: 5.w,
              ),
              label: Text(
                'Add Another',
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

          // Complete button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.capturedImages.isEmpty
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      widget.onComplete?.call();
                    },
              icon: CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 5.w,
              ),
              label: Text(
                'Complete',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.capturedImages.isEmpty
                    ? Colors.grey[600]
                    : AppTheme.lightTheme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 3.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Remove Document',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this document from the batch?',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onRemoveImage?.call(index);
                HapticFeedback.lightImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Remove',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}