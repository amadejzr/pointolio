import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';

class WelcomePageContent extends StatelessWidget {
  const WelcomePageContent({super.key});

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
          ClipRRect(
            borderRadius: BorderRadius.circular(24), // adjust to taste
            child: SizedBox(
              width: 140,
              height: 140,
              child: Image.asset(
                'assets/logo/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Spacing.gap24,
          Text(
            'Pointolio',
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Spacing.gap8,
          Text(
            'Track scores for any game',
            style: tt.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
