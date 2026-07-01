import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';

/// Reusable ruled-notebook background. Paints the paper fill, faint horizontal
/// rules, and the soft red margin line. Put it behind any screen:
///
/// ```dart
/// Stack(
///   children: [
///     const Positioned.fill(child: NotebookBackground()),
///     content,
///   ],
/// )
/// ```
class NotebookBackground extends StatelessWidget {
  const NotebookBackground({
    super.key,
    this.ruleGap = 33,
    this.marginX = 32,
    this.topOffset = 0,
    this.child,
  });

  /// Vertical distance between ruled lines.
  final double ruleGap;

  /// X position of the margin line.
  final double marginX;

  /// Where the ruling begins from the top (keeps it off the status bar).
  final double topOffset;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return CustomPaint(
      painter: _NotebookPainter(
        paper: pt.bg,
        line: pt.ruledLine,
        margin: pt.marginLine,
        ruleGap: ruleGap,
        marginX: marginX,
        topOffset: topOffset,
      ),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _NotebookPainter extends CustomPainter {
  _NotebookPainter({
    required this.paper,
    required this.line,
    required this.margin,
    required this.ruleGap,
    required this.marginX,
    required this.topOffset,
  });

  final Color paper;
  final Color line;
  final Color margin;
  final double ruleGap;
  final double marginX;
  final double topOffset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);

    final rule = Paint()
      ..color = line
      ..strokeWidth = 1.5;
    for (var y = topOffset + ruleGap; y < size.height; y += ruleGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }

    final marginPaint = Paint()
      ..color = margin
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(_NotebookPainter old) =>
      old.paper != paper ||
      old.line != line ||
      old.margin != margin ||
      old.ruleGap != ruleGap ||
      old.marginX != marginX ||
      old.topOffset != topOffset;
}
