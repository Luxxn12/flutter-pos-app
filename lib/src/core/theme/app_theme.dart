import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const seedColor = Color(0xFF0EA5A4); // Teal Primary

  static final lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      primary: seedColor,
      brightness: Brightness.light,
      surfaceContainerHighest: const Color(0xFFF6F8FA),
    ).copyWith(
      primaryContainer: seedColor,
      secondary: seedColor,
      secondaryContainer: seedColor,
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: seedColor);
        }
        return const IconThemeData(color: Colors.grey);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: seedColor, fontWeight: FontWeight.bold, fontSize: 12);
        }
        return const TextStyle(color: Colors.grey, fontSize: 12);
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: const IconThemeData(color: seedColor),
      unselectedIconTheme: const IconThemeData(color: Colors.grey),
      selectedLabelTextStyle: const TextStyle(color: seedColor, fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      indicatorColor: Colors.transparent,
      labelType: NavigationRailLabelType.all,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent, // Transparent app bar for modern look
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: seedColor, width: 2)),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      primary: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      primaryContainer: seedColor,
      onPrimary: Colors.white,
      onPrimaryContainer: Colors.white,
      secondary: seedColor,
      secondaryContainer: seedColor,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: seedColor, width: 2)),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0F172A),
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: seedColor);
        }
        return const IconThemeData(color: Colors.white70);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: seedColor, fontWeight: FontWeight.bold, fontSize: 12);
        }
        return const TextStyle(color: Colors.white70, fontSize: 12);
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: const Color(0xFF0F172A),
      selectedIconTheme: const IconThemeData(color: seedColor),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      selectedLabelTextStyle: const TextStyle(color: seedColor, fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
      indicatorColor: Colors.transparent,
      labelType: NavigationRailLabelType.all,
    ),
  );
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
