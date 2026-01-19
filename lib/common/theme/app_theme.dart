import 'package:flutter/material.dart';

class AppTheme {
  // Premium-ish palette: midnight + cyan, soft cool surfaces
  static const _primary = Color(0xFF1D4ED8); // Blue 700 (confident, not childish)
  static const _secondary = Color(0xFF06B6D4); // Cyan 500 (fresh accent)
  static const _surface = Color(0xFFF6F8FC); // cool near-white
  static const _card = Color(0xFFFFFFFF);
  static const _outline = Color(0xFFE2E8F0); // slate-200
  static const _text = Color(0xFF0F172A); // slate-900
  static const _muted = Color(0xFF475569); // slate-600

  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: const Color(0xFF062A2E),
      error: const Color(0xFFDC2626),
      onError: Colors.white,
      surface: _surface,
      onSurface: _text,
      surfaceContainerHighest: _card,
      outline: _outline,
      outlineVariant: _outline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _text,
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF93C5FD),
    );

    const r12 = BorderRadius.all(Radius.circular(12));
    const r16 = BorderRadius.all(Radius.circular(16));
    const r18 = BorderRadius.all(Radius.circular(18));

    return ThemeData(
      popupMenuTheme: PopupMenuThemeData(
  color: colorScheme.surfaceContainerHighest,
  elevation: 6,
  shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
  surfaceTintColor: Colors.transparent, // keeps it “clean” in M3

  shape: RoundedRectangleBorder(
    borderRadius: r16,
    side: BorderSide(
      color: colorScheme.outlineVariant.withValues(alpha: 0.9),
      width: 1,
    ),
  ),
  textStyle: Typography.material2021().black.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
),
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Better-feeling typography without custom fonts
      textTheme: Typography.material2021().black.apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: _text,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: _text),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: _card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: r18,
          side: BorderSide(
            color: _outline.withValues(alpha: 0.9),
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: _outline.withValues(alpha: 0.9),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(borderRadius: r16),
        iconColor: _muted,
        textColor: _text,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: r18),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _card,
        hintStyle: const TextStyle(color: _muted),
        labelStyle: const TextStyle(color: _muted),
        border: OutlineInputBorder(
          borderRadius: r16,
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: r16,
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: r16,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: r16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: r16),
          side: const BorderSide(color: _outline),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: r12),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEFF6FF), // light blue tint
        selectedColor: colorScheme.primary.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: _text, fontWeight: FontWeight.w600),
        side: const BorderSide(color: _outline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),

    snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _text,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: r16),
      ),
    );
  }
}