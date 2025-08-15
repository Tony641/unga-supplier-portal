import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_login_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/login_header_widget.dart';
import './widgets/social_login_widget.dart';

/// Login Screen enables secure supplier authentication with multiple verification methods
/// and seamless onboarding integration. Features clean mobile-first design with email/phone input,
/// password field, biometric authentication, social sign-in, and form validation.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isOnline = true;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// Initialize screen with connectivity check and biometric availability
  Future<void> _initializeScreen() async {
    await _checkConnectivity();
    await _checkBiometricAvailability();
    await _loadRememberedCredentials();
  }

  /// Check network connectivity
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _isOnline = connectivityResult != ConnectivityResult.none;
      });
    } catch (e) {
      setState(() {
        _isOnline = false;
      });
    }
  }

  /// Check biometric authentication availability
  Future<void> _checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool hadPreviousLogin =
          prefs.getBool('had_previous_login') ?? false;

      setState(() {
        _isBiometricAvailable =
            isAvailable && isDeviceSupported && hadPreviousLogin;
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  /// Load remembered credentials if available
  Future<void> _loadRememberedCredentials() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? rememberedEmail = prefs.getString('remembered_email');
      final bool rememberMe = prefs.getBool('remember_me') ?? false;

      if (rememberedEmail != null && rememberMe) {
        setState(() {
          _emailController.text = rememberedEmail;
          _rememberMe = rememberMe;
        });
      }
    } catch (e) {
      // Handle silently
    }
  }

  /// Handle email/password login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate login API call
      await Future.delayed(const Duration(seconds: 2));

      // Save authentication state
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setBool('had_previous_login', true);
      await prefs.setBool('remember_me', _rememberMe);

      if (_rememberMe) {
        await prefs.setString('remembered_email', _emailController.text.trim());
      } else {
        await prefs.remove('remembered_email');
      }

      // Show success and navigate
      _showSuccessToast('Login successful!');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
        );
      }
    } catch (e) {
      _showErrorToast('Login failed. Please check your credentials.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle biometric authentication
  Future<void> _handleBiometricLogin() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your supplier portal',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Save authentication state
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);

        _showSuccessToast('Biometric authentication successful!');
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.dashboard,
          );
        }
      }
    } catch (e) {
      _showErrorToast('Biometric authentication failed.');
    }
  }

  /// Handle social login (Google)
  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate social login
      await Future.delayed(const Duration(seconds: 2));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setBool('had_previous_login', true);

      _showSuccessToast('$provider sign-in successful!');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
        );
      }
    } catch (e) {
      _showErrorToast('$provider sign-in failed.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle forgot password
  void _handleForgotPassword() {
    // Navigate to forgot password screen or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter your email address to receive password reset instructions.'),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessToast('Reset instructions sent to your email');
            },
            child: const Text('Send Reset'),
          ),
        ],
      ),
    );
  }

  /// Navigate to registration
  void _handleRegistration() {
    // For now, navigate to dashboard as registration is not implemented
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  /// Show success toast
  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successLight,
      textColor: Colors.white,
    );
  }

  /// Show error toast
  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.errorLight,
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),

              // Header with logo and title
              const LoginHeaderWidget(),

              SizedBox(height: 6.h),

              // Login form
              Form(
                key: _formKey,
                child: LoginFormWidget(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  rememberMe: _rememberMe,
                  isLoading: _isLoading,
                  isOnline: _isOnline,
                  onTogglePasswordVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  onRememberMeChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  onLogin: _handleLogin,
                  onForgotPassword: _handleForgotPassword,
                ),
              ),

              SizedBox(height: 4.h),

              // Biometric login option
              if (_isBiometricAvailable)
                BiometricLoginWidget(
                  onBiometricLogin: _handleBiometricLogin,
                ),

              if (_isBiometricAvailable) SizedBox(height: 4.h),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.dividerLight)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.dividerLight)),
                ],
              ),

              SizedBox(height: 4.h),

              // Social login
              SocialLoginWidget(
                onSocialLogin: _handleSocialLogin,
                isLoading: _isLoading,
              ),

              SizedBox(height: 6.h),

              // Registration link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New Supplier? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: _handleRegistration,
                    child: Text(
                      'Register',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
} 