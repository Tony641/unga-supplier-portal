import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class NotificationFilterTabsWidget extends StatefulWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Map<String, int> categoryCounts;

  const NotificationFilterTabsWidget({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onTabChanged,
    this.categoryCounts = const {},
  });

  @override
  State<NotificationFilterTabsWidget> createState() =>
      _NotificationFilterTabsWidgetState();
}

class _NotificationFilterTabsWidgetState
    extends State<NotificationFilterTabsWidget> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.categories.length,
      initialIndex: widget.selectedIndex,
      vsync: this,
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
        widget.onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NotificationFilterTabsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _tabController.animateTo(widget.selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Expanded(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                indicatorColor: theme.colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                tabs: widget.categories.map((category) {
                  final count = widget.categoryCounts[category] ?? 0;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category),
                        if (count > 0) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 5.w,
                              minHeight: 2.5.h,
                            ),
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
