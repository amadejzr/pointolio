import 'package:flutter/material.dart';

/// A reusable confirmation dialog for delete operations.
///
/// This is a dumb widget that follows the existing dialog pattern
/// seen in the codebase (e.g., DeleteGameDialog).
class DeleteConfirmationDialog {
  /// Shows a delete confirmation dialog.
  ///
  /// Returns `true` if the user confirmed, `false` otherwise.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String itemName,
    String? description,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete "$itemName"?'),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
