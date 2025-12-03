import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sehatapp/core/config/screenutil_config.dart';
import 'package:sehatapp/core/constants/app_strings.dart';
import 'package:sehatapp/core/localization/app_locale_cubit.dart';
import 'package:sehatapp/core/providers/app_providers.dart';
import 'package:sehatapp/core/router/app_router.dart';
import 'package:sehatapp/core/theme/app_theme.dart';
import 'package:sehatapp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('app_locale_code') ?? 'en';
  final initialLocale = Locale(code);
  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialLocale});
  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      initialLocale: initialLocale,
      child: ScreenUtilConfig(
        child: BlocBuilder<AppLocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              title: AppStrings.appName,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              routerConfig: appRouter,
              locale: locale,
              supportedLocales: const [
                Locale('en'), 
                Locale('hi'), 
                Locale('ar'),
                Locale('ur'),
              ],
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}

