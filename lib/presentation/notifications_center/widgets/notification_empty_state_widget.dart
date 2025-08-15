import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationEmptyStateWidget extends StatefulWidget {
  final String category;
  final VoidCallback? onRefresh;

  const NotificationEmptyStateWidget({
    super.key,
    required this.category,
    this.onRefresh,
  });

  @override
  State<NotificationEmptyStateWidget> createState() =>
      _NotificationEmptyStateWidgetState();
}

class _NotificationEmptyStateWidgetState
    extends State<NotificationEmptyStateWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIllustration(context),
                    SizedBox(height: 4.h),
                    Text(
                      _getEmptyTitle(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _getEmptyDescription(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onRefresh?.call();
                      },
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: theme.colorScheme.onPrimary,
                        size: 5.w,
                      ),
                      label: Text(
                        'Refresh',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomIconWidget(
            iconName: _getEmptyIcon(),
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
            size: 20.w,
          ),
          Positioned(
            top: 8.w,
            right: 8.w,
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.getSuccessColor(
                    theme.brightness == Brightness.light),
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: theme.colorScheme.surface,
                size: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyTitle() {
    switch (widget.category.toLowerCase()) {
      case 'all':
        return 'All caught up!';
      case 'invoice updates':
        return 'No invoice updates';
      case 'payments':
        return 'No payment notifications';
      case 'system alerts':
        return 'No system alerts';
      default:
        return 'No notifications';
    }
  }

  String _getEmptyDescription() {
    switch (widget.category.toLowerCase()) {
      case 'all':
        return 'You\'re up to date with all your notifications. Check back later for new updates from Unga Holdings.';
      case 'invoice updates':
        return 'No recent updates on your submitted invoices. New status changes will appear here.';
      case 'payments':
        return 'No payment notifications at the moment. Payment confirmations and updates will show here.';
      case 'system alerts':
        return 'No system alerts currently. Important system messages and maintenance notices will appear here.';
      default:
        return 'No notifications in this category. New updates will appear here when available.';
    }
  }

  String _getEmptyIcon() {
    switch (widget.category.toLowerCase()) {
      case 'all':
        return 'notifications_none';
      case 'invoice updates':
        return 'receipt_long';
      case 'payments':
        return 'payments';
      case 'system alerts':
        return 'info_outline';
      default:
        return 'notifications_none';
    }
  }
}
