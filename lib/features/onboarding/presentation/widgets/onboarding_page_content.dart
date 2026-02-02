import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.icon,
    required this.title,
    required this.description,
    this.secondaryIcon,
    super.key,
  });

  final IconData icon;
  final IconData? secondaryIcon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: Spacing.page,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 56,
                  color: cs.onPrimaryContainer,
                ),
                if (secondaryIcon != null)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cs.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        secondaryIcon,
                        size: 20,
                        color: cs.onSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Spacing.gap24,
          Text(
            title,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.gap12,
          Text(
            description,
            style: tt.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
