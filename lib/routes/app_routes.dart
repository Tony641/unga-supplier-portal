import 'package:flutter/material.dart';
import '../presentation/document_scanner/document_scanner.dart';
import '../presentation/notifications_center/notifications_center.dart';
import '../presentation/invoice_status_tracking/invoice_status_tracking.dart';
import '../presentation/invoice_submission/invoice_submission.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/profile_management/profile_management.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding/onboarding_flow.dart';
import '../presentation/login_screen/login_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash';
  static const String dashboard = '/dashboard';
  static const String loginScreen = '/login';
  static const String onboarding = '/onboarding';
  static const String documentScanner = '/document-scanner';
  static const String notificationsCenter = '/notifications-center';
  static const String invoiceStatusTracking = '/invoice-status-tracking';
  static const String invoiceSubmission = '/invoice-submission';
 
  static const String profileManagement = '/profile-management';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingFlow(),
    documentScanner: (context) => const DocumentScanner(),
    notificationsCenter: (context) => const NotificationsCenter(),
    invoiceStatusTracking: (context) => const InvoiceStatusTracking(),
    invoiceSubmission: (context) => const InvoiceSubmission(),
    dashboard: (context) => const Dashboard(),
    loginScreen: (context) => const LoginScreen(),
    profileManagement: (context) => const ProfileManagement(),
    // TODO: Add your other routes here
  };
}
