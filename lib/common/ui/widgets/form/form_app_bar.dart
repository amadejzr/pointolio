import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// Modal header for the create/edit forms: Cancel - Title - optional action.
///
/// Works for "New party", "New game", "New player" and their edit variants.
/// Pass an [actionLabel]/[onAction] to show a trailing text action (e.g.
/// "Save"); leave them null when the screen relies on a pinned bottom CTA.
/// [actionEnabled] dims the action when false.
class FormAppBar extends StatelessWidget {
  const FormAppBar({
    required this.title,
    required this.onCancel,
    super.key,
    this.cancelLabel = 'Cancel',
    this.actionLabel,
    this.onAction,
    this.actionEnabled = true,
  });

  final String title;
  final VoidCallback onCancel;
  final String cancelLabel;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Padding(
          // Match the content margin so Cancel/Start line up with the fields.
          padding: const EdgeInsets.symmetric(horizontal: S.lg),
          child: Row(
            children: [
              // Text hugs the content edge; the hit target grows outward.
              _BarAction(
                label: cancelLabel,
                style: PT.body(pt.textMuted).copyWith(fontSize: 14),
                alignment: Alignment.centerLeft,
                onTap: onCancel,
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PT
                        .sectionTitle(
                          pt.text,
                        )
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (actionLabel == null)
                const SizedBox(width: 48)
              else
                _BarAction(
                  label: actionLabel!,
                  style: PT
                      .bodyStrong(
                        actionEnabled ? pt.accent : pt.textMuted,
                      )
                      .copyWith(fontSize: 14),
                  alignment: Alignment.centerRight,
                  onTap: actionEnabled ? onAction : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable bar label with a >=48px hit target. [alignment] decides which
/// edge the text hugs (left for Cancel, right for the action) so the label
/// lines up with the page content margin.
class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.label,
    required this.style,
    required this.alignment,
    this.onTap,
  });

  final String label;
  final TextStyle style;
  final AlignmentGeometry alignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      isButton: true,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        alignment: alignment,
        child: Text(label, style: style),
      ),
    );
  }
}
