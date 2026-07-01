import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A quiet, one-time coach banner that teaches the table's touch gestures
/// (drag to reorder, tap to edit, tap a round to delete). It shows until the
/// user taps "Got it", then collapses away and never returns (persisted in
/// [SharedPreferences]). Kept deliberately subtle so it reads as help, not
/// noise.
class ScoringHintBanner extends StatefulWidget {
  const ScoringHintBanner({required this.canReorder, super.key});

  /// Whether reordering is possible (2+ players) - tailors the copy.
  final bool canReorder;

  @override
  State<ScoringHintBanner> createState() => _ScoringHintBannerState();
}

class _ScoringHintBannerState extends State<ScoringHintBanner> {
  static const _seenKey = 'scoring_hints_seen';

  late bool _dismissed =
      locator<SharedPreferences>().getBool(_seenKey) ?? false;

  void _dismiss() {
    setState(() => _dismissed = true);
    unawaited(locator<SharedPreferences>().setBool(_seenKey, true));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Motion.base,
      curve: Motion.ease,
      alignment: Alignment.topCenter,
      child: _dismissed
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(S.lg, 0, S.lg, S.sm),
              child: AnimatedEntrance(
                child: _HintCard(
                  canReorder: widget.canReorder,
                  onDismiss: _dismiss,
                ),
              ),
            ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.canReorder, required this.onDismiss});

  final bool canReorder;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final tips = canReorder
        ? 'Drag a player to reorder them. Tap a score to edit, or a round '
              'label to delete it.'
        : 'Tap a score to edit, or a round label to delete it.';

    return Container(
      padding: const EdgeInsets.fromLTRB(S.md, S.sm, S.sm, S.sm),
      decoration: BoxDecoration(
        color: pt.accentTint,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: pt.accentBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              canReorder
                  ? Icons.drag_indicator_rounded
                  : Icons.touch_app_outlined,
              size: 18,
              color: pt.accent,
            ),
          ),
          const SizedBox(width: S.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(tips, style: PT.caption(pt.accentDeep)),
            ),
          ),
          const SizedBox(width: S.xs),
          Pressable(
            onTap: onDismiss,
            scale: 0.94,
            isButton: true,
            semanticLabel: 'Got it, dismiss tips',
            excludeChildSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: S.sm,
                vertical: 4,
              ),
              child: Text(
                'Got it',
                style: PT.bodyStrong(pt.accent).copyWith(fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
