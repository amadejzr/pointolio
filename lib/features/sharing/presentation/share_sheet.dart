import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareSheet extends StatefulWidget {
  const ShareSheet({
    required this.previews,
    super.key,
    this.title = 'Share',
  });

  final List<Widget> previews;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required List<Widget> previews,
    String title = 'Share',
  }) {
    final cs = Theme.of(context).colorScheme;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ShareSheet(
          previews: previews,
          title: title,
        ),
      ),
    );
  }

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  late final PageController _pageController;
  late final List<GlobalKey> _captureKeys;
  int _index = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _captureKeys = List.generate(
      widget.previews.length,
      (_) => GlobalKey(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Captures the current preview widget as a high-quality PNG.
  Future<Uint8List?> _captureWidget({double pixelRatio = 3.0}) async {
    // Wait for the next frame to ensure painting is complete
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final key = _captureKeys[_index];
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    // Wait until the boundary is ready to be painted
    if (boundary.debugNeedsPaint) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Saves the captured image to a temporary file and returns the path.
  Future<String?> _saveToTempFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/scoreio_$timestamp.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> _onShare() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final bytes = await _captureWidget();
      if (bytes == null) {
        _showError('Failed to capture image');
        return;
      }

      final path = await _saveToTempFile(bytes);
      if (path == null) {
        _showError('Failed to save image');
        return;
      }

      // Use platform share sheet

      if (!mounted) {
        return;
      }
      final size = MediaQuery.of(context).size;

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: 'Shared from Scoreio',
          sharePositionOrigin: Rect.fromLTWH(
            0,
            size.height - 1, // bottom edge
            size.width,
            1, // minimal non-zero height
          ),
        ),
      );

      if (result.status == ShareResultStatus.success) {
        if (mounted) Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      _showError('Share failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onSaveImage() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final bytes = await _captureWidget();
      if (bytes == null) {
        _showError('Failed to capture image');
        return;
      }

      final path = await _saveToTempFile(bytes);
      if (path == null) {
        _showError('Failed to save image');
        return;
      }

      final success =
          await GallerySaver.saveImage(path, albumName: 'Scoreio') ?? false;

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved to gallery')),
          );
          Navigator.of(context).pop();
        }
      } else {
        _showError('Failed to save to gallery');
      }
    } on Exception catch (e) {
      _showError('Save failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final previews = widget.previews.isEmpty
        ? [
            const _EmptyPreview(
              title: 'Nothing to share',
              subtitle: 'Generate a scorecard first.',
            ),
          ]
        : widget.previews;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset + 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),

          // ===== Header =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                _ChipCounter(current: _index + 1, total: previews.length),
              ],
            ),
          ),

          // ===== Preview Carousel =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400,
                minHeight: 200,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: previews.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.all(14),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              // RepaintBoundary inside FittedBox captures
                              // the full-size widget, not the scaled version
                              child: RepaintBoundary(
                                key: _captureKeys.length > i
                                    ? _captureKeys[i]
                                    : null,
                                child: previews[i],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // subtle gradient for nicer feel
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                cs.surface.withAlpha(0),
                                cs.surface.withAlpha(200),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // page dots
                    if (previews.length > 1)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: _Dots(
                          count: previews.length,
                          index: _index,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Spacer(),

          // ===== Actions =====
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.ios_share_rounded,
                        label: 'More',
                        busy: _busy,
                        onTap: widget.previews.isEmpty ? null : _onShare,
                        prominent: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.download_rounded,
                        label: 'Save image',
                        busy: _busy,
                        onTap: widget.previews.isEmpty ? null : _onSaveImage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.busy,
    required this.onTap,
    this.prominent = false,
  });

  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback? onTap;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final bg = prominent ? cs.primary : cs.surfaceContainerHighest;
    final fg = prominent ? cs.onPrimary : cs.onSurface;

    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        height: 52,
        decoration: BoxDecoration(
          color: onTap == null ? cs.surfaceContainerHighest.withAlpha(120) : bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Center(
          child: busy && onTap != null
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: fg,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ChipCounter extends StatelessWidget {
  const _ChipCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        '$current / $total',
        style: text.labelMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.onSurfaceVariant.withAlpha(90),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 34,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
