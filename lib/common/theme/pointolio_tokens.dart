import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Non-colour design tokens: radius, spacing, motion.
/// (Colours live in PointolioTheme; nothing here is a colour.)
class R {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double bar = 28;
  static const double pill = 999;
}

class S {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class Motion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve ease = Cubic(0.22, 0.61, 0.36, 1);
}

/// Type ramp. Colour is always passed in from the theme - never baked here.
/// Rule of thumb: numbers => Space Grotesk, sentences => Hanken Grotesk.
class PT {
  static TextStyle screenTitle(Color c) => GoogleFonts.spaceGrotesk(
    fontSize: 25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: c,
  );
  static TextStyle sectionTitle(Color c) => GoogleFonts.spaceGrotesk(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: c,
  );
  static TextStyle cardTitle(Color c) => GoogleFonts.hankenGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: c,
  );
  static TextStyle body(Color c) => GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: c,
  );
  static TextStyle bodyStrong(Color c) => GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: c,
  );
  static TextStyle label(Color c) => GoogleFonts.hankenGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: c,
  );
  static TextStyle caption(Color c) => GoogleFonts.hankenGrotesk(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: c,
  );
  static TextStyle tab(Color c) => GoogleFonts.hankenGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: c,
  );
  static TextStyle chip(Color c) => GoogleFonts.hankenGrotesk(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    color: c,
  );
  static TextStyle number(
    Color c, {
    double size = 17,
    FontWeight weight = FontWeight.w700,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: -0.3,
    color: c,
  );
}
