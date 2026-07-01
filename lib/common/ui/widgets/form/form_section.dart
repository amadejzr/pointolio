import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';

/// The little uppercase field label ("PARTY NAME", "GAME", "COLOUR", ...).
class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: PT.label(context.pt.textMuted));
  }
}

/// A labelled block: the label (with an optional [trailing] widget - e.g. a
/// count or a "New" action) above its [child] field. Compose these down a form
/// with a [SectionGap] between them.
class FormSection extends StatelessWidget {
  const FormSection({
    required this.child,
    super.key,
    this.label,
    this.trailing,
  });

  final String? label;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 9, left: 2),
            child: Row(
              children: [
                FormLabel(label!),
                if (trailing != null) ...[const Spacer(), trailing!],
              ],
            ),
          ),
        child,
      ],
    );
  }
}

/// Standard vertical gap between form sections.
class SectionGap extends StatelessWidget {
  const SectionGap({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: S.xl);
}

/// Inline validation error shown under a form field. Renders nothing when
/// [error] is null. Uses the shared new-theme danger hue.
class FieldErrorText extends StatelessWidget {
  const FieldErrorText({required this.error, super.key});

  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    final pt = context.pt;
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 2),
      child: Text(error!, style: PT.caption(pt.players[3])),
    );
  }
}
