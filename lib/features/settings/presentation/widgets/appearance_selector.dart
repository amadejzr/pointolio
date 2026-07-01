import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/form/segmented_control.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_state.dart';

/// Notebook-themed appearance picker wrapped in a card: System / Light / Dark.
class AppearanceSelector extends StatelessWidget {
  const AppearanceSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Container(
      padding: const EdgeInsets.all(S.lg),
      decoration: BoxDecoration(
        color: pt.surface,
        borderRadius: BorderRadius.circular(R.lg),
        border: Border.all(color: pt.border),
        boxShadow: pt.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: pt.accentTint,
                  borderRadius: BorderRadius.circular(R.md),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: pt.accent,
                ),
              ),
              const SizedBox(width: S.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text('Appearance', style: PT.cardTitle(pt.text)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Choose your preferred theme',
                      style: PT.caption(pt.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: S.lg),
          SegmentedControl<AppThemeMode>(
            value: selected,
            onChanged: onChanged,
            options: const [
              SegmentOption(AppThemeMode.system, 'System'),
              SegmentOption(AppThemeMode.light, 'Light'),
              SegmentOption(AppThemeMode.dark, 'Dark'),
            ],
          ),
        ],
      ),
    );
  }
}
