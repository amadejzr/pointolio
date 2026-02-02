import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';

class FeaturePageContent extends StatelessWidget {
  const FeaturePageContent({
    required this.preview,
    required this.title,
    required this.description,
    super.key,
  });

  final Widget preview;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: Spacing.page,
      child: Column(
        children: [
          const Spacer(flex: 2),
          preview,
          const Spacer(),
          Text(
            title,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.gap12,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: tt.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
