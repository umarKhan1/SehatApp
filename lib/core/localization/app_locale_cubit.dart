import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleCubit extends Cubit<Locale> {
  AppLocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }
  AppLocaleCubit.withInitial(super.initial);

  static const _key = 'app_locale_code';

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) {
      emit(Locale(code));
    }
  }

  static Future<Locale> getSavedOrDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    return Locale(code);
  }
}
