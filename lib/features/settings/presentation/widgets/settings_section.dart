import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';

/// A titled group of settings rows rendered as one card, with hairline
/// dividers between the [children]. Pass `SettingsTile`s (or any widgets).
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.children,
    super.key,
    this.title,
  });

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, S.sm),
            child: Semantics(
              header: true,
              child: Text(title!.toUpperCase(), style: PT.label(pt.textMuted)),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: pt.surface,
            borderRadius: BorderRadius.circular(R.lg),
            border: Border.all(color: pt.border),
            boxShadow: pt.shadowCard,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: S.md,
                    color: pt.border,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
