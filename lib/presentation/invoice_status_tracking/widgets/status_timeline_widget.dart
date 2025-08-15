import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum InvoiceStatus {
  submitted,
  underReview,
  approved,
  paymentScheduled,
  paid,
}

class StatusTimelineWidget extends StatefulWidget {
  final InvoiceStatus currentStatus;
  final Map<InvoiceStatus, Map<String, dynamic>> statusDetails;
  final Function(InvoiceStatus) onStatusTap;

  const StatusTimelineWidget({
    super.key,
    required this.currentStatus,
    required this.statusDetails,
    required this.onStatusTap,
  });

  @override
  State<StatusTimelineWidget> createState() => _StatusTimelineWidgetState();
}

class _StatusTimelineWidgetState extends State<StatusTimelineWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statuses = InvoiceStatus.values;

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
            'Invoice Status Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          Column(
            children: statuses.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final isCompleted = status.index <= widget.currentStatus.index;
              final isCurrent = status == widget.currentStatus;
              final isLast = index == statuses.length - 1;

              return GestureDetector(
                onTap: () => widget.onStatusTap(status),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          isCurrent
                              ? AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: _buildStatusIcon(status,
                                          isCompleted, isCurrent, theme),
                                    );
                                  },
                                )
                              : _buildStatusIcon(
                                  status, isCompleted, isCurrent, theme),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 6.h,
                              color: isCompleted
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor.withValues(alpha: 0.3),
                            ),
                        ],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(status),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isCompleted
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _getStatusDescription(status),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            if (widget.statusDetails[status]?['timestamp'] !=
                                null)
                              Padding(
                                padding: EdgeInsets.only(top: 0.5.h),
                                child: Text(
                                  widget.statusDetails[status]!['timestamp']
                                      as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (widget.statusDetails[status]
                                        ?['estimatedTime'] !=
                                    null &&
                                !isCompleted)
                              Padding(
                                padding: EdgeInsets.only(top: 0.5.h),
                                child: Text(
                                  'Est. ${widget.statusDetails[status]!['estimatedTime']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.tertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(
      InvoiceStatus status, bool isCompleted, bool isCurrent, ThemeData theme) {
    Color backgroundColor;
    Color iconColor;
    String iconName;

    if (isCompleted) {
      backgroundColor = theme.colorScheme.primary;
      iconColor = theme.colorScheme.onPrimary;
      iconName = _getStatusIcon(status);
    } else {
      backgroundColor = theme.colorScheme.surface;
      iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      iconName = _getStatusIcon(status);
    }

    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: iconName,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }

  String _getStatusTitle(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.submitted:
        return 'Submitted';
      case InvoiceStatus.underReview:
        return 'Under Review';
      case InvoiceStatus.approved:
        return 'Approved';
      case InvoiceStatus.paymentScheduled:
        return 'Payment Scheduled';
      case InvoiceStatus.paid:
        return 'Paid';
    }
  }

  String _getStatusDescription(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.submitted:
        return 'Invoice has been successfully submitted';
      case InvoiceStatus.underReview:
        return 'Invoice is being reviewed by finance team';
      case InvoiceStatus.approved:
        return 'Invoice has been approved for payment';
      case InvoiceStatus.paymentScheduled:
        return 'Payment has been scheduled';
      case InvoiceStatus.paid:
        return 'Payment has been completed';
    }
  }

  String _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.submitted:
        return 'check_circle';
      case InvoiceStatus.underReview:
        return 'hourglass_empty';
      case InvoiceStatus.approved:
        return 'verified';
      case InvoiceStatus.paymentScheduled:
        return 'schedule';
      case InvoiceStatus.paid:
        return 'payments';
    }
  }
}
