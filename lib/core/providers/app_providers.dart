import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/localization/app_locale_cubit.dart';
import 'package:sehatapp/core/network/network_status_cubit.dart';
import 'package:sehatapp/core/services/network_service.dart';
import 'package:sehatapp/features/auth/bloc/signup/signup_cubit.dart';
import 'package:sehatapp/features/auth/bloc/validation/login_validation.dart';
import 'package:sehatapp/features/auth/bloc/validation/signup_validation_cubit.dart';
import 'package:sehatapp/features/auth/data/auth_repository.dart';
import 'package:sehatapp/features/auth/data/user_repository.dart';
import 'package:sehatapp/features/blood_request/bloc/blood_request_cubit.dart';
import 'package:sehatapp/features/blood_request/data/blood_request_repository.dart';
import 'package:sehatapp/features/call/data/call_repository_impl.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';
import 'package:sehatapp/features/chat/data/chat_repository.dart';
import 'package:sehatapp/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:sehatapp/features/chat/presentation/cubit/inbox_cubit.dart';
import 'package:sehatapp/features/dashboard/bloc/banner_cubit.dart';
import 'package:sehatapp/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:sehatapp/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:sehatapp/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:sehatapp/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:sehatapp/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:sehatapp/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:sehatapp/features/post_request/bloc/create_post_cubit.dart';
import 'package:sehatapp/features/post_request/data/post_repository.dart';
import 'package:sehatapp/features/profile/bloc/profile_setup_cubit.dart';
import 'package:sehatapp/features/recently_viewed/bloc/recently_viewed_cubit.dart';
import 'package:sehatapp/features/recently_viewed/data/recently_viewed_repository.dart';
import 'package:sehatapp/features/search/bloc/search_cubit.dart';
import 'package:sehatapp/features/search/data/search_repository.dart';
import 'package:sehatapp/features/splash/bloc/splash_cubit.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.child,
    required this.initialLocale,
  });

  final Widget child;
  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final userRepo = UserRepository();
    final postRepo = PostRepository();
    final searchRepo = SearchRepository();
    final chatRepo = ChatRepository();
    final callRepo = CallRepository();
    final notificationRepo = NotificationRepositoryImpl();
    return MultiBlocProvider(
      providers: [
        // Network status monitoring (global)
        BlocProvider<NetworkStatusCubit>(
          create: (_) => NetworkStatusCubit(NetworkService()),
        ),
        BlocProvider<SplashCubit>(create: (_) => SplashCubit()),
        BlocProvider<OnboardingCubit>(create: (_) => OnboardingCubit()),
        BlocProvider<SignupCubit>(
          create: (_) => SignupCubit(auth: authRepo, users: userRepo),
        ),
        BlocProvider<SignupValidationCubit>(
          create: (ctx) => SignupValidationCubit(ctx.read<SignupCubit>()),
        ),
        BlocProvider<LoginValidationCubit>(
          create: (_) => LoginValidationCubit(auth: authRepo, users: userRepo),
        ),
        BlocProvider<ProfileSetupCubit>(
          create: (_) => ProfileSetupCubit(auth: authRepo, users: userRepo),
        ),
        BlocProvider<BannerCubit>(create: (_) => BannerCubit()),
        BlocProvider<CreatePostCubit>(
          create: (_) => CreatePostCubit(repo: postRepo),
        ),
        BlocProvider<AppLocaleCubit>(
          create: (_) => AppLocaleCubit.withInitial(initialLocale),
        ),
        BlocProvider<SearchCubit>(create: (_) => SearchCubit(repo: searchRepo)),
        BlocProvider<BloodRequestCubit>(
          create: (_) => BloodRequestCubit(BloodRequestRepository()),
        ),
        BlocProvider<InboxCubit>(create: (_) => InboxCubit(chatRepo)),
        BlocProvider<ChatCubit>(create: (_) => ChatCubit(chatRepo, userRepo)),
        BlocProvider<CallCubit>(
          create: (_) => CallCubit(callRepo, chatRepo: chatRepo),
        ),
        BlocProvider<NotificationCubit>(
          create: (_) => NotificationCubit(
            getNotificationsUseCase: GetNotificationsUseCase(notificationRepo),
            markNotificationReadUseCase: MarkNotificationReadUseCase(
              notificationRepo,
            ),
            markAllNotificationsReadUseCase: MarkAllNotificationsReadUseCase(
              notificationRepo,
            ),
          ),
        ),
        // Load preview so dashboard shows items
        BlocProvider(
          create: (_) =>
              RecentlyViewedCubit(RecentlyViewedRepository())..loadPreview(),
        ),
      ],
      child: child,
    );
  }
}
