import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/app_settings_section.dart';
import './widgets/business_details_section.dart';
import './widgets/data_sync_indicator.dart';
import './widgets/personal_information_section.dart';
import './widgets/profile_photo_section.dart';

class ProfileManagement extends StatefulWidget {
  const ProfileManagement({super.key});

  @override
  State<ProfileManagement> createState() => _ProfileManagementState();
}

class _ProfileManagementState extends State<ProfileManagement> {
  final ScrollController _scrollController = ScrollController();

  bool _hasUnsavedChanges = false;
  bool _isLoading = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // Mock user data
  final Map<String, dynamic> _userData = {
    "profilePhoto":
        "https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=400",
    "fullName": "Samuel Kiprotich",
    "phoneNumber": "+254712345678",
    "phoneVerified": true,
    "email": "samuel.kiprotich@email.com",
    "preferredLanguage": "English",
    "companyName": "Kiprotich Agricultural Supplies",
    "registrationNumber": "BN/2019/45678",
    "businessType": "Agricultural Supplier",
    "primaryContact": "Samuel Kiprotich",
    "biometricEnabled": false,
    "pushNotificationsEnabled": true,
    "themeMode": "System",
    "currencyFormat": "KES 1,000.00",
  };

  @override
  void initState() {
    super.initState();
    _lastSyncTime = DateTime.now().subtract(Duration(minutes: 15));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile Management'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => _handleBackPress(),
        ),
        actions: [
          if (_hasUnsavedChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: _isLoading
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 2.h),
                ProfilePhotoSection(
                  currentPhotoUrl: _userData['profilePhoto'],
                  onPhotoChanged: _onPhotoChanged,
                ),
                SizedBox(height: 2.h),
                PersonalInformationSection(
                  personalData: {
                    'fullName': _userData['fullName'],
                    'phoneNumber': _userData['phoneNumber'],
                    'phoneVerified': _userData['phoneVerified'],
                    'email': _userData['email'],
                    'preferredLanguage': _userData['preferredLanguage'],
                  },
                  onDataChanged: _onPersonalDataChanged,
                ),
                BusinessDetailsSection(
                  businessData: {
                    'companyName': _userData['companyName'],
                    'registrationNumber': _userData['registrationNumber'],
                    'businessType': _userData['businessType'],
                    'primaryContact': _userData['primaryContact'],
                  },
                  onDataChanged: _onBusinessDataChanged,
                ),
                AppSettingsSection(
                  settingsData: {
                    'biometricEnabled': _userData['biometricEnabled'],
                    'pushNotificationsEnabled':
                        _userData['pushNotificationsEnabled'],
                    'themeMode': _userData['themeMode'],
                    'currencyFormat': _userData['currencyFormat'],
                  },
                  onSettingsChanged: _onSettingsChanged,
                ),
                DataSyncIndicator(
                  lastSyncTime: _lastSyncTime,
                  isLoading: _isSyncing,
                  onRefresh: _syncData,
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPhotoChanged(String? photoPath) {
    setState(() {
      _userData['profilePhoto'] = photoPath;
      _hasUnsavedChanges = true;
    });
  }

  void _onPersonalDataChanged(Map<String, dynamic> personalData) {
    setState(() {
      _userData.addAll(personalData);
      _hasUnsavedChanges = true;
    });
  }

  void _onBusinessDataChanged(Map<String, dynamic> businessData) {
    setState(() {
      _userData.addAll(businessData);
      _hasUnsavedChanges = true;
    });
  }

  void _onSettingsChanged(Map<String, dynamic> settingsData) {
    setState(() {
      _userData.addAll(settingsData);
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _hasUnsavedChanges = false;
        _lastSyncTime = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save changes. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isSyncing = true);

    try {
      // Simulate data refresh
      await Future.delayed(Duration(seconds: 1));

      setState(() => _lastSyncTime = DateTime.now());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile data refreshed'),
          backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    try {
      // Simulate manual sync
      await Future.delayed(Duration(seconds: 2));

      setState(() => _lastSyncTime = DateTime.now());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data synchronized successfully'),
          backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed. Please check your connection.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  void _handleBackPress() {
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsaved Changes'),
          content: Text(
              'You have unsaved changes. Do you want to save them before leaving?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'Discard',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _saveChanges();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
