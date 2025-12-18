import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/navigation/navigator_service.dart';
import 'package:sehatapp/features/ai_chat/presentation/cubit/ai_chat_cubit.dart';
import 'package:sehatapp/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:sehatapp/features/auth/presentation/pages/login_page.dart';
import 'package:sehatapp/features/auth/presentation/pages/signup_page.dart';
import 'package:sehatapp/features/blood_request/presentation/pages/blood_request_details_page.dart';
import 'package:sehatapp/features/blood_request/presentation/pages/blood_request_page.dart';
import 'package:sehatapp/features/chat/presentation/pages/chat_page.dart';
import 'package:sehatapp/features/chat/presentation/pages/inbox_page.dart';
import 'package:sehatapp/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sehatapp/features/notification/presentation/pages/notification_page.dart';
import 'package:sehatapp/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sehatapp/features/onboarding/presentation/pages/permissions_onboarding_page.dart';
import 'package:sehatapp/features/profile/presentation/pages/profile_setup_step1_page.dart';
import 'package:sehatapp/features/profile/presentation/pages/profile_setup_step2_page.dart';
import 'package:sehatapp/features/recently_viewed/presentation/pages/recently_viewed_page.dart';
import 'package:sehatapp/features/search/presentation/pages/search_page.dart';
import 'package:sehatapp/features/shell/presentation/pages/shell_page.dart';
import 'package:sehatapp/features/splash/presentation/splash_page.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: NavigatorService.navigatorKey,
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
    GoRoute(
      path: '/permissions-onboarding',
      name: 'permissionsOnboarding',
      builder: (context, state) => const PermissionsOnboardingPage(),
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
    GoRoute(
      path: '/blood-request/details',
      name: 'bloodRequestDetails',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return BloodRequestDetailsPage(post: data ?? const {});
      },
    ),
    GoRoute(
      path: '/recently-viewed',
      name: 'recentlyViewed',
      builder: (context, state) => const RecentlyViewedPage(),
    ),
    // Inbox route
    GoRoute(
      path: '/inbox',
      name: 'inbox',
      builder: (context, state) => const InboxPage(),
    ),
    // Chat route expects extra: { 'title': String, 'uid': String }
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final title = extra?['title'] as String? ?? '';
        final uid = extra?['uid'] as String? ?? '';
        return ChatPage(title: title, otherUid: uid);
      },
    ),
    GoRoute(
      path: '/ai-chat',
      name: 'ai-chat',
      builder: (context, state) => BlocProvider(
        create: (context) => AIChatCubit(context),
        child: const AIChatPage(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationPage(),
    ),
  ],
);
