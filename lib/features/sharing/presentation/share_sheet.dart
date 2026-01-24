import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/ui/widgets/toast_message.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/sharing/presentation/cubit/share_sheet_cubit.dart';
import 'package:pointolio/features/sharing/presentation/widgets/share_score_card_transparent.dart';
import 'package:pointolio/features/sharing/presentation/widgets/share_score_card_transparent_alt.dart';

class ShareSheet extends StatefulWidget {
  const ShareSheet({
    required this.scoringData,
    required this.lowestScoreWins,
    super.key,
    this.title = 'Share',
    this.primaryColor,
  });

  final ScoringData scoringData;
  final bool lowestScoreWins;
  final String title;
  final Color? primaryColor;

  static Future<void> show(
    BuildContext context, {
    required ScoringData scoringData,
    required bool lowestScoreWins,
    Color? primaryColor,
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
      builder: (_) => BlocProvider(
        create: (_) => ShareSheetCubit(),
        child: FractionallySizedBox(
          heightFactor: 0.95,
          child: ShareSheet(
            scoringData: scoringData,
            lowestScoreWins: lowestScoreWins,
            primaryColor: primaryColor,
            title: title,
          ),
        ),
      ),
    );
  }

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  static const double _capturePixelRatio = 3;

  late final PageController _pageController;
  late final List<Widget> _previews;

  // Keys for the VISIBLE repaint boundaries (one per page)
  late final List<GlobalKey> _previewKeys;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _previews = [
      ShareScoreCardTransparent(
        scoringData: widget.scoringData,
        lowestScoreWins: widget.lowestScoreWins,
        primaryColor: widget.primaryColor,
      ),
      ShareScoreCardTransparentAlt(
        scoringData: widget.scoringData,
        lowestScoreWins: widget.lowestScoreWins,
        primaryColor: widget.primaryColor,
      ),
    ];

    _previewKeys = List.generate(_previews.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureVisiblePreviewPng(int index) async {
    if (!mounted) return null;

    final i = index.clamp(0, _previewKeys.length - 1);

    // Make sure correct page is visible
    if (_pageController.hasClients) {
      final currentPage =
          (_pageController.page ?? _pageController.initialPage.toDouble())
              .round();
      if (currentPage != i) {
        _pageController.jumpToPage(i);
      }
    }

    // Simple delay - works reliably in both debug and release modes
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return null;

    for (var attempt = 0; attempt < 10; attempt++) {
      if (!mounted) return null;

      try {
        final ctx = _previewKeys[i].currentContext;
        if (ctx == null) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          continue;
        }

        if (!ctx.mounted) return null;

        final ro = ctx.findRenderObject();
        if (ro is! RenderRepaintBoundary) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          continue;
        }

        if (ro.size.isEmpty) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          continue;
        }

        // Capture the image
        final image = await ro.toImage(pixelRatio: _capturePixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();

        if (byteData == null) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          continue;
        }

        return byteData.buffer.asUint8List();
      } on Object {
        // Catch ALL errors (Exception and Error), wait and retry
        await Future<void>.delayed(const Duration(milliseconds: 100));
        continue;
      }
    }

    return null;
  }

  Future<void> _onSharePressed() async {
    final cubit = context.read<ShareSheetCubit>();
    final currentIndex = cubit.state.index;

    final bytes = await _captureVisiblePreviewPng(currentIndex);
    if (!mounted) return;

    if (bytes == null) {
      ToastMessage.error(context, 'Failed to capture image');
      return;
    }

    final size = MediaQuery.sizeOf(context);
    final result = await cubit.share(
      imageBytes: bytes,
      screenWidth: size.width,
      screenHeight: size.height,
    );

    if (!mounted) return;

    switch (result) {
      case ShareActionResult.success:
        Navigator.of(context).pop();
      case ShareActionResult.failed:
        ToastMessage.error(context, 'Failed to share image');
      case ShareActionResult.cancelled:
      case ShareActionResult.permissionDenied:
        break;
    }
  }

  Future<void> _onSavePressed() async {
    final cubit = context.read<ShareSheetCubit>();
    final currentIndex = cubit.state.index;

    final bytes = await _captureVisiblePreviewPng(currentIndex);
    if (!mounted) return;

    if (bytes == null) {
      ToastMessage.error(context, 'Failed to capture image');
      return;
    }

    final result = await cubit.saveToGallery(bytes);

    if (!mounted) return;

    switch (result) {
      case ShareActionResult.success:
        ToastMessage.success(context, 'Image saved to gallery');
        Navigator.of(context).pop();
      case ShareActionResult.failed:
        ToastMessage.error(context, 'Failed to save image');
      case ShareActionResult.permissionDenied:
        ToastMessage.error(context, 'Photos permission not granted');
      case ShareActionResult.cancelled:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset + 5),
      child: Column(
        children: [
          const SizedBox(height: 6),

          // ===== Header =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                BlocBuilder<ShareSheetCubit, ShareSheetState>(
                  builder: (context, state) => _ChipCounter(
                    current: state.index + 1,
                    total: _previews.length,
                  ),
                ),
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
                      itemCount: _previews.length,
                      onPageChanged: (i) =>
                          context.read<ShareSheetCubit>().setIndex(i),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.all(14),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: RepaintBoundary(
                                key: _previewKeys[i],
                                child: _previews[i],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // subtle gradient (UI only, not captured)
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

                    // dots
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: BlocBuilder<ShareSheetCubit, ShareSheetState>(
                        builder: (context, state) => _Dots(
                          count: _previews.length,
                          index: state.index,
                        ),
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
            child: BlocBuilder<ShareSheetCubit, ShareSheetState>(
              builder: (context, state) {
                return Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.ios_share_rounded,
                        label: 'More',
                        busy: state.busy,
                        onTap: _onSharePressed,
                        prominent: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.download_rounded,
                        label: 'Save image',
                        busy: state.busy,
                        onTap: _onSavePressed,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// ===== UI bits =====

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
  final VoidCallback onTap;
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
          color: busy ? cs.surfaceContainerHighest.withAlpha(120) : bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Center(
          child: busy
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
