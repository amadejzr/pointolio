part of 'share_sheet_cubit.dart';

enum ShareSheetToastType { info, success, error }

class ShareSheetToast extends Equatable {
  const ShareSheetToast({
    required this.id,
    required this.message,
    required this.type,
  });

  final int id;
  final String message;
  final ShareSheetToastType type;

  @override
  List<Object?> get props => [id, message, type];
}

class ShareSheetState extends Equatable {
  const ShareSheetState({
    this.index = 0,
    this.busy = false,
    this.toast,
  });

  final int index;
  final bool busy;

  /// One-shot UI message (sheet renders it as a floating banner on top).
  final ShareSheetToast? toast;

  ShareSheetState copyWith({
    int? index,
    bool? busy,
    ShareSheetToast? toast,
  }) {
    return ShareSheetState(
      index: index ?? this.index,
      busy: busy ?? this.busy,
      toast: toast,
    );
  }

  @override
  List<Object?> get props => [index, busy, toast];
}
