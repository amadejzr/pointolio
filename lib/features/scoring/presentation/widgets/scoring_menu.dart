import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// Actions offered by the scoring "⋯" dropdown.
enum ScoringMenuAction { toggleFinished, edit, share }

const double _menuWidth = 224;
const double _estMenuHeight = 168;

/// Opens a themed dropdown anchored to [anchorContext] (the "⋯" button) and
/// returns the chosen [ScoringMenuAction], or null if dismissed. Fully custom
/// (no Material popup) so it matches the Notebook/Slate surfaces and motion.
/// Mirrors `showPartyMenu` / `showPlayerMenu`.
Future<ScoringMenuAction?> showScoringMenu(
  BuildContext anchorContext, {
  required bool isFinished,
}) {
  final box = anchorContext.findRenderObject()! as RenderBox;
  final topLeft = box.localToGlobal(Offset.zero);
  final size = box.size;
  final screen = MediaQuery.sizeOf(anchorContext);
  final insets = MediaQuery.paddingOf(anchorContext);

  // Right-align the menu with the button; flip above it near the bottom.
  final rightInset = screen.width - (topLeft.dx + size.width);
  final spaceBelow = screen.height - (topLeft.dy + size.height) - insets.bottom;
  final openUp = spaceBelow < _estMenuHeight + S.lg;

  return showGeneralDialog<ScoringMenuAction>(
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
                child: _ScoringMenu(isFinished: isFinished),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _ScoringMenu extends StatelessWidget {
  const _ScoringMenu({required this.isFinished});

  final bool isFinished;

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
              icon: isFinished
                  ? Icons.replay_rounded
                  : Icons.check_circle_outline_rounded,
              label: isFinished ? 'Reopen party' : 'Finish party',
              color: pt.accent,
              tint: pt.accentTint,
              textColor: pt.text,
              onTap: () =>
                  Navigator.pop(context, ScoringMenuAction.toggleFinished),
            ),
            _MenuDivider(color: pt.border),
            _MenuRow(
              icon: Icons.edit_outlined,
              label: 'Edit party',
              color: pt.accent,
              tint: pt.accentTint,
              textColor: pt.text,
              onTap: () => Navigator.pop(context, ScoringMenuAction.edit),
            ),
            _MenuDivider(color: pt.border),
            _MenuRow(
              icon: Icons.ios_share_rounded,
              label: 'Share',
              color: pt.accent,
              tint: pt.accentTint,
              textColor: pt.text,
              onTap: () => Navigator.pop(context, ScoringMenuAction.share),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: color,
      indent: S.sm,
      endIndent: S.sm,
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
