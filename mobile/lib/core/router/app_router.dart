import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/scanner/qr_scanner_screen.dart';
import '../../presentation/screens/vehicle/vehicle_confirmation_screen.dart';
import '../../presentation/screens/report/report_form_screen.dart';
import '../../presentation/screens/report/success_screen.dart';
import '../../presentation/screens/tracking/track_entry_screen.dart';
import '../../presentation/screens/tracking/report_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/auth/verify_email_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/vehicle-confirmation',
        name: 'vehicle-confirmation',
        builder: (context, state) {
          final vehicle = state.extra as Map<String, dynamic>;
          return VehicleConfirmationScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/report-form',
        name: 'report-form',
        builder: (context, state) {
          final vehicle = state.extra as Map<String, dynamic>;
          return ReportFormScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/success',
        name: 'success',
        builder: (context, state) {
          final report = state.extra as Map<String, dynamic>;
          return SuccessScreen(report: report);
        },
      ),
      GoRoute(
        path: '/track',
        name: 'track',
        builder: (context, state) => const TrackEntryScreen(),
      ),
      GoRoute(
        path: '/report-detail/:uuid',
        name: 'report-detail',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;
          return ReportDetailScreen(uuid: uuid);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
  path: '/verify-email',
  name: 'verify-email',
  builder: (context, state) {
    final email = state.uri.queryParameters['email'] ?? '';
    return VerifyEmailScreen(email: email);
  },
),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
    ],
  );
}
