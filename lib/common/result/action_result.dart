import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/widgets/toast_message.dart';

/// Result of a cubit action (add, update, delete operations).
///
/// Use this to return operation results from cubits, allowing the UI
/// to show appropriate success/error toasts without storing toast state.
sealed class ActionResult {
  const ActionResult();

  /// Shows a toast based on the result type.
  void showToast(BuildContext context) {
    if (!context.mounted) return;
    switch (this) {
      case ActionSuccess(:final message):
        if (message != null) ToastMessage.success(context, message);
      case ActionFailure(:final message):
        ToastMessage.error(context, message);
    }
  }
}

/// Operation completed successfully.
class ActionSuccess extends ActionResult {
  const ActionSuccess([this.message]);

  final String? message;
}

/// Operation failed with an error.
class ActionFailure extends ActionResult {
  const ActionFailure(this.message);

  final String message;
}
