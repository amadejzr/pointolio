import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/features/scoring/presentation/widgets/calculator_keyboard/calculator_keyboard_exports.dart';

/// Notebook-themed dialog to edit a single score cell, backed by the calculator
/// keyboard. Returns the new points, or null on cancel.
Future<int?> editPointsDialog(
  BuildContext context, {
  required int current,
  required String playerName,
  required int round,
}) {
  return showDialog<int>(
    barrierDismissible: false,
    context: context,
    builder: (_) => _EditPointsDialog(
      current: current,
      playerName: playerName,
      round: round,
    ),
  );
}

class _EditPointsDialog extends StatefulWidget {
  const _EditPointsDialog({
    required this.current,
    required this.playerName,
    required this.round,
  });

  final int current;
  final String playerName;
  final int round;

  @override
  State<_EditPointsDialog> createState() => _EditPointsDialogState();
}

class _EditPointsDialogState extends State<_EditPointsDialog> {
  late final TextEditingController _controller;
  bool _isFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final v = int.tryParse(_controller.text.trim());
    if (v != null) Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Dialog(
      backgroundColor: pt.surface,
      insetPadding: EdgeInsets.only(
        left: S.lg,
        right: S.lg,
        top: S.lg,
        bottom: _isFieldFocused
            ? getCalculatorKeyboardHeight(context) + S.lg
            : MediaQuery.of(context).viewInsets.bottom + S.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.lg),
        side: BorderSide(color: pt.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(S.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit points', style: PT.sectionTitle(pt.text)),
            const SizedBox(height: 2),
            Text(
              '${widget.playerName} · Round ${widget.round}',
              style: PT.caption(pt.textMuted),
            ),
            const SizedBox(height: S.md),
            CalculatorTextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFocusChanged: (hasFocus) =>
                  setState(() => _isFieldFocused = hasFocus),
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: pt.surfaceSunken,
                hintText: 'e.g. 10, -2',
                hintStyle: PT.body(pt.textFaint),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: S.md,
                  vertical: S.md,
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
            const SizedBox(height: S.md),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: S.md),
                Expanded(
                  child: _DialogButton(
                    label: 'Save',
                    filled: true,
                    onTap: _save,
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

/// Notebook-themed confirm dialog for deleting a whole round.
Future<bool> confirmDeleteRound(
  BuildContext context, {
  required int round,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final pt = context.pt;
      return Dialog(
        backgroundColor: pt.surface,
        insetPadding: const EdgeInsets.all(S.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.lg),
          side: BorderSide(color: pt.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(S.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete round $round?', style: PT.sectionTitle(pt.text)),
              const SizedBox(height: S.xs),
              Text(
                "This removes every player's score for round $round.",
                style: PT.body(pt.textMuted),
              ),
              const SizedBox(height: S.lg),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: S.md),
                  Expanded(
                    child: _DialogButton(
                      label: 'Delete',
                      destructive: true,
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final Color bg;
    final Color fg;
    final Color border;
    if (destructive) {
      bg = pt.players[3];
      fg = pt.onPlayer;
      border = pt.players[3];
    } else if (filled) {
      bg = pt.accent;
      fg = pt.accentText;
      border = pt.accent;
    } else {
      bg = pt.surface;
      fg = pt.text;
      border = pt.border;
    }

    return Pressable(
      onTap: onTap,
      isButton: true,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: border),
        ),
        child: Text(label, style: PT.bodyStrong(fg)),
      ),
    );
  }
}
