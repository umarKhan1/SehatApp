import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/constants/app_images.dart';
import 'package:sehatapp/core/constants/app_strings.dart';
import 'package:sehatapp/features/splash/bloc/splash_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Ensure listeners are mounted before first emission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SplashCubit>().start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashFinished) {
          context.goNamed('onboarding');
        }
      },
      child: Scaffold(
        body: Center(
          child: BlocBuilder<SplashCubit, SplashState>(
            builder: (context, state) {
              final double opacity = state is SplashFadingIn ? 1.0 : 0.0;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeIn,
                opacity: opacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppImages.logo,
                      width: 150.w,
                      height: 150.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      AppStrings.splashTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}