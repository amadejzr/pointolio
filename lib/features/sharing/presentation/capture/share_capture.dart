import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Rasterises whatever is inside a [RepaintBoundary] to PNG bytes.
///
/// Wrap the share card in `RepaintBoundary(key: myKey)`, then call
/// `captureBoundary(myKey)`. A [pixelRatio] of 3 yields a crisp export at 3x
/// the card's logical size. Retries a few frames while layout settles, and
/// returns null if the boundary never becomes paintable.
Future<Uint8List?> captureBoundary(
  GlobalKey key, {
  double pixelRatio = 3.0,
  int maxAttempts = 10,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    final ctx = key.currentContext;
    final boundary = ctx?.findRenderObject();
    if (boundary is RenderRepaintBoundary &&
        boundary.hasSize &&
        !boundary.size.isEmpty &&
        !_needsPaint(boundary)) {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes != null) return bytes.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    }
    // Let a frame paint before the next attempt (schedules one if idle).
    await WidgetsBinding.instance.endOfFrame;
  }
  return null;
}

/// Whether the boundary still needs to be painted before it can be captured.
///
/// [RenderObject.debugNeedsPaint] is a debug-only getter: its backing field is
/// assigned only inside an `assert`, so reading it in a release/profile build
/// throws `LateInitializationError`. We therefore consult it behind an assert
/// (accurate in debug) and treat the boundary as ready in release, where the
/// card has already been painted on screen before the user taps Share.
bool _needsPaint(RenderRepaintBoundary boundary) {
  var needsPaint = false;
  assert(() {
    needsPaint = boundary.debugNeedsPaint;
    return true;
  }(), 'debug-only paint check');
  return needsPaint;
}
