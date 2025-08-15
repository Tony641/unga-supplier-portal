import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Biometric Login Widget provides biometric authentication option
/// with appropriate icons and descriptive text for supported devices
class BiometricLoginWidget extends StatelessWidget {
  final VoidCallback onBiometricLogin;

  const BiometricLoginWidget({
    super.key,
    required this.onBiometricLogin,
  });

  /// Get biometric icon based on platform
  IconData _getBiometricIcon() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Icons
          .fingerprint; // Face ID and Touch ID both use fingerprint icon
    } else {
      return Icons.fingerprint; // Android fingerprint
    }
  }

  /// Get biometric text based on platform
  String _getBiometricText() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Use Face ID or Touch ID';
    } else {
      return 'Use Fingerprint or Face Unlock';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Biometric icon
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getBiometricIcon(),
              color: AppTheme.primaryLight,
              size: 8.w,
            ),
          ),

          SizedBox(height: 2.h),

          // Biometric text
          Text(
            _getBiometricText(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
          ),

          SizedBox(height: 1.h),

          // Description
          Text(
            'Quick and secure access to your account',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 3.h),

          // Biometric login button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: OutlinedButton.icon(
              onPressed: onBiometricLogin,
              icon: Icon(
                _getBiometricIcon(),
                size: 5.w,
              ),
              label: const Text(
                'Login with Biometrics',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppTheme.primaryLight,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 