import 'package:go_router/go_router.dart';
import 'package:sehatapp/features/auth/presentation/pages/login_page.dart';
import 'package:sehatapp/features/auth/presentation/pages/signup_page.dart';
import 'package:sehatapp/features/blood_request/presentation/pages/blood_request_page.dart';
import 'package:sehatapp/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sehatapp/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sehatapp/features/profile/presentation/pages/profile_setup_step1_page.dart';
import 'package:sehatapp/features/profile/presentation/pages/profile_setup_step2_page.dart';
import 'package:sehatapp/features/search/presentation/pages/search_page.dart';
import 'package:sehatapp/features/shell/presentation/pages/shell_page.dart';
import 'package:sehatapp/features/splash/presentation/splash_page.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    // Profile Setup - entry point is step1
    GoRoute(
      path: '/profile/setup/step1',
      name: 'profileSetupStep1',
      builder: (context, state) => const ProfileSetupStep1Page(),
    ),
    GoRoute(
      path: '/profile/setup/step2',
      name: 'profileSetupStep2',
      builder: (context, state) => const ProfileSetupStep2Page(),
    ),
    // Shell with bottom navigation
    GoRoute(
      path: '/shell',
      name: 'shell',
      builder: (context, state) => const ShellPage(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/blood-request',
      name: 'bloodRequest',
      builder: (context, state) {
        final group = state.uri.queryParameters['group'];
        return BloodRequestPage(group: group);
      },
    ),
  ],
);
