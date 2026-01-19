import 'package:flutter/material.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';

class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

  static Future<Map<String, String>?> show(BuildContext context) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddPlayerDialog(),
    );
  }

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Player'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'First name'),
            autocorrect: false,
            textCapitalization: TextCapitalization.words,
          ),
          Spacing.gap12,
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(hintText: 'Last name (optional)'),
            autocorrect: false,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
