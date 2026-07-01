import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// One option in a [SegmentedControl].
class SegmentOption<T> {
  const SegmentOption(this.value, this.label);

  final T value;
  final String label;
}

/// A reusable segmented control (the sliding "pill" toggle). Generic over the
/// value type - use it for win rule, theme mode, anything with 2-3 options.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final n = options.length;
    final selectedIndex = options.indexWhere((o) => o.value == value);
    final index = selectedIndex < 0 ? 0 : selectedIndex;
    // Fractional x-alignment for the sliding pill: -1 (first) .. 1 (last).
    final indicatorX = n == 1 ? 0.0 : -1 + 2 * index / (n - 1);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: pt.surfaceMuted,
        borderRadius: BorderRadius.circular(R.md),
      ),
      child: SizedBox(
        height: 44,
        child: Stack(
          children: [
            // A single indicator that slides between segments - no cross-fade,
            // so the toggle reads as one clean motion instead of a flicker.
            Positioned.fill(
              child: AnimatedAlign(
                duration: Motion.base,
                curve: Motion.ease,
                alignment: Alignment(indicatorX, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / n,
                  heightFactor: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: pt.surface,
                      borderRadius: BorderRadius.circular(R.sm),
                      boxShadow: [
                        BoxShadow(
                          color: pt.text.withValues(alpha: 0.12),
                          blurRadius: 8,
                          spreadRadius: -3,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final o in options)
                  Expanded(
                    child: Pressable(
                      onTap: () => onChanged(o.value),
                      scale: 0.97,
                      isButton: true,
                      selected: o.value == value,
                      semanticLabel: o.label,
                      excludeChildSemantics: true,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: Motion.base,
                          curve: Motion.ease,
                          style: o.value == value
                              ? PT.bodyStrong(pt.text).copyWith(fontSize: 13.5)
                              : PT.bodyStrong(pt.textMuted).copyWith(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                          child: Text(o.label),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
