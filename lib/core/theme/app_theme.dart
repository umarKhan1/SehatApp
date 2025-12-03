import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Colors.red;

  static ThemeData get light {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.white,
      
      textTheme: GoogleFonts.poppinsTextTheme(),
      popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(Colors.white)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
    return base.copyWith(
      primaryTextTheme: GoogleFonts.poppinsTextTheme(base.primaryTextTheme),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(Colors.white)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
    return base.copyWith(
      primaryTextTheme: GoogleFonts.poppinsTextTheme(base.primaryTextTheme),
    );
  }
}
