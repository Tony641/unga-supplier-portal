import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DataSyncIndicator extends StatefulWidget {
  final DateTime? lastSyncTime;
  final bool isLoading;
  final VoidCallback onRefresh;

  const DataSyncIndicator({
    super.key,
    this.lastSyncTime,
    this.isLoading = false,
    required this.onRefresh,
  });

  @override
  State<DataSyncIndicator> createState() => _DataSyncIndicatorState();
}

class _DataSyncIndicatorState extends State<DataSyncIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(DataSyncIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _animationController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.isLoading ? null : widget.onRefresh,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: CustomIconWidget(
                    iconName: 'sync',
                    color: widget.isLoading
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 5.w,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isLoading ? 'Syncing data...' : 'Data Sync',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getLastSyncText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isLoading)
            TextButton(
              onPressed: widget.onRefresh,
              child: Text(
                'Refresh',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getLastSyncText() {
    if (widget.isLoading) {
      return 'Updating profile data...';
    }

    if (widget.lastSyncTime == null) {
      return 'Never synced';
    }

    final now = DateTime.now();
    final difference = now.difference(widget.lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Last updated just now';
    } else if (difference.inMinutes < 60) {
      return 'Last updated ${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return 'Last updated ${difference.inHours} hours ago';
    } else {
      return 'Last updated ${difference.inDays} days ago';
    }
  }
}
