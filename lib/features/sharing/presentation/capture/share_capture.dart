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
        !boundary.debugNeedsPaint &&
        !boundary.size.isEmpty) {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes != null) return bytes.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 32));
  }
  return null;
}
