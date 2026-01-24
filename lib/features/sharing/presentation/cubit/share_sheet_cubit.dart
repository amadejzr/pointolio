import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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

  /// Saves the image bytes to the device gallery.
  /// Returns the result of the save action.
  Future<ShareActionResult> saveToGallery(Uint8List imageBytes) async {
    if (state.busy || isClosed) return ShareActionResult.cancelled;
    emit(state.copyWith(busy: true));

    try {
      final permissionGranted = await _ensureGalleryPermission();
      if (isClosed) return ShareActionResult.cancelled;

      if (!permissionGranted) {
        emit(state.copyWith(busy: false));
        _toast('Photos permission not granted', ShareSheetToastType.error);
        return ShareActionResult.permissionDenied;
      }

      final result = await ImageGallerySaverPlus.saveImage(imageBytes);

      if (isClosed) return ShareActionResult.cancelled;
      emit(state.copyWith(busy: false));

      // saveImage function is returning dynamic result
      // ignore: avoid_dynamic_calls
      final success = result['isSuccess'] as bool? ?? false;
      if (success) {
        _toast('Image saved to gallery', ShareSheetToastType.success);
        return ShareActionResult.success;
      } else {
        _toast('Failed to save to gallery', ShareSheetToastType.error);
        return ShareActionResult.failed;
      }
    } on Object catch (e) {
      if (isClosed) return ShareActionResult.failed;
      emit(state.copyWith(busy: false));
      _toast('Save failed: $e', ShareSheetToastType.error);
      return ShareActionResult.failed;
    }
  }

  Future<bool> _ensureGalleryPermission() async {
    if (isClosed) return false;
    if (!(Platform.isIOS || Platform.isAndroid)) return false;

    // iOS: photosAddOnly for saving images (write-only)
    // Android 13+: Permission.photos (READ_MEDIA_IMAGES)
    // older Android: Permission.storage
    final perm = Platform.isIOS ? Permission.photosAddOnly : Permission.photos;

    final status = await perm.request();

    if (status.isGranted || status.isLimited) return true;

    // If permanently denied, open app settings so user can grant manually
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    // fallback for older Androids if needed
    if (Platform.isAndroid) {
      final legacy = await Permission.storage.request();
      return legacy.isGranted;
    }

    return false;
  }

  void clearToast() {
    if (isClosed) return;
    emit(state.copyWith());
  }
}
