import 'package:go_router/go_router.dart';
import 'package:sehatapp/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sehatapp/features/splash/presentation/pages/splash_page.dart';

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
  ],
);
