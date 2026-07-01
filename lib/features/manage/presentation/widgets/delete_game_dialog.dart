import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// Notebook/Slate delete confirmation for a saved game. Crosses the game name
/// out (like striking an entry from the book) and asks to confirm. Returns true
/// if the user confirmed deletion.
Future<bool> showDeleteGameDialog(
  BuildContext context, {
  required String gameName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => _DeleteGameDialog(gameName: gameName),
  );
  return confirmed ?? false;
}

class _DeleteGameDialog extends StatelessWidget {
  const _DeleteGameDialog({required this.gameName});

  final String gameName;

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
                  decoration: BoxDecoration(
                    color: danger.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 26,
                    color: danger,
                  ),
                ),
                const SizedBox(height: S.md),
                Semantics(
                  header: true,
                  child: Text(
                    'Cross this off?',
                    style: PT.sectionTitle(pt.text),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: S.sm),
                // The game name, struck through like a deleted notebook entry.
                Text(
                  gameName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: PT.bodyStrong(pt.textMuted).copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: danger,
                    decorationThickness: 2,
                  ),
                ),
                const SizedBox(height: S.xs),
                Text(
                  'This game leaves your library. '
                  'Past parties keep their scores.',
                  style: PT.caption(pt.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: S.xl),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Keep',
                        color: pt.text,
                        background: pt.surfaceMuted,
                        onTap: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: S.sm),
                    Expanded(
                      child: _DialogButton(
                        label: 'Delete',
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
