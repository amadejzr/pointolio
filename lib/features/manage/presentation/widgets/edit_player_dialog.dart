import 'package:flutter/material.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';

/// A dialog for editing player information.
///
/// This is a dumb widget that accepts initial values and returns
/// the edited data via callbacks. No state management logic here.
class EditPlayerDialog extends StatefulWidget {
  const EditPlayerDialog({
    required this.firstName,
    this.lastName,
    super.key,
  });

  final String firstName;
  final String? lastName;

  /// Shows the edit player dialog.
  ///
  /// Returns a map with 'firstName' and 'lastName' keys if confirmed,
  /// or null if cancelled.
  static Future<Map<String, String?>?> show(
    BuildContext context, {
    required String firstName,
    String? lastName,
  }) async {
    return showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => EditPlayerDialog(
        firstName: firstName,
        lastName: lastName,
      ),
    );
  }

  @override
  State<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<EditPlayerDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _confirm() {
    final firstName = _firstNameController.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name is required')),
      );
      return;
    }

    Navigator.pop(context, {
      'firstName': firstName,
      'lastName': _lastNameController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Edit Player'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First name',
              hintText: 'Enter first name',
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          Spacing.gap16,
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last name (optional)',
              hintText: 'Enter last name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _confirm,
          style: TextButton.styleFrom(foregroundColor: cs.primary),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
