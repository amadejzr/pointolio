import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';
import 'package:pointolio/features/scoring/presentation/widgets/calculator_keyboard/calculator_keyboard_exports.dart';
import 'package:pointolio/features/scoring/presentation/widgets/score_table.dart';

/// Bottom sheet to enter one round of scores. Notebook-themed chrome around the
/// calculator keyboard field the user likes - one row per player, in the same
/// order as the table so entry follows the seating order.
class AddRoundSheet extends StatefulWidget {
  const AddRoundSheet({required this.state, required this.onSave, super.key});

  final ScoringState state;
  final FutureOr<void> Function(Map<int, int> scores) onSave;

  @override
  State<AddRoundSheet> createState() => _AddRoundSheetState();
}

class _AddRoundSheetState extends State<AddRoundSheet> {
  late final Map<int, TextEditingController> _controllers;
  late final Map<int, FocusNode> _focusNodes;
  late final ScrollController _scrollController;
  bool _isAnyFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controllers = {
      for (final ps in widget.state.playerScores)
        ps.gamePlayer.id: TextEditingController(),
    };
    _focusNodes = {
      for (final ps in widget.state.playerScores) ps.gamePlayer.id: FocusNode(),
    };
    for (final entry in _focusNodes.entries) {
      entry.value.addListener(() => _onFieldFocusChanged(entry.key));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onFieldFocusChanged(int playerId) {
    final hasFocus = _focusNodes[playerId]?.hasFocus ?? false;
    setState(() => _isAnyFieldFocused = hasFocus);
    if (hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFocusedField(playerId);
      });
    }
  }

  void _scrollToFocusedField(int playerId) {
    // Layout-agnostic: scroll the focused field into the viewport (which the
    // AnimatedPadding already shrinks to sit above the keyboard). Works for the
    // single-column portrait layout and the two-column landscape grid alike.
    final fieldContext = _focusNodes[playerId]?.context;
    if (fieldContext == null) return;

    unawaited(
      Scrollable.ensureVisible(
        fieldContext,
        alignment: 0.5,
        duration: Motion.slow,
        curve: Motion.ease,
      ),
    );
  }

  Future<void> _saveRound() async {
    final scores = <int, int>{};
    for (final e in _controllers.entries) {
      scores[e.key] = int.tryParse(e.value.text.trim()) ?? 0;
    }
    await widget.onSave(scores);
  }

  void _reset() {
    for (final c in _controllers.values) {
      c.clear();
    }
    setState(() {});
  }

  Widget _buildInputRow(PointolioTheme pt, int index) {
    final players = widget.state.playerScores;
    final ps = players[index];
    return _PlayerInputRow(
      key: ValueKey(ps.gamePlayer.id),
      controller: _controllers[ps.gamePlayer.id]!,
      focusNode: _focusNodes[ps.gamePlayer.id],
      name: ScoreTable.fullName(ps.player),
      initials: ScoreTable.initials(ps.player),
      color: ps.player.color != null
          ? Color(ps.player.color!)
          : pt.playerColor(index),
      autofocus: index == 0,
      isLast: index == players.length - 1,
      onFocusChanged: () => _onFieldFocusChanged(ps.gamePlayer.id),
      onSubmittedLast: _saveRound,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final roundNumber = widget.state.roundCount + 1;
    final keyboardHeight = getCalculatorKeyboardHeight(context);
    final players = widget.state.playerScores;
    // Landscape phones are short and wide: use two columns so the inputs stay
    // compact above the keyboard instead of a tall single-column list.
    final columns =
        MediaQuery.orientationOf(context) == Orientation.landscape ? 2 : 1;

    final bottomPadding = _isAnyFieldFocused
        ? keyboardHeight + MediaQuery.of(context).padding.bottom
        : MediaQuery.of(context).padding.bottom + S.md;

    return AnimatedPadding(
      duration: Motion.base,
      curve: Motion.ease,
      padding: EdgeInsets.only(
        left: S.lg,
        right: S.lg,
        top: S.lg,
        bottom: bottomPadding,
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: S.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: pt.accentTint,
                    borderRadius: BorderRadius.circular(R.sm),
                  ),
                  child: Text(
                    'R$roundNumber',
                    style: PT.number(pt.accent, size: 14),
                  ),
                ),
                const SizedBox(width: S.sm),
                Text('New round', style: PT.sectionTitle(pt.text)),
                const Spacer(),
                Pressable(
                  onTap: _reset,
                  scale: 0.94,
                  isButton: true,
                  semanticLabel: 'Reset all inputs',
                  excludeChildSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: S.sm,
                      vertical: S.xs,
                    ),
                    child: Text('Reset', style: PT.bodyStrong(pt.textMuted)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: S.md),
            for (var row = 0; row < players.length; row += columns)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var col = 0; col < columns; col++) ...[
                    if (col > 0) const SizedBox(width: S.md),
                    Expanded(
                      child: (row + col) < players.length
                          ? _buildInputRow(pt, row + col)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: S.md),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'Cancel',
                    filled: false,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: S.md),
                Expanded(
                  flex: 2,
                  child: _SheetButton(
                    label: 'Save round',
                    filled: true,
                    onTap: _saveRound,
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

class _PlayerInputRow extends StatelessWidget {
  const _PlayerInputRow({
    required this.controller,
    required this.name,
    required this.initials,
    required this.color,
    required this.autofocus,
    required this.isLast,
    required this.onFocusChanged,
    required this.onSubmittedLast,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String name;
  final String initials;
  final Color color;
  final bool autofocus;
  final bool isLast;
  final VoidCallback onFocusChanged;
  final Future<void> Function() onSubmittedLast;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Padding(
      padding: const EdgeInsets.only(bottom: S.sm),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initials, style: PT.number(pt.onPlayer, size: 13)),
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PT.bodyStrong(pt.text),
            ),
          ),
          const SizedBox(width: S.md),
          SizedBox(
            width: 118,
            child: CalculatorTextField(
              controller: controller,
              focusNode: focusNode,
              onFocusChanged: (_) => onFocusChanged(),
              autofocus: autofocus,
              textInputAction: isLast
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: isLast ? (_) => onSubmittedLast() : null,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: pt.surfaceSunken,
                hintText: '0',
                hintStyle: PT.number(pt.textFaint, size: 16),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: S.md,
                  vertical: S.sm,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(R.sm),
                  borderSide: BorderSide(color: pt.border),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(R.sm),
                  borderSide: BorderSide(color: pt.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(R.sm),
                  borderSide: BorderSide(color: pt.accent, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Pressable(
      onTap: onTap,
      isButton: true,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? pt.accent : pt.surface,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: filled ? pt.accent : pt.border),
          boxShadow: filled ? pt.shadowAccent : null,
        ),
        child: Text(
          label,
          style: PT.bodyStrong(filled ? pt.accentText : pt.text),
        ),
      ),
    );
  }
}
