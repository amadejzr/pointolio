import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// Full-width primary action ("Start party", "Save game", ...). Dims when
/// [enabled] is false and shows a spinner while [loading]. Colour and shadow
/// come from the theme.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    super.key,
    this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final active = enabled && !loading;
    return Pressable(
      onTap: active ? onTap : null,
      isButton: true,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 52),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? pt.accent : pt.surfaceMuted,
          borderRadius: BorderRadius.circular(R.md),
          // A border keeps the disabled pill readable against the paper bg.
          border: active ? null : Border.all(color: pt.borderStrong),
          boxShadow: active ? pt.shadowAccent : null,
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(pt.accentText),
                ),
              )
            : Text(
                label,
                style: PT.sectionTitle(
                  active ? pt.accentText : pt.textMuted,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
