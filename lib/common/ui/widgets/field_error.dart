import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';

/// Displays a field validation error message below a form field.
///
/// Shows red error text if [error] is not null, otherwise returns empty space.
class FieldError extends StatelessWidget {
  const FieldError({required this.error, super.key});

  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xxs),
      child: Text(
        error!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }
}
