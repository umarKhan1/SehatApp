import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sehatapp/core/config/screenutil_config.dart';
import 'package:sehatapp/core/constants/app_strings.dart';
import 'package:sehatapp/core/localization/app_locale_cubit.dart';
import 'package:sehatapp/core/providers/app_providers.dart';
import 'package:sehatapp/core/router/app_router.dart';
import 'package:sehatapp/core/theme/app_theme.dart';
import 'package:sehatapp/core/widgets/network_status_banner.dart';
import 'package:sehatapp/features/call/presentation/widgets/call_listener.dart';
import 'package:sehatapp/firebase_options.dart';
import 'package:sehatapp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // ignore: avoid_redundant_argument_values
  await dotenv.load(fileName: '.env');

  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('app_locale_code') ?? 'en';
  final initialLocale = Locale(code);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Check if user should stay logged in
  // If not explicitly set, sign out to prevent auto-login from cached credentials
  final stayLoggedIn = prefs.getBool('stay_logged_in') ?? false;
  if (!stayLoggedIn) {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('[Main] Signed out user - no active session flag');
    } catch (e) {
      debugPrint('[Main] Error signing out: $e');
    }
  }

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
              debugShowCheckedModeBanner: false,
              darkTheme: AppTheme.light,
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
              builder: (context, child) {
                return NetworkStatusBanner(
                  child: CallListener(child: child ?? const SizedBox.shrink()),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
