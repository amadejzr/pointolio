import 'package:flutter/widgets.dart';

/// Design spacing tokens used across Scoreio UI.
///
/// Use these instead of raw numbers like `8`, `12`, `16`
/// so spacing stays consistent and easy to tweak.
abstract class Spacing {
  // ===== Base scale =====
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  // ===== Vertical gaps (most common) =====
  static const gap4 = SizedBox(height: xxs);
  static const gap8 = SizedBox(height: xs);
  static const gap12 = SizedBox(height: sm);
  static const gap16 = SizedBox(height: md);
  static const gap24 = SizedBox(height: lg);

  // ===== Horizontal gaps =====
  static const hGap8 = SizedBox(width: xs);
  static const hGap12 = SizedBox(width: sm);
  static const hGap16 = SizedBox(width: md);

  // ===== Common paddings =====
  static const EdgeInsets page = EdgeInsets.all(md);

  static const EdgeInsets horizontalPage = EdgeInsets.symmetric(horizontal: md);

  static const EdgeInsets card = EdgeInsets.all(sm);

  static const EdgeInsets list = EdgeInsets.fromLTRB(md, 0, md, md);

  static const EdgeInsets search = EdgeInsets.fromLTRB(md, 0, md, sm);

  // ===== Bottom sheet specific =====
  static const EdgeInsets sheetHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );

  static const EdgeInsets sheetBottom = EdgeInsets.fromLTRB(md, 0, md, md);
}
