import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Social Login Widget provides social authentication options
/// Currently supports Google Sign-In with native SDK integration
class SocialLoginWidget extends StatelessWidget {
  final Function(String) onSocialLogin;
  final bool isLoading;

  const SocialLoginWidget({
    super.key,
    required this.onSocialLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign-In button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : () => onSocialLogin('Google'),
            icon: Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.g_mobiledata,
                color: Colors.red,
                size: 6.w,
              ),
            ),
            label: Text(
              isLoading ? 'Signing In...' : 'Continue with Google',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(
                color: AppTheme.dividerLight,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 