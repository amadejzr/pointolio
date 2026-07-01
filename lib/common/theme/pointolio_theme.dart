import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
/// Pointolio - Notebook / Slate theme
/// The single source of truth. NOTHING hardcodes a colour;
/// widgets read everything from `context.pt` (this extension).
/// ============================================================
@immutable
class PointolioTheme extends ThemeExtension<PointolioTheme> {
  const PointolioTheme({
    required this.bg,
    required this.ruledLine,
    required this.marginLine,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.text2,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.accentText,
    required this.accentTint,
    required this.accentBorder,
    required this.accentDeep,
    required this.players,
    required this.onPlayer,
    required this.shadowCard,
    required this.shadowFloat,
    required this.shadowAccent,
    required this.shadowDevice,
  });

  // surfaces
  final Color bg;
  final Color ruledLine;
  final Color marginLine;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceSunken;
  final Color border;
  final Color borderStrong;
  // ink
  final Color text;
  final Color text2;
  final Color textMuted;
  final Color textFaint;
  // accent
  final Color accent;
  final Color accentText;
  final Color accentTint;
  final Color accentBorder;
  final Color accentDeep;
  // player hues (one per person) + label colour on top
  final List<Color> players;
  final Color onPlayer;
  // shadows
  final List<BoxShadow> shadowCard;
  final List<BoxShadow> shadowFloat;
  final List<BoxShadow> shadowAccent;
  final List<BoxShadow> shadowDevice;

  /// Player hue by index (wraps around).
  Color playerColor(int index) => players[index % players.length];

