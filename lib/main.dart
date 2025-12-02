import 'package:flutter/material.dart';
import 'package:sehatapp/core/config/screenutil_config.dart';
import 'package:sehatapp/core/constants/app_strings.dart';
import 'package:sehatapp/core/providers/app_providers.dart';
import 'package:sehatapp/core/router/app_router.dart';
import 'package:sehatapp/core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: ScreenUtilConfig(
        child: MaterialApp.router(
          title: AppStrings.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}

