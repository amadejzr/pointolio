// share_sheet_cubit.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

part 'share_sheet_state.dart';

class ShareSheetCubit extends Cubit<ShareSheetState> {
  ShareSheetCubit({
    required int previewCount,
    this.pixelRatio = 3.0,
  }) : _keys = List.generate(previewCount, (_) => GlobalKey()),
       super(const ShareSheetState());

  final double pixelRatio;
  final List<GlobalKey> _keys;
  int _toastSeq = 0;

  List<GlobalKey> get captureKeys => _keys;

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

  Future<void> share(BuildContext context) async {
    if (state.busy || isClosed) return;
    emit(state.copyWith(busy: true));

    try {
      final bytes = await _captureCurrent();
      if (isClosed) return;

      if (bytes == null) {
        emit(state.copyWith(busy: false));
        _toast('Failed to capture image', ShareSheetToastType.error);
        return;
      }

      if (!context.mounted || isClosed) return;

      final size = MediaQuery.sizeOf(context);
      final ts = DateTime.now().millisecondsSinceEpoch;

      final xfile = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'scoreio_$ts.png',
        lastModified: DateTime.now(),
      );

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
          sharePositionOrigin: Rect.fromLTWH(
            0,
            size.height - 1,
            size.width,
            1,
          ),
        ),
      );

      if (isClosed) return;
      emit(state.copyWith(busy: false));

      if (result.status == ShareResultStatus.success && context.mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(busy: false));
      _toast('Share failed: $e', ShareSheetToastType.error);
    }
  }

  Future<void> saveToGallery(BuildContext context) async {
    if (state.busy || isClosed) return;
    emit(state.copyWith(busy: true));

    File? file;

    try {
      final ok = await _ensureGalleryPermission();
      if (isClosed) return;

      if (!ok) {
        emit(state.copyWith(busy: false));
        _toast('Photos permission not granted', ShareSheetToastType.error);
        return;
      }

      final bytes = await _captureCurrent();
      if (isClosed) return;

      if (bytes == null) {
        emit(state.copyWith(busy: false));
        _toast('Failed to capture image', ShareSheetToastType.error);
        return;
      }

      final dir = await getTemporaryDirectory();
      if (isClosed) return;

      final ts = DateTime.now().millisecondsSinceEpoch;
      file = File('${dir.path}/scoreio_$ts.png');
      await file.writeAsBytes(bytes, flush: true);

      final success =
          await GallerySaver.saveImage(file.path, albumName: 'Scoreio') ??
          false;

      if (isClosed) return;
      emit(state.copyWith(busy: false));

      if (success) {
        //
        // ignore: body_might_complete_normally_catch_error
        await file.delete().catchError((_) {});
        _toast('Image saved to gallery', ShareSheetToastType.success);
        if (context.mounted) Navigator.of(context).pop();
      } else {
        _toast('Failed to save to gallery', ShareSheetToastType.error);
      }
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(busy: false));
      _toast('Save failed: $e', ShareSheetToastType.error);

      if (file != null) {
        //
        // ignore: body_might_complete_normally_catch_error
        await file.delete().catchError((_) {});
      }
    }
  }

  Future<bool> _ensureGalleryPermission() async {
    if (isClosed) return false;
    if (!(Platform.isIOS || Platform.isAndroid)) return false;

    // iOS: Permission.photos
    // Android 13+: Permission.photos (READ_MEDIA_IMAGES)
    // older Android: Permission.storage
    final perm = Platform.isIOS ? Permission.photos : Permission.photos;

    final status = await perm.request();
    if (status.isGranted || status.isLimited) return true;

    // fallback for older Androids if needed
    if (Platform.isAndroid) {
      final legacy = await Permission.storage.request();
      return legacy.isGranted;
    }

    return false;
  }

  Future<Uint8List?> _captureCurrent() async {
    if (isClosed) return null;

    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (isClosed) return null;

    final index = state.index.clamp(0, _keys.length - 1);
    final boundary =
        _keys[index].currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

    if (boundary == null) return null;

    if (boundary.debugNeedsPaint) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (isClosed) return null;
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void clearToast() {
    if (isClosed) return;
    emit(state.copyWith());
  }
}
