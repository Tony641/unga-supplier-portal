import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/welcome_card_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  bool _isLoading = true;
  int _notificationCount = 3;

  // Mock supplier data
  final String _supplierName = "Kiambu Farmers Cooperative";

  // Mock metrics data
  final List<Map<String, dynamic>> _metricsData = [
    {
      "title": "Outstanding Invoices",
      "value": "12",
      "subtitle": "KES 2,450,000",
      "icon": Icons.receipt_long,
      "iconColor": Colors.orange,
    },
    {
      "title": "Pending Payments",
      "value": "KES 1,200,000",
      "subtitle": "8 invoices",
      "icon": Icons.pending_actions,
      "iconColor": Colors.blue,
    },
    {
      "title": "This Month Activity",
      "value": "24",
      "subtitle": "Invoices submitted",
      "icon": Icons.trending_up,
      "iconColor": Colors.green,
    },
    {
      "title": "Average Payment Time",
      "value": "14 days",
      "subtitle": "Last 30 days",
      "icon": Icons.schedule,
      "iconColor": Colors.purple,
    },
  ];

  // Mock recent activity data
  final List<Map<String, dynamic>> _recentActivities = [
    {
      "invoiceNumber": "INV-2024-001",
      "amount": "KES 450,000",
      "status": "Approved",
      "date": DateTime.now().subtract(const Duration(hours: 2)),
      "description": "Maize supply - August batch",
    },
    {
      "invoiceNumber": "INV-2024-002",
      "amount": "KES 320,000",
      "status": "Processing",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "description": "Fertilizer procurement",
    },
    {
      "invoiceNumber": "INV-2024-003",
      "amount": "KES 180,000",
      "status": "Pending",
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "description": "Seeds and equipment",
    },
    {
      "invoiceNumber": "INV-2024-004",
      "amount": "KES 650,000",
      "status": "Paid",
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "description": "Wheat supply - July batch",
    },
    {
      "invoiceNumber": "INV-2024-005",
      "amount": "KES 290,000",
      "status": "Submitted",
      "date": DateTime.now().subtract(const Duration(days: 4)),
      "description": "Transport services",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    // Simulate refresh API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isRefreshing = false);
      HapticFeedback.lightImpact();
    }
  }

  void _onSubmitInvoice() {
    Navigator.pushNamed(context, '/invoice-submission');
  }

  void _onScanDocument() {
    Navigator.pushNamed(context, '/document-scanner');
  }

  void _onMetricTap(int index) {
    switch (index) {
      case 0:
      case 1:
        Navigator.pushNamed(context, '/invoice-status-tracking');
        break;
      case 2:
      case 3:
        // Navigate to analytics or reports
        break;
    }
  }

  void _onViewAllActivities() {
    Navigator.pushNamed(context, '/invoice-status-tracking');
  }

  void _onNotificationTap() {
    Navigator.pushNamed(context, '/notifications-center');
  }

  void _onProfileTap() {
    Navigator.pushNamed(context, '/profile-management');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(context),
                  _buildInvoicesTab(context),
                  _buildDocumentsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unga Supplier Portal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _supplierName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _onNotificationTap,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'notifications',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                    if (_notificationCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _notificationCount > 99
                                ? '99+'
                                : _notificationCount.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              GestureDetector(
                onTap: _onProfileTap,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'Invoices'),
          Tab(text: 'Documents'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            WelcomeCardWidget(
              supplierName: _supplierName,
              onRefresh: _onRefresh,
            ),
            SizedBox(height: 3.h),
            _buildMetricsSection(context),
            SizedBox(height: 4.h),
            QuickActionsWidget(
              onSubmitInvoice: _onSubmitInvoice,
              onScanDocument: _onScanDocument,
            ),
            SizedBox(height: 4.h),
            RecentActivityWidget(
              activities: _recentActivities,
              onViewAll: _onViewAllActivities,
            ),
            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 32.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: _metricsData.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final metric = _metricsData[index];
              return MetricsCardWidget(
                title: metric['title'] as String,
                value: metric['value'] as String,
                subtitle: metric['subtitle'] as String,
                icon: metric['icon'] as IconData,
                iconColor: metric['iconColor'] as Color?,
                isLoading: _isLoading,
                onTap: () => _onMetricTap(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesTab(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'receipt_long',
            color: theme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Invoices Tab',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Invoice management features coming soon',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'folder',
            color: theme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Documents Tab',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Document management features coming soon',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _onSubmitInvoice();
      },
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 6,
      icon: CustomIconWidget(
        iconName: 'add',
        color: theme.colorScheme.onPrimary,
        size: 24,
      ),
      label: Text(
        'New Invoice',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
