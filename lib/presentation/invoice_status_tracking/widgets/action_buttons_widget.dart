import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool showDownloadReceipt;
  final bool showContactSupport;
  final VoidCallback? onDownloadReceipt;
  final VoidCallback? onContactSupport;
  final VoidCallback? onShareStatus;
  final VoidCallback? onSetReminder;

  const ActionButtonsWidget({
    super.key,
    this.showDownloadReceipt = false,
    this.showContactSupport = false,
    this.onDownloadReceipt,
    this.onContactSupport,
    this.onShareStatus,
    this.onSetReminder,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          if (showDownloadReceipt || showContactSupport) ...[
            Row(
              children: [
                if (showDownloadReceipt)
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Download Receipt',
                      'download',
                      theme.colorScheme.primary,
                      onDownloadReceipt,
                      theme,
                    ),
                  ),
                if (showDownloadReceipt && showContactSupport)
                  SizedBox(width: 3.w),
                if (showContactSupport)
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Contact Support',
                      'support_agent',
                      theme.colorScheme.secondary,
                      onContactSupport,
                      theme,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Share Status',
                  'share',
                  theme.colorScheme.tertiary,
                  onShareStatus,
                  theme,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Set Reminder',
                  'notifications',
                  theme.colorScheme.outline,
                  onSetReminder,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    Color color,
    VoidCallback? onPressed,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed?.call();
      },
      child: Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
