import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/localization/app_locale_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
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
