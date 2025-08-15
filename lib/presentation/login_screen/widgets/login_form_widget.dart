import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Login Form Widget handles the main authentication form with email/phone input,
/// password field, remember me checkbox, and login button
class LoginFormWidget extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final bool isOnline;
  final VoidCallback onTogglePasswordVisibility;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.isOnline,
    required this.onTogglePasswordVisibility,
    required this.onRememberMeChanged,
    required this.onLogin,
    required this.onForgotPassword,
  });

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone number is required';
    }

    // Check if it's a phone number (contains only digits, spaces, +, -, (, ))
    final phoneRegex = RegExp(r'^[\d\s\+\-\(\)]+$');
    if (phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      if (value.replaceAll(RegExp(r'[\s\-\(\)]'), '').length < 10) {
        return 'Please enter a valid phone number';
      }
      return null; // Valid phone number
    }

    // Check email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Determine keyboard type based on input
  TextInputType _getKeyboardType() {
    final text = emailController.text;
    final phoneRegex = RegExp(r'^[\d\+\-\(\)\s]*$');

    if (text.isNotEmpty && phoneRegex.hasMatch(text)) {
      return TextInputType.phone;
    }
    return TextInputType.emailAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email/Phone input field
        TextFormField(
          controller: emailController,
          keyboardType: _getKeyboardType(),
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          validator: _validateEmail,
          onChanged: (_) {
            // Rebuild to update keyboard type
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                (context as Element).markNeedsBuild();
              }
            });
          },
          decoration: InputDecoration(
            labelText: 'Email or Phone Number',
            hintText: 'Enter your email or phone number',
            prefixIcon: Icon(
              _getKeyboardType() == TextInputType.phone
                  ? Icons.phone_outlined
                  : Icons.email_outlined,
              color: AppTheme.textSecondaryLight,
            ),
            suffixIcon: emailController.text.isNotEmpty
                ? IconButton(
                    onPressed: isLoading ? null : () => emailController.clear(),
                    icon: const Icon(Icons.clear, size: 20),
                    color: AppTheme.textSecondaryLight,
                  )
                : null,
          ),
        ),

        SizedBox(height: 3.h),

        // Password input field
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          validator: _validatePassword,
          onFieldSubmitted: (_) => isLoading ? null : onLogin(),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppTheme.textSecondaryLight,
            ),
            suffixIcon: IconButton(
              onPressed: isLoading ? null : onTogglePasswordVisibility,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Remember me and forgot password row
        Row(
          children: [
            // Remember me checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: rememberMe,
                onChanged: isLoading ? null : onRememberMeChanged,
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: isLoading ? null : () => onRememberMeChanged(!rememberMe),
              child: Text(
                'Remember Me',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLoading
                          ? AppTheme.textSecondaryLight
                          : AppTheme.textPrimaryLight,
                    ),
              ),
            ),

            const Spacer(),

            // Forgot password link
            GestureDetector(
              onTap: isLoading ? null : onForgotPassword,
              child: Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLoading
                          ? AppTheme.textSecondaryLight
                          : AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: isLoading
                          ? AppTheme.textSecondaryLight
                          : AppTheme.primaryLight,
                    ),
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Sign in button
        SizedBox(
          height: 7.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isLoading ? AppTheme.dividerLight : AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      const Text('Signing In...'),
                    ],
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        // Offline indicator
        if (!isOnline) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warningLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off,
                  color: AppTheme.warningLight,
                  size: 4.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'You are currently offline. Some features may not be available.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.warningLight,
                          fontSize: 11.sp,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
} 