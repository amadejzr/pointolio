import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';

/// Themed text field for the Notebook/Slate forms - white surface, hairline
/// border, azure caret. Numbers still use Space Grotesk elsewhere; this is for
/// names and labels.
///
/// Reused across New Party / New Game / New Player. Set [hasError] to switch
/// the border to the danger hue; pair it with a `FieldErrorText` below.
class PtTextField extends StatelessWidget {
  const PtTextField({
    required this.controller,
    super.key,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.words,
    this.autofocus = false,
    this.hasError = false,
    this.semanticLabel,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool hasError;
  final String? semanticLabel;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    // The theme has no dedicated danger role; the rose player hue is the
    // agreed danger colour across new-theme screens (see delete_party_dialog).
    final danger = pt.players[3];

    return Semantics(
      label: semanticLabel,
      textField: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pt.surface,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: hasError ? danger : pt.border),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          cursorColor: pt.accent,
          style: PT.bodyStrong(pt.text).copyWith(fontSize: 15),
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: PT.body(pt.textFaint).copyWith(fontSize: 15),
          ),
        ),
      ),
    );
  }
}
