import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'widgets/splash_logo_widget.dart';

/// Splash Screen provides branded app launch experience with authentication state detection
/// and smooth transitions. Features Unga logo with subtle animation, brand gradient background,
/// authentication state detection, biometric authentication prompt, and network connectivity check.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isOnline = true;
  String? _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  /// Initialize logo and fade animations
  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  /// Start the splash screen sequence
  Future<void> _startSplashSequence() async {
    try {
      // Start animations
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      _logoController.forward();

      // Check network connectivity
      await _checkConnectivity();

      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: 2000));

      // Check authentication state and navigate
      await _checkAuthenticationAndNavigate();
    } catch (e) {
      // On error, navigate to login screen
      _navigateToLogin();
    }
  }

  /// Check network connectivity status
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

  /// Check authentication state and handle biometric authentication
  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      final bool isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      final bool biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

      // Check if onboarding is completed
      if (!onboardingCompleted) {
        _navigateToOnboarding();
        return;
      }

      if (isAuthenticated) {
        if (biometricEnabled && await _isBiometricAvailable()) {
          // Attempt biometric authentication
          final bool didAuthenticate = await _authenticateWithBiometrics();
          if (didAuthenticate) {
            _navigateToDashboard();
          } else {
            _navigateToLogin();
          }
        } else {
          // User is authenticated, go to dashboard
          _navigateToDashboard();
        }
      } else {
        // New user, go to login
        _navigateToLogin();
      }
    } catch (e) {
      _navigateToOnboarding();
    }
  }

  /// Check if biometric authentication is available
  Future<bool> _isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Perform biometric authentication
  Future<bool> _authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your supplier portal',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Navigate to supplier dashboard
  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.dashboard,
    );
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.loginScreen,
    );
  }

  /// Navigate to onboarding flow
  void _navigateToOnboarding() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.onboarding,
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryVariantLight,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Subtle geometric patterns
                _buildBackgroundPattern(),

                // Main splash content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      ScaleTransition(
                        scale: _logoAnimation,
                        child: const SplashLogoWidget(),
                      ),

                      SizedBox(height: 4.h),

                      // Loading indicator
                      _buildLoadingIndicator(),

                      SizedBox(height: 2.h),

                      // Connectivity status
                      _buildConnectivityStatus(),
                    ],
                  ),
                ),

                // App version in bottom corner
                _buildAppVersionInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build subtle background geometric pattern
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GeometricPatternPainter(),
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 6.w,
      height: 6.w,
      child: Theme.of(context).platform == TargetPlatform.iOS
          ? const CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 0.5.w,
            ),
    );
  }

  /// Build connectivity status indicator
  Widget _buildConnectivityStatus() {
    if (!_isOnline) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white70,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Offline Mode',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 10.sp,
                  ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Build app version information
  Widget _buildAppVersionInfo() {
    return Positioned(
      bottom: 4.h,
      right: 4.w,
      child: Text(
        'v$_appVersion',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              fontSize: 9.sp,
            ),
      ),
    );
  }
}

/// Custom painter for subtle geometric background patterns
class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw subtle geometric patterns
    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: Offset(size.width * 0.8, size.height * 0.2),
        width: (i + 1) * 100.0,
        height: (i + 1) * 100.0,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(20)),
        paint,
      );
    }

    for (int i = 0; i < 2; i++) {
      final rect = Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.8),
        width: (i + 1) * 80.0,
        height: (i + 1) * 80.0,
      );
      canvas.drawCircle(rect.center, rect.width / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 