import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MetricsCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const MetricsCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        width: 40.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: _getIconName(icon),
                    color: iconColor ?? theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                if (onTap != null)
                  CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 16,
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            if (isLoading)
              _buildShimmerEffect(context)
            else
              _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 10.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 2.5.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 0.5.h),
        Container(
          width: 15.w,
          height: 1.5.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 0.5.h),
        Container(
          width: 12.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.receipt_long) return 'receipt_long';
    if (icon == Icons.pending_actions) return 'pending_actions';
    if (icon == Icons.trending_up) return 'trending_up';
    if (icon == Icons.schedule) return 'schedule';
    if (icon == Icons.account_balance_wallet) return 'account_balance_wallet';
    if (icon == Icons.analytics) return 'analytics';
    return 'receipt_long';
  }
}
