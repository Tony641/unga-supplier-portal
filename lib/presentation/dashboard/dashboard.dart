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
  
  // Search controllers
  final TextEditingController _invoiceSearchController = TextEditingController();
  final TextEditingController _documentSearchController = TextEditingController();
  
  // Filter states
  String _selectedInvoiceStatus = 'All';
  String _selectedDocumentType = 'All';
  String _selectedDateRange = 'All Time';

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

  // Mock invoices data
  final List<Map<String, dynamic>> _invoicesData = [
    {
      "invoiceNumber": "INV-2024-001",
      "amount": "KES 450,000",
      "status": "Approved",
      "date": DateTime.now().subtract(const Duration(hours: 2)),
      "description": "Maize supply - August batch",
      "dueDate": DateTime.now().add(const Duration(days: 7)),
      "customer": "Unga Limited",
      "category": "Grains",
    },
    {
      "invoiceNumber": "INV-2024-002",
      "amount": "KES 320,000",
      "status": "Processing",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "description": "Fertilizer procurement",
      "dueDate": DateTime.now().add(const Duration(days: 14)),
      "customer": "Unga Limited",
      "category": "Agro Chemicals",
    },
    {
      "invoiceNumber": "INV-2024-003",
      "amount": "KES 180,000",
      "status": "Pending",
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "description": "Seeds and equipment",
      "dueDate": DateTime.now().add(const Duration(days: 21)),
      "customer": "Unga Limited",
      "category": "Seeds",
    },
    {
      "invoiceNumber": "INV-2024-004",
      "amount": "KES 650,000",
      "status": "Paid",
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "description": "Wheat supply - July batch",
      "dueDate": DateTime.now().subtract(const Duration(days: 5)),
      "customer": "Unga Limited",
      "category": "Grains",
    },
    {
      "invoiceNumber": "INV-2024-005",
      "amount": "KES 290,000",
      "status": "Submitted",
      "date": DateTime.now().subtract(const Duration(days: 4)),
      "description": "Transport services",
      "dueDate": DateTime.now().add(const Duration(days: 30)),
      "customer": "Unga Limited",
      "category": "Services",
    },
    {
      "invoiceNumber": "INV-2024-006",
      "amount": "KES 890,000",
      "status": "Draft",
      "date": DateTime.now().subtract(const Duration(days: 5)),
      "description": "Rice supply - September batch",
      "dueDate": DateTime.now().add(const Duration(days: 45)),
      "customer": "Unga Limited",
      "category": "Grains",
    },
    {
      "invoiceNumber": "INV-2024-007",
      "amount": "KES 125,000",
      "status": "Rejected",
      "date": DateTime.now().subtract(const Duration(days: 6)),
      "description": "Pesticides supply",
      "dueDate": DateTime.now().add(const Duration(days: 15)),
      "customer": "Unga Limited",
      "category": "Agro Chemicals",
    },
  ];

  // Mock documents data
  final List<Map<String, dynamic>> _documentsData = [
    {
      "name": "Invoice Template 2024",
      "type": "Template",
      "size": "2.5 MB",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "status": "Active",
      "icon": Icons.description,
      "color": Colors.blue,
    },
    {
      "name": "Contract Agreement",
      "type": "Contract",
      "size": "1.8 MB",
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "status": "Active",
      "icon": Icons.assignment,
      "color": Colors.green,
    },
    {
      "name": "Quality Certificate",
      "type": "Certificate",
      "size": "3.2 MB",
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "status": "Expired",
      "icon": Icons.verified,
      "color": Colors.orange,
    },
    {
      "name": "Tax Compliance",
      "type": "Compliance",
      "size": "4.1 MB",
      "date": DateTime.now().subtract(const Duration(days: 4)),
      "status": "Active",
      "icon": Icons.account_balance,
      "color": Colors.purple,
    },
    {
      "name": "Delivery Note Template",
      "type": "Template",
      "size": "1.2 MB",
      "date": DateTime.now().subtract(const Duration(days: 5)),
      "status": "Active",
      "icon": Icons.local_shipping,
      "color": Colors.teal,
    },
    {
      "name": "Insurance Policy",
      "type": "Insurance",
      "size": "5.6 MB",
      "date": DateTime.now().subtract(const Duration(days: 6)),
      "status": "Active",
      "icon": Icons.security,
      "color": Colors.indigo,
    },
  ];

  // Filter options
  final List<String> _invoiceStatusOptions = ['All', 'Draft', 'Submitted', 'Processing', 'Approved', 'Paid', 'Rejected'];
  final List<String> _documentTypeOptions = ['All', 'Template', 'Contract', 'Certificate', 'Compliance', 'Insurance'];
  final List<String> _dateRangeOptions = ['All Time', 'Today', 'This Week', 'This Month', 'Last 30 Days', 'Last 90 Days'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _invoiceSearchController.dispose();
    _documentSearchController.dispose();
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

  void _onInvoiceTap(Map<String, dynamic> invoice) {
    Navigator.pushNamed(context, '/invoice-status-tracking');
  }

  void _onDocumentTap(Map<String, dynamic> document) {
    // Handle document tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${document['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'paid':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: theme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            _buildInvoiceSearchAndFilters(context),
            SizedBox(height: 2.h),
            _buildInvoiceStats(context),
            SizedBox(height: 2.h),
            _buildInvoiceList(context),
            SizedBox(height: 10.h), // Space for potential FAB
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSearchAndFilters(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _invoiceSearchController,
            decoration: InputDecoration(
              hintText: 'Search invoices...',
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              suffixIcon: _invoiceSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      onPressed: () {
                        _invoiceSearchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              filled: true,
              fillColor: theme.cardColor,
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 2.h),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Status', _selectedInvoiceStatus, _invoiceStatusOptions, (value) {
                  setState(() => _selectedInvoiceStatus = value);
                }),
                SizedBox(width: 2.w),
                _buildFilterChip(context, 'Date Range', _selectedDateRange, _dateRangeOptions, (value) {
                  setState(() => _selectedDateRange = value);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String selectedValue, List<String> options, Function(String) onChanged) {
    final theme = Theme.of(context);
    
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) => options.map((option) => PopupMenuItem(
        value: option,
        child: Text(option),
      )).toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $selectedValue',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 1.w),
            Icon(Icons.arrow_drop_down, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceStats(BuildContext context) {
    final theme = Theme.of(context);
    
    final totalInvoices = _invoicesData.length;
    final pendingInvoices = _invoicesData.where((inv) => inv['status'] == 'Pending' || inv['status'] == 'Processing').length;
    final paidInvoices = _invoicesData.where((inv) => inv['status'] == 'Paid').length;
    final totalAmount = _invoicesData.fold<double>(0, (sum, inv) => sum + double.parse(inv['amount'].toString().replaceAll(RegExp(r'[^\d.]'), '')));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(context, 'Total', totalInvoices.toString(), Icons.receipt_long, Colors.blue),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStatCard(context, 'Pending', pendingInvoices.toString(), Icons.pending_actions, Colors.orange),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStatCard(context, 'Paid', paidInvoices.toString(), Icons.check_circle, Colors.green),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStatCard(context, 'Total Amount', 'KES ${(totalAmount / 1000).toStringAsFixed(0)}K', Icons.attach_money, Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(BuildContext context) {
    final theme = Theme.of(context);
    
    // Filter invoices based on search and filters
    List<Map<String, dynamic>> filteredInvoices = _invoicesData.where((invoice) {
      final searchQuery = _invoiceSearchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty || 
          invoice['invoiceNumber'].toString().toLowerCase().contains(searchQuery) ||
          invoice['description'].toString().toLowerCase().contains(searchQuery) ||
          invoice['customer'].toString().toLowerCase().contains(searchQuery);
      
      final matchesStatus = _selectedInvoiceStatus == 'All' || invoice['status'] == _selectedInvoiceStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoices (${filteredInvoices.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/invoice-status-tracking'),
                icon: Icon(Icons.view_list, size: 16),
                label: Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (filteredInvoices.isEmpty)
            _buildEmptyState(context, 'No invoices found', 'Try adjusting your search or filters')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredInvoices.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) => _buildInvoiceCard(context, filteredInvoices[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Map<String, dynamic> invoice) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(invoice['status']);

    return GestureDetector(
      onTap: () => _onInvoiceTap(invoice),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 4,
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
                Expanded(
                  child: Text(
                    invoice['invoiceNumber'],
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    invoice['status'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              invoice['description'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice['amount'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Due: ${_formatDate(invoice['dueDate'])}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    invoice['customer'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invoice['category'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: theme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            _buildDocumentSearchAndFilters(context),
            SizedBox(height: 2.h),
            _buildDocumentStats(context),
            SizedBox(height: 2.h),
            _buildDocumentList(context),
            SizedBox(height: 10.h), // Space for potential FAB
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSearchAndFilters(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _documentSearchController,
            decoration: InputDecoration(
              hintText: 'Search documents...',
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              suffixIcon: _documentSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      onPressed: () {
                        _documentSearchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              filled: true,
              fillColor: theme.cardColor,
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 2.h),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Type', _selectedDocumentType, _documentTypeOptions, (value) {
                  setState(() => _selectedDocumentType = value);
                }),
                SizedBox(width: 2.w),
                _buildFilterChip(context, 'Date Range', _selectedDateRange, _dateRangeOptions, (value) {
                  setState(() => _selectedDateRange = value);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStats(BuildContext context) {
    final theme = Theme.of(context);
    
    final totalDocuments = _documentsData.length;
    final activeDocuments = _documentsData.where((doc) => doc['status'] == 'Active').length;
    final expiredDocuments = _documentsData.where((doc) => doc['status'] == 'Expired').length;
    final totalSize = _documentsData.fold<double>(0, (sum, doc) => sum + double.parse(doc['size'].toString().replaceAll(RegExp(r'[^\d.]'), '')));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(context, 'Total', totalDocuments.toString(), Icons.folder, Colors.blue),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStatCard(context, 'Active', activeDocuments.toString(), Icons.check_circle, Colors.green),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStatCard(context, 'Expired', expiredDocuments.toString(), Icons.warning, Colors.orange),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStatCard(context, 'Total Size', '${totalSize.toStringAsFixed(1)} MB', Icons.storage, Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context) {
    final theme = Theme.of(context);
    
    // Filter documents based on search and filters
    List<Map<String, dynamic>> filteredDocuments = _documentsData.where((document) {
      final searchQuery = _documentSearchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty || 
          document['name'].toString().toLowerCase().contains(searchQuery) ||
          document['type'].toString().toLowerCase().contains(searchQuery);
      
      final matchesType = _selectedDocumentType == 'All' || document['type'] == _selectedDocumentType;
      
      return matchesSearch && matchesType;
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documents (${filteredDocuments.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _onScanDocument(),
                    icon: Icon(Icons.camera_alt, size: 20),
                    tooltip: 'Scan Document',
                    style: IconButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to document management
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Document management coming soon')),
                      );
                    },
                    icon: Icon(Icons.folder_open, size: 16),
                    label: Text('Manage'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (filteredDocuments.isEmpty)
            _buildEmptyState(context, 'No documents found', 'Try adjusting your search or filters')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDocuments.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) => _buildDocumentCard(context, filteredDocuments[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, Map<String, dynamic> document) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(document['status']);

    return GestureDetector(
      onTap: () => _onDocumentTap(document),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
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
            // Document icon
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: document['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: document['color'].withValues(alpha: 0.3)),
              ),
              child: Icon(
                document['icon'],
                color: document['color'],
                size: 20,
              ),
            ),
            SizedBox(width: 4.w),
            // Document details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          document['name'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          document['status'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          document['type'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        document['size'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Updated: ${_formatDate(document['date'])}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Action button
            IconButton(
              onPressed: () => _onDocumentTap(document),
              icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
