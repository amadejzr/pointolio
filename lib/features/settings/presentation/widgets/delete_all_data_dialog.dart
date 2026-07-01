import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// Notebook/Slate confirmation for wiping every party, player, game and score
/// from the device. Returns true if the user confirmed.
Future<bool> showDeleteAllDataDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => const _DeleteAllDataDialog(),
  );
  return confirmed ?? false;
}

class _DeleteAllDataDialog extends StatelessWidget {
  const _DeleteAllDataDialog();

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final danger = pt.players[3]; // rose

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: S.xl),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(S.xl),
            decoration: BoxDecoration(
              color: pt.surface,
              borderRadius: BorderRadius.circular(R.xl),
              border: Border.all(color: pt.border),
              boxShadow: pt.shadowFloat,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: danger.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever_outlined,
                    size: 26,
                    color: danger,
                  ),
                ),
                const SizedBox(height: S.md),
                Semantics(
                  header: true,
                  child: Text(
                    'Delete all data?',
                    style: PT.sectionTitle(pt.text),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: S.sm),
                Text(
                  'Every party, player, game and score on this device will be '
                  'erased for good. This cannot be undone.',
                  style: PT.caption(pt.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: S.xl),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Cancel',
                        color: pt.text,
                        background: pt.surfaceMuted,
                        onTap: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: S.sm),
                    Expanded(
                      child: _DialogButton(
                        label: 'Delete all',
                        color: pt.onPlayer,
                        background: danger,
                        onTap: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      isButton: true,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(R.md),
        ),
        child: Text(label, style: PT.bodyStrong(color)),
      ),
    );
  }
}