  // ---------------------------------------------------------- LIGHT
  static const light = PointolioTheme(
    bg: Color(0xFFF7F8FB),
    ruledLine: Color(0xFFE3E9F4),
    marginLine: Color(0x47D47878), // rgba(212,120,120,.28)
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEF0F3),
    surfaceSunken: Color(0xFFF4F6FA),
    border: Color(0xFFE6E9F0),
    borderStrong: Color(0xFFE2E5EC),
    text: Color(0xFF1B1E26),
    text2: Color(0xFF3A3E49),
    textMuted: Color(0xFF9297A5),
    textFaint: Color(0xFFC2C6D0),
    accent: Color(0xFF2F6BF6),
    accentText: Color(0xFFFFFFFF),
    accentTint: Color(0xFFEAF0FF),
    accentBorder: Color(0xFFCDDCFF),
    accentDeep: Color(0xFF1E4FD0),
    players: _players,
    onPlayer: Color(0xFFFFFFFF),
    shadowCard: [
      BoxShadow(
        color: Color(0x2814183C),
        blurRadius: 26,
        spreadRadius: -18,
        offset: Offset(0, 12),
      ),
    ],
    shadowFloat: [
      BoxShadow(
        color: Color(0x2314183C),
        blurRadius: 32,
        spreadRadius: -10,
        offset: Offset(0, 12),
      ),
    ],
    shadowAccent: [
      BoxShadow(
        color: Color(0x8C2F6BF6),
        blurRadius: 28,
        spreadRadius: -8,
        offset: Offset(0, 14),
      ),
    ],
    shadowDevice: [
      BoxShadow(
        color: Color(0x3814183C),
        blurRadius: 55,
        spreadRadius: -24,
        offset: Offset(0, 28),
      ),
    ],
  );

  // ---------------------------------------------------------- DARK
  static const dark = PointolioTheme(
    bg: Color(0xFF0E1016),
    ruledLine: Color(0xFF1B1F28),
    marginLine: Color(0x38D47878),
    surface: Color(0xFF171A21),
    surfaceMuted: Color(0xFF1F232C),
    surfaceSunken: Color(0xFF141821),
    border: Color(0xFF262A34),
    borderStrong: Color(0xFF2F3542),
    text: Color(0xFFEEF0F4),
    text2: Color(0xFFC4C8D2),
    textMuted: Color(0xFF8A90A0),
    textFaint: Color(0xFF5D616C),
    accent: Color(0xFF4F86FF),
    accentText: Color(0xFF0E1016),
    accentTint: Color(0x214F86FF),
    accentBorder: Color(0x664F86FF),
    accentDeep: Color(0xFF7FA8FF),
    players: _players,
    onPlayer: Color(0xFFFFFFFF),
    shadowCard: [
      BoxShadow(
        color: Color(0xB3000000),
        blurRadius: 26,
        spreadRadius: -18,
        offset: Offset(0, 12),
      ),
    ],
    shadowFloat: [
      BoxShadow(
        color: Color(0x8C000000),
        blurRadius: 32,
        spreadRadius: -10,
        offset: Offset(0, 12),
      ),
    ],
    shadowAccent: [
      BoxShadow(
        color: Color(0x734F86FF),
        blurRadius: 28,
        spreadRadius: -8,
        offset: Offset(0, 14),
      ),
    ],
    shadowDevice: [
      BoxShadow(
        color: Color(0xB3000000),
        blurRadius: 55,
        spreadRadius: -24,
        offset: Offset(0, 28),
      ),
    ],
  );

  static const List<Color> _players = [
    Color(0xFF4661D8), // indigo
    Color(0xFF2F9E8F), // teal
    Color(0xFFE0A23A), // amber
    Color(0xFFD05A7A), // rose
    Color(0xFF6C5CC4), // violet
    Color(0xFF3F9E6A), // green
  ];

  @override
  PointolioTheme copyWith({
    Color? bg,
    Color? ruledLine,
    Color? marginLine,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceSunken,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? text2,
    Color? textMuted,
    Color? textFaint,
    Color? accent,
    Color? accentText,
    Color? accentTint,
    Color? accentBorder,
    Color? accentDeep,
    List<Color>? players,
    Color? onPlayer,
    List<BoxShadow>? shadowCard,
    List<BoxShadow>? shadowFloat,
    List<BoxShadow>? shadowAccent,
    List<BoxShadow>? shadowDevice,
  }) {
    return PointolioTheme(
      bg: bg ?? this.bg,
      ruledLine: ruledLine ?? this.ruledLine,
      marginLine: marginLine ?? this.marginLine,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      accent: accent ?? this.accent,
      accentText: accentText ?? this.accentText,
      accentTint: accentTint ?? this.accentTint,
      accentBorder: accentBorder ?? this.accentBorder,
      accentDeep: accentDeep ?? this.accentDeep,
      players: players ?? this.players,
      onPlayer: onPlayer ?? this.onPlayer,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowFloat: shadowFloat ?? this.shadowFloat,
      shadowAccent: shadowAccent ?? this.shadowAccent,
      shadowDevice: shadowDevice ?? this.shadowDevice,
    );
  }

  @override
  PointolioTheme lerp(ThemeExtension<PointolioTheme>? other, double t) {
    if (other is! PointolioTheme) return this;
    List<Color> lerpList(List<Color> a, List<Color> b) =>
        List.generate(a.length, (i) => Color.lerp(a[i], b[i], t)!);
    return PointolioTheme(
      bg: Color.lerp(bg, other.bg, t)!,
      ruledLine: Color.lerp(ruledLine, other.ruledLine, t)!,
      marginLine: Color.lerp(marginLine, other.marginLine, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      accentBorder: Color.lerp(accentBorder, other.accentBorder, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      players: lerpList(players, other.players),
      onPlayer: Color.lerp(onPlayer, other.onPlayer, t)!,
      shadowCard: BoxShadow.lerpList(shadowCard, other.shadowCard, t)!,
      shadowFloat: BoxShadow.lerpList(shadowFloat, other.shadowFloat, t)!,
      shadowAccent: BoxShadow.lerpList(shadowAccent, other.shadowAccent, t)!,
      shadowDevice: BoxShadow.lerpList(shadowDevice, other.shadowDevice, t)!,
    );
  }

  /// Build a ready-to-use ThemeData for MaterialApp.
  static ThemeData themeData(Brightness brightness) {
    final ext = brightness == Brightness.dark ? dark : light;
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: ext.bg,
      textTheme: GoogleFonts.hankenGroteskTextTheme(base.textTheme).apply(
        bodyColor: ext.text,
        displayColor: ext.text,
      ),
      extensions: [ext],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}

/// `context.pt` - grab the theme anywhere.
extension PointolioContext on BuildContext {
  PointolioTheme get pt => Theme.of(this).extension<PointolioTheme>()!;
}
