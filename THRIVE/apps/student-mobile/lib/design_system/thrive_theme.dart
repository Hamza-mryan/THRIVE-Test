import 'package:flutter/material.dart';

abstract final class ThriveColors {
  static const navy = Color(0xFF183F42);
  static const teal = Color(0xFF096B5D);
  static const mint = Color(0xFFE0F1E8);
  static const canvas = Color(0xFFF4F7F5);
  static const muted = Color(0xFF506B66);
  static const border = Color(0xFFD5E2DC);
  static const controlBorder = Color(0xFF718A7F);
  static const softSurface = Color(0xFFEDF4F0);
  static const errorSurface = Color(0xFFFFEEEC);
  static const urgent = Color(0xFFAE3E39);
  static const sky = Color(0xFFE8F1FC);
  static const lavender = Color(0xFFEFEBFA);
  static const apricot = Color(0xFFFFF0DD);
  static const coral = Color(0xFFE8A38A);
  static const checkInk = Color(0xFF255F91);
  static const guideInk = Color(0xFF206E57);
  static const connectInk = Color(0xFF785622);
  static const plusInk = Color(0xFF665089);
}

abstract final class ThriveSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class ThriveLayout {
  static const workspaceWidth = 900.0;
  static const heroRadius = 26.0;
  static const actionRadius = 16.0;
}

ThemeData thriveTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: ThriveColors.teal,
    primary: ThriveColors.teal,
    secondary: ThriveColors.navy,
    surface: Colors.white,
    primaryContainer: ThriveColors.mint,
    onPrimaryContainer: ThriveColors.navy,
    outline: ThriveColors.controlBorder,
    outlineVariant: ThriveColors.border,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ThriveColors.canvas,
    fontFamily: 'NotoSansArabic',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        height: 1.45,
        fontWeight: FontWeight.w700,
        color: ThriveColors.navy,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.6,
        fontWeight: FontWeight.w700,
        color: ThriveColors.navy,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.6,
        fontWeight: FontWeight.w700,
        color: ThriveColors.navy,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        height: 1.5,
        fontWeight: FontWeight.w700,
        color: ThriveColors.navy,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        height: 1.6,
        fontWeight: FontWeight.w700,
        color: ThriveColors.navy,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        height: 1.6,
        fontWeight: FontWeight.w600,
        color: ThriveColors.navy,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.8, color: ThriveColors.navy),
      bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.8,
        color: ThriveColors.muted,
      ),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.8,
        color: ThriveColors.muted,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        height: 1.6,
        fontWeight: FontWeight.w600,
        color: ThriveColors.muted,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ThriveColors.canvas,
      scrolledUnderElevation: 0,
      toolbarHeight: 76,
      titleTextStyle: TextStyle(
        fontFamily: 'NotoSansArabic',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ThriveColors.navy,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      height: 78,
      indicatorColor: ThriveColors.mint,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'NotoSansArabic',
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? ThriveColors.teal
              : ThriveColors.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 23,
          color: states.contains(WidgetState.selected)
              ? ThriveColors.teal
              : ThriveColors.muted,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: ThriveColors.controlBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: ThriveColors.controlBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: ThriveColors.teal, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: ThriveColors.mint,
      side: const BorderSide(color: ThriveColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ThriveColors.teal,
      linearTrackColor: ThriveColors.mint,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: ThriveColors.border),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    dividerTheme: const DividerThemeData(color: ThriveColors.border),
  );
}
