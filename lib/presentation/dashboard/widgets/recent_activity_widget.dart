import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final VoidCallback? onViewAll;

  const RecentActivityWidget({
    super.key,
    required this.activities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (activities.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onViewAll?.call();
                  },
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          activities.isEmpty
              ? _buildEmptyState(context)
              : _buildActivityList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CustomIconWidget(
              iconName: 'receipt_long',
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'No Recent Activity',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Submit your first invoice to get started',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length > 5 ? 5 : activities.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(context, activity, index);
      },
    );
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity, int index) {
    final theme = Theme.of(context);
    final status = activity['status'] as String;
    final invoiceNumber = activity['invoiceNumber'] as String;
    final amount = activity['amount'] as String;
    final date = activity['date'] as DateTime;
    final description = activity['description'] as String;

    return Dismissible(
      key: Key('activity_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'visibility',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'View',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, '/invoice-status-tracking');
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showActivityDetails(context, activity);
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showContextMenu(context, activity);
        },
        child: Container(
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
                color: theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getStatusColor(status, theme).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getStatusIcon(status),
                  color: _getStatusColor(status, theme),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            invoiceNumber,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          amount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status, theme)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(status, theme),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(
      BuildContext context, Map<String, dynamic> activity) {
    Navigator.pushNamed(context, '/invoice-status-tracking');
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> activity) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'View Details',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/invoice-status-tracking');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'support_agent',
                color: theme.colorScheme.secondary,
                size: 24,
              ),
              title: Text(
                'Contact Support',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Contact support functionality
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
        return Colors.green;
      case 'pending':
      case 'submitted':
        return Colors.orange;
      case 'rejected':
      case 'failed':
        return Colors.red;
      case 'processing':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
        return 'check_circle';
      case 'pending':
      case 'submitted':
        return 'schedule';
      case 'rejected':
      case 'failed':
        return 'cancel';
      case 'processing':
        return 'sync';
      default:
        return 'info';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
