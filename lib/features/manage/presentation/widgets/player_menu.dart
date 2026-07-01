import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// Actions offered by the per-player "⋯" dropdown.
enum PlayerAction { edit, delete }

const double _menuWidth = 216;
const double _estMenuHeight = 116;

/// Opens a themed dropdown anchored to [anchorContext] (the "⋯" button) and
/// returns the chosen [PlayerAction], or null if dismissed. Fully custom (no
/// Material popup) so it matches the Notebook/Slate surfaces and motion.
Future<PlayerAction?> showPlayerMenu(BuildContext anchorContext) {
  final box = anchorContext.findRenderObject()! as RenderBox;
  final topLeft = box.localToGlobal(Offset.zero);
  final size = box.size;
  final screen = MediaQuery.sizeOf(anchorContext);
  final insets = MediaQuery.paddingOf(anchorContext);

  // Right-align the menu with the button; flip above it near the bottom.
  final rightInset = screen.width - (topLeft.dx + size.width);
  final spaceBelow = screen.height - (topLeft.dy + size.height) - insets.bottom;
  final openUp = spaceBelow < _estMenuHeight + S.lg;

  return showGeneralDialog<PlayerAction>(
    context: anchorContext,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: Motion.fast,
    pageBuilder: (context, animation, _) {
      final curved = CurvedAnimation(parent: animation, curve: Motion.ease);
      return Stack(
        children: [
          Positioned(
            right: rightInset,
            top: openUp ? null : topLeft.dy + size.height + S.xs,
            bottom: openUp ? screen.height - topLeft.dy + S.xs : null,
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
                alignment: openUp ? Alignment.bottomRight : Alignment.topRight,
                child: const _PlayerMenu(),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _PlayerMenu extends StatelessWidget {
  const _PlayerMenu();

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: _menuWidth,
        padding: const EdgeInsets.all(S.xs),
        decoration: BoxDecoration(
          color: pt.surface,
          borderRadius: BorderRadius.circular(R.lg),
          border: Border.all(color: pt.border),
          boxShadow: pt.shadowFloat,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuRow(
              icon: Icons.edit_outlined,
              label: 'Edit player',
              color: pt.accent,
              tint: pt.accentTint,
              textColor: pt.text,
              onTap: () => Navigator.pop(context, PlayerAction.edit),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: pt.border,
              indent: S.sm,
              endIndent: S.sm,
            ),
            _MenuRow(
              icon: Icons.delete_outline_rounded,
              label: 'Delete player',
              color: pt.players[3], // rose
              tint: pt.surfaceMuted,
              textColor: pt.players[3],
              onTap: () => Navigator.pop(context, PlayerAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.tint,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color tint;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      isButton: true,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: S.sm, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: S.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PT.bodyStrong(textColor).copyWith(fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
