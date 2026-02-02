import 'package:flutter/material.dart';

class CalculatorPreview extends StatelessWidget {
  const CalculatorPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expression display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '50 + 30',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  '80',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Calculator buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CalcButton(label: '7', cs: cs),
              _CalcButton(label: '8', cs: cs),
              _CalcButton(label: '9', cs: cs),
              _CalcButton(label: '+', cs: cs, isOperator: true),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CalcButton(label: '4', cs: cs),
              _CalcButton(label: '5', cs: cs, isHighlighted: true),
              _CalcButton(label: '6', cs: cs),
              _CalcButton(label: '-', cs: cs, isOperator: true),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CalcButton(label: '1', cs: cs),
              _CalcButton(label: '2', cs: cs),
              _CalcButton(label: '3', cs: cs),
              _CalcButton(label: '=', cs: cs, isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  const _CalcButton({
    required this.label,
    required this.cs,
    this.isOperator = false,
    this.isPrimary = false,
    this.isHighlighted = false,
  });

  final String label;
  final ColorScheme cs;
  final bool isOperator;
  final bool isPrimary;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (isPrimary) {
      bgColor = cs.primary;
      textColor = cs.onPrimary;
    } else if (isOperator) {
      bgColor = cs.secondaryContainer;
      textColor = cs.onSecondaryContainer;
    } else if (isHighlighted) {
      bgColor = cs.primaryContainer;
      textColor = cs.onPrimaryContainer;
    } else {
      bgColor = cs.surface;
      textColor = cs.onSurface;
    }

    return Container(
      width: 44,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? null : Border.all(color: cs.outlineVariant),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
