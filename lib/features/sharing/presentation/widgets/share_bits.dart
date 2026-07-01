import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/features/sharing/presentation/cubit/share_editor_cubit.dart';

/// Small circular player disc for share cards. Self-contained (colours are
/// passed in) so it rasterises identically off-screen.
class ShareAvatar extends StatelessWidget {
  const ShareAvatar({
    required this.initial,
    required this.color,
    this.size = 74,
    this.ring = Colors.transparent,
    super.key,
  });

  final String initial;
  final Color color;
  final double size;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: ring == Colors.transparent
            ? null
            : Border.all(color: ring, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: PT.number(Colors.white, size: size * 0.4),
      ),
    );
  }
}

/// The Pointolio wordmark for the card footer - the light logo lockup, sized
/// for the dark share card.
class ShareWatermark extends StatelessWidget {
  const ShareWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/wordmark/pointolio-wordmark-light-transparent.png',
      height: 16,
    );
  }
}

/// Horizontal segmented chip row used for the style + background pickers.
class PickerChips extends StatelessWidget {
  const PickerChips({
    required this.labels,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final on = i == selected;
          return Pressable(
            onTap: () => onSelect(i),
            scale: 0.94,
            semanticLabel: labels[i],
            isButton: true,
            selected: on,
            excludeChildSemantics: true,
            child: AnimatedContainer(
              duration: Motion.fast,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? pt.accent : pt.surface,
                borderRadius: BorderRadius.circular(R.pill),
                border: Border.all(color: on ? pt.accent : pt.border),
              ),
              child: Text(
                labels[i],
                style: PT
                    .bodyStrong(on ? pt.accentText : pt.text2)
                    .copyWith(fontSize: 13),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Transparency slider - the "little transparency" control. Right = more
/// see-through. Values run [kMinShareOpacity]..[kMaxShareOpacity].
class TransparencySlider extends StatelessWidget {
  const TransparencySlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    const span = kMaxShareOpacity - kMinShareOpacity;
    final pct = ((kMaxShareOpacity - value) / span * 100).round();
    return Row(
      children: [
        Icon(Icons.opacity_rounded, size: 16, color: pt.textMuted),
        const SizedBox(width: 4),
        Text(
          'Transparency',
          style: PT.bodyStrong(pt.text2).copyWith(fontSize: 13),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: pt.accent,
              inactiveTrackColor: pt.surfaceMuted,
              thumbColor: pt.accent,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            // Invert so dragging right makes the card more see-through.
            child: Slider(
              value: kMaxShareOpacity - value + kMinShareOpacity,
              min: kMinShareOpacity,
              onChanged: (v) =>
                  onChanged(kMaxShareOpacity - v + kMinShareOpacity),
            ),
          ),
        ),
        SizedBox(
          width: 34,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: PT.number(pt.textMuted, size: 12),
          ),
        ),
      ],
    );
  }
}
