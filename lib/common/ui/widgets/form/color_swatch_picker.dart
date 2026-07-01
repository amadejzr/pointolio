import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// Row of colour swatches from the theme's player palette. The selected one
/// gets a ring. Returns the palette index so it stays theme-driven; store the
/// resolved `pt.playerColor(index).toARGB32()` if you need the raw int.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    required this.selectedIndex,
    required this.onSelect,
    super.key,
    this.count,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  /// How many swatches to show. Defaults to the full palette.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final n = count ?? pt.players.length;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(n, (i) {
        final c = pt.playerColor(i);
        final selected = i == selectedIndex;
        return Pressable(
          onTap: () => onSelect(i),
          scale: 0.88,
          isButton: true,
          selected: selected,
          semanticLabel: 'Colour ${i + 1}',
          excludeChildSemantics: true,
          // 44x44 hit target around a 30px disc.
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: AnimatedContainer(
                duration: Motion.base,
                curve: Motion.ease,
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? c : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
