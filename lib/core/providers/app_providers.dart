import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/localization/app_locale_cubit.dart';
import 'package:sehatapp/features/auth/bloc/validation/login_validation.dart';
import 'package:sehatapp/features/auth/bloc/validation/signup_validation_cubit.dart';
import 'package:sehatapp/features/dashboard/bloc/banner_cubit.dart';
import 'package:sehatapp/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:sehatapp/features/profile/bloc/profile_setup_cubit.dart';
import 'package:sehatapp/features/splash/bloc/splash_cubit.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child, required this.initialLocale});

  final Widget child;
  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashCubit>(create: (_) => SplashCubit()),
        BlocProvider<OnboardingCubit>(create: (_) => OnboardingCubit()),
        BlocProvider<LoginValidationCubit>(create: (_) => LoginValidationCubit()),
        BlocProvider<SignupValidationCubit>(create: (_) => SignupValidationCubit()),
        BlocProvider<ProfileSetupCubit>(create: (_) => ProfileSetupCubit()),
        BlocProvider<BannerCubit>(create: (_) => BannerCubit()),
        BlocProvider<AppLocaleCubit>(create: (_) => AppLocaleCubit.withInitial(initialLocale)),
      ],
      child: child,
    );
  }
}
