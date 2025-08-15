import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class WelcomeCardWidget extends StatelessWidget {
  final String supplierName;
  final VoidCallback? onRefresh;

  const WelcomeCardWidget({
    super.key,
    required this.supplierName,
    this.onRefresh,
  });

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getWeatherMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) {
      return 'Perfect time to start your day!';
    } else if (hour >= 10 && hour < 14) {
      return 'Great weather for business today!';
    } else if (hour >= 14 && hour < 18) {
      return 'Hope your day is going well!';
    } else {
      return 'Time to wrap up the day!';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreetingMessage()},',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      supplierName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'wb_sunny',
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            _getCurrentDate(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            _getWeatherMessage(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
