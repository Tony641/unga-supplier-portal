import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/notification_card_widget.dart';
import './widgets/notification_empty_state_widget.dart';
import './widgets/notification_filter_tabs_widget.dart';
import './widgets/notification_search_widget.dart';

class NotificationsCenter extends StatefulWidget {
  const NotificationsCenter({super.key});

  @override
  State<NotificationsCenter> createState() => _NotificationsCenterState();
}

class _NotificationsCenterState extends State<NotificationsCenter>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  final List<String> _categories = [
    'All',
    'Invoice Updates',
    'Payments',
    'System Alerts',
  ];

  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  bool _isSearchVisible = false;
  bool _isBatchMode = false;
  bool _isRefreshing = false;
  final Set<String> _selectedNotifications = {};

  // Mock notifications data
  final List<Map<String, dynamic>> _allNotifications = [
    {
      "id": "1",
      "type": "invoice",
      "title": "Invoice INV-2024-001 Approved",
      "description":
          "Your invoice for maize supply has been approved and is now in processing queue for payment.",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
      "isUnread": true,
      "priority": "normal",
      "category": "Invoice Updates",
    },
    {
      "id": "2",
      "type": "payment",
      "title": "Payment Processed - KES 45,000",
      "description":
          "Payment for invoice INV-2024-002 has been successfully processed and transferred to your account.",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "isUnread": true,
      "priority": "high",
      "category": "Payments",
    },
    {
      "id": "3",
      "type": "invoice",
      "title": "Document Required for INV-2024-003",
      "description":
          "Additional documentation needed for your wheat supply invoice. Please upload delivery receipt.",
      "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
      "isUnread": false,
      "priority": "urgent",
      "category": "Invoice Updates",
    },
    {
      "id": "4",
      "type": "system",
      "title": "System Maintenance Scheduled",
      "description":
          "The supplier portal will undergo maintenance on Sunday, 18th August from 2:00 AM to 6:00 AM EAT.",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "isUnread": false,
      "priority": "normal",
      "category": "System Alerts",
    },
    {
      "id": "5",
      "type": "payment",
      "title": "Payment Delayed - INV-2024-004",
      "description":
          "Payment for your barley supply invoice is delayed due to bank processing. Expected completion: 2 business days.",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "isUnread": false,
      "priority": "high",
      "category": "Payments",
    },
    {
      "id": "6",
      "type": "invoice",
      "title": "Invoice INV-2024-005 Rejected",
      "description":
          "Your invoice has been rejected due to missing quality certificates. Please resubmit with required documents.",
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "isUnread": false,
      "priority": "urgent",
      "category": "Invoice Updates",
    },
    {
      "id": "7",
      "type": "alert",
      "title": "New Compliance Requirements",
      "description":
          "Updated supplier compliance requirements are now in effect. Please review the new guidelines in your dashboard.",
      "timestamp": DateTime.now().subtract(const Duration(days: 5)),
      "isUnread": false,
      "priority": "normal",
      "category": "System Alerts",
    },
    {
      "id": "8",
      "type": "payment",
      "title": "Monthly Statement Available",
      "description":
          "Your July 2024 payment statement is now available for download in the payments section.",
      "timestamp": DateTime.now().subtract(const Duration(days: 7)),
      "isUnread": false,
      "priority": "normal",
      "category": "Payments",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );

    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshAnimationController,
      curve: Curves.easeInOut,
    ));

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategoryIndex = _tabController.index;
          _isBatchMode = false;
          _selectedNotifications.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    List<Map<String, dynamic>> filtered = _allNotifications;

    // Filter by category
    if (_selectedCategoryIndex > 0) {
      final selectedCategory = _categories[_selectedCategoryIndex];
      filtered = filtered
          .where((notification) => notification["category"] == selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((notification) {
        final title = (notification["title"] as String? ?? "").toLowerCase();
        final description =
            (notification["description"] as String? ?? "").toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    return filtered;
  }

  Map<String, int> get _categoryCounts {
    final Map<String, int> counts = {};

    for (final category in _categories) {
      if (category == 'All') {
        counts[category] =
            _allNotifications.where((n) => n["isUnread"] == true).length;
      } else {
        counts[category] = _allNotifications
            .where((n) => n["category"] == category && n["isUnread"] == true)
            .length;
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          if (_isSearchVisible)
            NotificationSearchWidget(
              searchQuery: _searchQuery,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onSearchClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              isVisible: _isSearchVisible,
            ),
          NotificationFilterTabsWidget(
            categories: _categories,
            selectedIndex: _selectedCategoryIndex,
            onTabChanged: (index) {
              setState(() {
                _selectedCategoryIndex = index;
                _isBatchMode = false;
                _selectedNotifications.clear();
              });
            },
            categoryCounts: _categoryCounts,
          ),
          Expanded(
            child: _buildNotificationsList(context),
          ),
        ],
      ),
      floatingActionButton:
          _isBatchMode ? _buildBatchActionButton(context) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        _isBatchMode
            ? '${_selectedNotifications.length} selected'
            : 'Notifications',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      systemOverlayStyle: theme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      leading: _isBatchMode
          ? IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _isBatchMode = false;
                  _selectedNotifications.clear();
                });
              },
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurface,
                size: 6.w,
              ),
            )
          : IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: theme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
      actions: [
        if (!_isBatchMode) ...[
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchQuery = '';
                }
              });
            },
            icon: CustomIconWidget(
              iconName: _isSearchVisible ? 'search_off' : 'search',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              HapticFeedback.lightImpact();
              _handleMenuAction(value);
            },
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'done_all',
                      color: theme.colorScheme.onSurface,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Text('Mark All Read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'settings',
                      color: theme.colorScheme.onSurface,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _selectAllNotifications();
            },
            child: Text(
              'Select All',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    final filteredNotifications = _filteredNotifications;

    if (filteredNotifications.isEmpty) {
      return NotificationEmptyStateWidget(
        category: _categories[_selectedCategoryIndex],
        onRefresh: _handleRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          final notificationId = notification["id"] as String;

          return NotificationCardWidget(
            notification: notification,
            isSelected: _selectedNotifications.contains(notificationId),
            isBatchMode: _isBatchMode,
            onTap: () => _handleNotificationTap(notification),
            onMarkAsRead: () => _markAsRead(notificationId),
            onArchive: () => _archiveNotification(notificationId),
            onDelete: () => _deleteNotification(notificationId),
            onViewDetails: () => _viewNotificationDetails(notification),
            onSelectionChanged: (isSelected) {
              setState(() {
                if (isSelected) {
                  _selectedNotifications.add(notificationId);
                  if (!_isBatchMode) {
                    _isBatchMode = true;
                  }
                } else {
                  _selectedNotifications.remove(notificationId);
                  if (_selectedNotifications.isEmpty) {
                    _isBatchMode = false;
                  }
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildBatchActionButton(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _showBatchActionsBottomSheet(context);
      },
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      icon: CustomIconWidget(
        iconName: 'more_horiz',
        color: theme.colorScheme.onPrimary,
        size: 5.w,
      ),
      label: Text(
        'Actions',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showBatchActionsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
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
            Text(
              'Batch Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildBatchActionTile(
              context,
              'Mark as Read',
              'done_all',
              () => _batchMarkAsRead(),
            ),
            _buildBatchActionTile(
              context,
              'Archive',
              'archive',
              () => _batchArchive(),
            ),
            _buildBatchActionTile(
              context,
              'Delete',
              'delete',
              () => _batchDelete(),
              isDestructive: true,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchActionTile(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface,
        size: 6.w,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isDestructive
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    _refreshAnimationController.forward();
    HapticFeedback.mediumImpact();

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    _refreshAnimationController.reset();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications refreshed'),
          backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'settings':
        _openNotificationSettings();
        break;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    if (_isBatchMode) return;

    // Mark as read when tapped
    _markAsRead(notification["id"] as String);

    // Navigate based on notification type
    _viewNotificationDetails(notification);
  }

  void _viewNotificationDetails(Map<String, dynamic> notification) {
    final type = notification["type"] as String? ?? "";

    switch (type) {
      case "invoice":
        Navigator.pushNamed(context, '/invoice-status-tracking');
        break;
      case "payment":
        Navigator.pushNamed(context, '/dashboard');
        break;
      case "system":
      case "alert":
        // Show details dialog or navigate to relevant screen
        _showNotificationDetailsDialog(notification);
        break;
      default:
        _showNotificationDetailsDialog(notification);
    }
  }

  void _showNotificationDetailsDialog(Map<String, dynamic> notification) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          notification["title"] as String? ?? "",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          notification["description"] as String? ?? "",
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index =
          _allNotifications.indexWhere((n) => n["id"] == notificationId);
      if (index != -1) {
        _allNotifications[index]["isUnread"] = false;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _allNotifications) {
        notification["isUnread"] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _archiveNotification(String notificationId) {
    setState(() {
      _allNotifications.removeWhere((n) => n["id"] == notificationId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification archived'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _allNotifications.removeWhere((n) => n["id"] == notificationId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _selectAllNotifications() {
    setState(() {
      _selectedNotifications.clear();
      for (final notification in _filteredNotifications) {
        _selectedNotifications.add(notification["id"] as String);
      }
    });
  }

  void _batchMarkAsRead() {
    setState(() {
      for (final notificationId in _selectedNotifications) {
        final index =
            _allNotifications.indexWhere((n) => n["id"] == notificationId);
        if (index != -1) {
          _allNotifications[index]["isUnread"] = false;
        }
      }
      _selectedNotifications.clear();
      _isBatchMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected notifications marked as read'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _batchArchive() {
    setState(() {
      _allNotifications
          .removeWhere((n) => _selectedNotifications.contains(n["id"]));
      _selectedNotifications.clear();
      _isBatchMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected notifications archived'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _batchDelete() {
    setState(() {
      _allNotifications
          .removeWhere((n) => _selectedNotifications.contains(n["id"]));
      _selectedNotifications.clear();
      _isBatchMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected notifications deleted'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _openNotificationSettings() {
    // Navigate to notification settings or show settings dialog
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Notification Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Notification preferences and settings will be available in a future update.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
