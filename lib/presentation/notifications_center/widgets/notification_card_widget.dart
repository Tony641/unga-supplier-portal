import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;
  final bool isSelected;
  final bool isBatchMode;
  final ValueChanged<bool>? onSelectionChanged;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onArchive,
    this.onDelete,
    this.onViewDetails,
    this.isSelected = false,
    this.isBatchMode = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = notification["isUnread"] as bool? ?? false;
    final type = notification["type"] as String? ?? "system";
    final title = notification["title"] as String? ?? "";
    final description = notification["description"] as String? ?? "";
    final timestamp = notification["timestamp"] as DateTime? ?? DateTime.now();
    final priority = notification["priority"] as String? ?? "normal";

    return Dismissible(
      key: Key(notification["id"].toString()),
      background: _buildSwipeBackground(context, isLeft: false),
      secondaryBackground: _buildSwipeBackground(context, isLeft: true),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          onMarkAsRead?.call();
        } else {
          onViewDetails?.call();
        }
      },
      confirmDismiss: (direction) async {
        HapticFeedback.lightImpact();
        return false; // Prevent actual dismissal, just trigger actions
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (isBatchMode) {
            onSelectionChanged?.call(!isSelected);
          } else {
            onTap?.call();
          }
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onSelectionChanged?.call(!isSelected);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isUnread
                ? theme.colorScheme.primary.withValues(alpha: 0.05)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.dividerColor.withValues(alpha: 0.5),
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBatchMode) ...[
                      Container(
                        width: 6.w,
                        height: 6.w,
                        margin: EdgeInsets.only(right: 3.w, top: 0.5.h),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                            width: 2,
                          ),
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? CustomIconWidget(
                                iconName: 'check',
                                color: theme.colorScheme.onPrimary,
                                size: 3.w,
                              )
                            : null,
                      ),
                    ],
                    _buildNotificationIcon(context, type, priority),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: isUnread
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 2.w,
                                  height: 2.w,
                                  margin: EdgeInsets.only(left: 2.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Text(
                                _formatTimestamp(timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                              _buildPriorityBadge(context, priority),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (priority == "high")
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 1.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
      BuildContext context, String type, String priority) {
    final theme = Theme.of(context);
    String iconName;
    Color iconColor;

    switch (type) {
      case "invoice":
        iconName = "receipt_long";
        iconColor = theme.colorScheme.primary;
        break;
      case "payment":
        iconName = "payments";
        iconColor =
            AppTheme.getSuccessColor(theme.brightness == Brightness.light);
        break;
      case "alert":
        iconName = "warning";
        iconColor =
            AppTheme.getWarningColor(theme.brightness == Brightness.light);
        break;
      case "system":
        iconName = "info";
        iconColor = theme.colorScheme.secondary;
        break;
      default:
        iconName = "notifications";
        iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }

    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withValues(alpha: 0.1),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: iconName,
          color: iconColor,
          size: 5.w,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context, String priority) {
    if (priority == "normal") return const SizedBox.shrink();

    final theme = Theme.of(context);
    Color badgeColor;
    String label;

    switch (priority) {
      case "high":
        badgeColor = theme.colorScheme.error;
        label = "High";
        break;
      case "urgent":
        badgeColor = theme.colorScheme.error;
        label = "Urgent";
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? theme.colorScheme.secondary.withValues(alpha: 0.1)
            : AppTheme.getSuccessColor(theme.brightness == Brightness.light)
                .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? "visibility" : "check",
                color: isLeft
                    ? theme.colorScheme.secondary
                    : AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light),
                size: 6.w,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? "View" : "Mark Read",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isLeft
                      ? theme.colorScheme.secondary
                      : AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }
}
