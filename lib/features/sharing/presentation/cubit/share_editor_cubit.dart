import 'dart:typed_data';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/features/sharing/domain/share_result.dart';
import 'package:share_plus/share_plus.dart';

part 'share_editor_state.dart';

/// Result of a share attempt.
enum ShareActionResult { success, cancelled, failed }

/// Bounds for the transparency control (fill opacity of the glass card).
const double kMinShareOpacity = 0.35;
const double kMaxShareOpacity = 1;

/// Thin seam over the platform share sheet so the cubit stays unit-testable.
// ignore: one_member_abstracts
abstract interface class ShareLauncher {
  Future<ShareActionResult> shareImage(
    Uint8List bytes, {
    required Rect origin,
    String? text,
  });
}

/// Default [ShareLauncher] backed by `share_plus`.
class SharePlusLauncher implements ShareLauncher {
  const SharePlusLauncher();

  @override
  Future<ShareActionResult> shareImage(
    Uint8List bytes, {
    required Rect origin,
    String? text,
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = XFile.fromData(
      bytes,
      mimeType: 'image/png',
      name: 'pointolio_$ts.png',
    );

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [file],
        text: text,
        sharePositionOrigin: origin,
      ),
    );

    return switch (result.status) {
      ShareResultStatus.success => ShareActionResult.success,
      ShareResultStatus.dismissed => ShareActionResult.cancelled,
      ShareResultStatus.unavailable => ShareActionResult.cancelled,
    };
  }
}

/// Owns the interactive editor state (style / background / transparency) and
/// runs the actual share. The widget layer captures the PNG bytes from the
/// preview and hands them to [share]; everything else lives here.
class ShareEditorCubit extends Cubit<ShareEditorState> {
  ShareEditorCubit({ShareLauncher? launcher})
    : _launcher = launcher ?? const SharePlusLauncher(),
      super(const ShareEditorState());

  final ShareLauncher _launcher;

  void setStyle(ShareStyle style) {
    if (isClosed) return;
    emit(state.copyWith(style: style));
  }

  void setOpacity(double opacity) {
    if (isClosed) return;
    final clamped = opacity.clamp(kMinShareOpacity, kMaxShareOpacity);
    emit(state.copyWith(opacity: clamped));
  }

  /// Shares the captured PNG through the system sheet.
  ///
  /// [origin] anchors the iPad share popover; [text] is an optional caption.
  Future<ShareActionResult> share(
    Uint8List bytes, {
    required Rect origin,
    String? text,
  }) async {
    if (state.busy || isClosed) return ShareActionResult.cancelled;
    emit(state.copyWith(busy: true));
    try {
      final result = await _launcher.shareImage(
        bytes,
        origin: origin,
        text: text,
      );
      if (!isClosed) emit(state.copyWith(busy: false));
      return result;
    } on Object {
      if (!isClosed) emit(state.copyWith(busy: false));
      return ShareActionResult.failed;
    }
  }
}
