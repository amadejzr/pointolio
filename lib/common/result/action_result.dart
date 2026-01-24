/// Result of a cubit action (add, update, delete operations).
///
/// Use this to return operation results from cubits, allowing the UI
/// to show appropriate success/error toasts without storing toast state.
sealed class ActionResult {
  const ActionResult();
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
