import 'package:flutter/material.dart';

class DeleteGameDialog {
  static Future<bool> show(
    BuildContext context, {
    required String gameName,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Game'),
            content: Text('Are you sure you want to delete "$gameName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
