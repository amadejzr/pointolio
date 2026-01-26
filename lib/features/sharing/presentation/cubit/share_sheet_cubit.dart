import 'dart:typed_data';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

part 'share_sheet_state.dart';

/// Result of a share or save operation.
enum ShareActionResult { success, cancelled, permissionDenied, failed }

class ShareSheetCubit extends Cubit<ShareSheetState> {
  ShareSheetCubit() : super(const ShareSheetState());

  int _toastSeq = 0;

  void setIndex(int index) {
    if (isClosed) return;
    emit(state.copyWith(index: index));
  }

  void _toast(String message, ShareSheetToastType type) {
    if (isClosed) return;
    _toastSeq++;
    emit(
      state.copyWith(
        toast: ShareSheetToast(id: _toastSeq, message: message, type: type),
      ),
    );
  }

  /// Shows an error toast message.
  void showError(String message) {
    _toast(message, ShareSheetToastType.error);
  }

  /// Shares the image bytes using the system share sheet.
  /// Returns the result of the share action.
  Future<ShareActionResult> share({
    required Uint8List imageBytes,
    required double screenWidth,
    required double screenHeight,
  }) async {
    if (state.busy || isClosed) return ShareActionResult.cancelled;
    emit(state.copyWith(busy: true));

    try {
      final ts = DateTime.now().millisecondsSinceEpoch;

      final xfile = XFile.fromData(
        imageBytes,
        mimeType: 'image/png',
        name: 'pointolio_$ts.png',
        lastModified: DateTime.now(),
      );

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
          sharePositionOrigin: Rect.fromLTWH(
            0,
            screenHeight - 1,
            screenWidth,
            1,
          ),
        ),
      );

      if (isClosed) return ShareActionResult.cancelled;
      emit(state.copyWith(busy: false));

      if (result.status == ShareResultStatus.success) {
        return ShareActionResult.success;
      }
      return ShareActionResult.cancelled;
    } on Object catch (e) {
      if (isClosed) return ShareActionResult.failed;
      emit(state.copyWith(busy: false));
      _toast('Share failed: $e', ShareSheetToastType.error);
      return ShareActionResult.failed;
    }
  }

  void clearToast() {
    if (isClosed) return;
    emit(state.copyWith());
  }
}
