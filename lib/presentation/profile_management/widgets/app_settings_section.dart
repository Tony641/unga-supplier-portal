import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppSettingsSection extends StatefulWidget {
  final Map<String, dynamic> settingsData;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const AppSettingsSection({
    super.key,
    required this.settingsData,
    required this.onSettingsChanged,
  });

  @override
  State<AppSettingsSection> createState() => _AppSettingsSectionState();
}

class _AppSettingsSectionState extends State<AppSettingsSection> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _biometricEnabled = false;
  bool _pushNotificationsEnabled = true;
  String _themeMode = 'System';
  String _currencyFormat = 'KES 1,000.00';
  bool _biometricAvailable = false;

  final List<String> _themeModes = ['System', 'Light', 'Dark'];
  final List<String> _currencyFormats = [
    'KES 1,000.00',
    'KSh 1,000.00',
    '1,000.00 KES'
  ];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _checkBiometricAvailability();
  }

  void _initializeSettings() {
    _biometricEnabled = widget.settingsData['biometricEnabled'] ?? false;
    _pushNotificationsEnabled =
        widget.settingsData['pushNotificationsEnabled'] ?? true;
    _themeMode = widget.settingsData['themeMode'] ?? 'System';
    _currencyFormat = widget.settingsData['currencyFormat'] ?? 'KES 1,000.00';
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      setState(() {
        _biometricAvailable = isAvailable && availableBiometrics.isNotEmpty;
      });
    } catch (e) {
      setState(() => _biometricAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'settings',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'App Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildBiometricSetting(),
          SizedBox(height: 2.h),
          _buildNotificationSetting(),
          SizedBox(height: 2.h),
          _buildThemeSetting(),
          SizedBox(height: 2.h),
          _buildCurrencySetting(),
          SizedBox(height: 3.h),
          _buildChangePasswordButton(),
          SizedBox(height: 2.h),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildBiometricSetting() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: 'fingerprint',
              color: theme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Authentication',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _biometricAvailable
                      ? 'Use fingerprint or face recognition'
                      : 'Not available on this device',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _biometricEnabled && _biometricAvailable,
            onChanged: _biometricAvailable ? _toggleBiometric : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: 'notifications',
              color: theme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Receive updates about invoice status',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _pushNotificationsEnabled,
            onChanged: _toggleNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSetting() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: 'palette',
              color: theme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Choose your preferred theme',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _themeMode,
                items: _themeModes.map((String mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Text(
                      mode,
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _themeMode = newValue);
                    _onSettingChanged('themeMode', newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySetting() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: 'attach_money',
              color: theme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currency Display',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Choose currency format',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currencyFormat,
                items: _currencyFormats.map((String format) {
                  return DropdownMenuItem<String>(
                    value: format,
                    child: Text(
                      format,
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _currencyFormat = newValue);
                    _onSettingChanged('currencyFormat', newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _changePassword,
      borderRadius: BorderRadius.circular(2.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: 'lock',
                color: theme.colorScheme.secondary,
                size: 6.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Update your account password',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _showLogoutDialog,
      borderRadius: BorderRadius.circular(2.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: 'logout',
                color: theme.colorScheme.error,
                size: 6.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Sign out of your account',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.error.withValues(alpha: 0.6),
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      try {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
          options: AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          setState(() => _biometricEnabled = true);
          _onSettingChanged('biometricEnabled', true);
          _showSuccessMessage('Biometric authentication enabled');
        }
      } catch (e) {
        _showErrorMessage('Failed to enable biometric authentication');
      }
    } else {
      setState(() => _biometricEnabled = false);
      _onSettingChanged('biometricEnabled', false);
      _showSuccessMessage('Biometric authentication disabled');
    }
  }

  void _toggleNotifications(bool value) {
    setState(() => _pushNotificationsEnabled = value);
    _onSettingChanged('pushNotificationsEnabled', value);
    _showSuccessMessage(
        value ? 'Push notifications enabled' : 'Push notifications disabled');
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content:
            Text('You will be redirected to the secure password change flow.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Password change flow initiated');
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to logout?'),
            SizedBox(height: 2.h),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                Expanded(
                  child: Text(
                    'Logout from all devices',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    _showSuccessMessage('Logged out successfully');
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  void _onSettingChanged(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(widget.settingsData);
    updatedSettings[key] = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
