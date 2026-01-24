import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ===== Light palette (your current) =====
  static const _primary = Color(0xFF1D4ED8); // Blue 700
  static const _secondary = Color(0xFF06B6D4); // Cyan 500
  static const _surface = Color(0xFFF6F8FC);
  static const _card = Color(0xFFFFFFFF);
  static const _outline = Color(0xFFE2E8F0);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF475569);

  // ===== Dark palette (new) =====
  static const _dPrimary = Color(0xFF60A5FA); // Blue 400 (readable on dark)
  static const _dSecondary = Color(0xFF22D3EE); // Cyan 400
  static const _dSurface = Color(0xFF0B1220); // deep navy (not pure black)
  static const _dCard = Color(0xFF0F1A2B); // slightly lifted surface
  static const _dOutline = Color(0xFF24344D); // subtle border
  static const _dText = Color(0xFFE5E7EB); // near-white
  static const _dMuted = Color(0xFF9CA3AF); // gray 400
  static const _dError = Color(0xFFF87171); // red 400

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Color(0xFF062A2E),
      error: Color(0xFFDC2626),
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
      inversePrimary: Color(0xFF93C5FD),
    );

    const r12 = BorderRadius.all(Radius.circular(12));
    const r16 = BorderRadius.all(Radius.circular(16));
    const r18 = BorderRadius.all(Radius.circular(18));

    return ThemeData(
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: r12,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.9),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        textStyle: Typography.material2021().black.bodySmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 400),
        showDuration: const Duration(seconds: 3),
      ),
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      textTheme: Typography.material2021().black.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: _text,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: _text),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 6,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: r16,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.9),
          ),
        ),
        textStyle: Typography.material2021().black.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: _card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: r18,
          side: BorderSide(color: _outline.withValues(alpha: 0.9)),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: _outline.withValues(alpha: 0.9),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: r16),
        iconColor: _muted,
        textColor: _text,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
        border: const OutlineInputBorder(
          borderRadius: r16,
          borderSide: BorderSide(color: _outline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: r16,
          borderSide: BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: r16,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
        backgroundColor: const Color(0xFFEFF6FF),
        selectedColor: colorScheme.primary.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: _text, fontWeight: FontWeight.w600),
        side: const BorderSide(color: _outline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _text,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: r16),
      ),
    );
  }

  // ========================= DARK THEME (new) =========================

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _dPrimary,
      onPrimary: Color(0xFF061423), // deep navy text on light-blue buttons
      secondary: _dSecondary,
      onSecondary: Color(0xFF042024),
      error: _dError,
      onError: Color(0xFF1A0B0B),

      surface: _dSurface,
      onSurface: _dText,
      surfaceContainerHighest: _dCard,

      outline: _dOutline,
      outlineVariant: _dOutline,

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _dText,
      onInverseSurface: Color(0xFF0B1220),
      inversePrimary: Color(0xFF1D4ED8),
    );

    const r12 = BorderRadius.all(Radius.circular(12));
    const r16 = BorderRadius.all(Radius.circular(16));
    const r18 = BorderRadius.all(Radius.circular(18));

    return ThemeData(
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _dCard,
          borderRadius: r12,
          border: Border.all(
            color: _dOutline.withValues(alpha: 0.9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        textStyle: Typography.material2021().white.bodySmall?.copyWith(
          color: _dText,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 400),
        showDuration: const Duration(seconds: 3),
      ),
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Typography
      textTheme: Typography.material2021().white.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: _dText,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: _dText),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 8,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.35),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: r16,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.9),
          ),
        ),
        textStyle: Typography.material2021().white.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards / Surfaces
      cardTheme: CardThemeData(
        elevation: 0,
        color: _dCard,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: r18,
          side: BorderSide(color: _dOutline.withValues(alpha: 0.9)),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: _dOutline.withValues(alpha: 0.9),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: r16),
        iconColor: _dMuted,
        textColor: _dText,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: r18),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _dCard,
        hintStyle: const TextStyle(color: _dMuted),
        labelStyle: const TextStyle(color: _dMuted),
        border: const OutlineInputBorder(
          borderRadius: r16,
          borderSide: BorderSide(color: _dOutline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: r16,
          borderSide: BorderSide(color: _dOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: r16,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Buttons
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
          side: const BorderSide(color: _dOutline),
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
        backgroundColor: const Color(0xFF0D1B2D),
        selectedColor: colorScheme.primary.withValues(alpha: 0.18),
        labelStyle: const TextStyle(color: _dText, fontWeight: FontWeight.w600),
        side: const BorderSide(color: _dOutline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF0F172A),
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: r16),
      ),
    );
  }
}
