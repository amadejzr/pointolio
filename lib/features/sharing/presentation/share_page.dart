import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/notebook_background.dart';
import 'package:pointolio/common/ui/widgets/page_app_bar.dart';
import 'package:pointolio/common/ui/widgets/toast_message.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/sharing/domain/share_result.dart';
import 'package:pointolio/features/sharing/presentation/capture/share_capture.dart';
import 'package:pointolio/features/sharing/presentation/cubit/share_editor_cubit.dart';
import 'package:pointolio/features/sharing/presentation/widgets/share_bits.dart';
import 'package:pointolio/features/sharing/presentation/widgets/share_card.dart';

/// The interactive share editor: pick a card style, set the transparency,
/// preview the (always transparent) card live, then share it. Full-screen,
/// Notebook-themed.
class SharePage extends StatefulWidget {
  const SharePage({
    required this.result,
    this.accent,
    this.launcher,
    super.key,
  });

  final ShareResult result;

  /// Optional accent (e.g. the game-type colour); falls back to the theme.
  final Color? accent;

  /// Overrides the share backend; injected in tests. Null uses `share_plus`.
  @visibleForTesting
  final ShareLauncher? launcher;

  /// Builds the [ShareResult] from live scoring state and pushes the editor.
  static Future<void> show(
    BuildContext context, {
    required ScoringData scoringData,
    required bool lowestScoreWins,
    Color? accent,
  }) {
    final result = ShareResult.fromScoringData(
      scoringData,
      lowestScoreWins: lowestScoreWins,
    );
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SharePage(result: result, accent: accent),
      ),
    );
  }

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShareEditorCubit(launcher: widget.launcher),
      child: _SharePageView(
        result: widget.result,
        accent: widget.accent,
        cardKey: _cardKey,
      ),
    );
  }
}

class _SharePageView extends StatelessWidget {
  const _SharePageView({
    required this.result,
    required this.accent,
    required this.cardKey,
  });

  final ShareResult result;
  final Color? accent;
  final GlobalKey cardKey;

  Future<void> _onShare(BuildContext context) async {
    final cubit = context.read<ShareEditorCubit>();
    if (cubit.state.busy) return;

    final size = MediaQuery.sizeOf(context);
    final bytes = await captureBoundary(cardKey);
    if (!context.mounted) return;

    if (bytes == null) {
      ToastMessage.error(context, 'Could not build the image');
      return;
    }

    final outcome = await cubit.share(
      bytes,
      origin: Rect.fromLTWH(0, size.height - 1, size.width, 1),
      text: result.toShareText(),
    );
    if (!context.mounted) return;

    switch (outcome) {
      case ShareActionResult.success:
        unawaited(Navigator.of(context).maybePop());
      case ShareActionResult.failed:
        ToastMessage.error(context, 'Sharing failed, please try again');
      case ShareActionResult.cancelled:
        break;
    }
  }

  Future<void> _onCopyText(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: result.toShareText()));
    if (!context.mounted) return;
    ToastMessage.success(context, 'Result copied');
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final resolvedAccent = accent ?? pt.accent;
    final bottom = MediaQuery.paddingOf(context).bottom;

    Color colorFor(Standing s) => s.storedColor != null
        ? Color(s.storedColor!)
        : pt.playerColor(s.colorIndex);

    return Scaffold(
      backgroundColor: pt.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NotebookBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                PageAppBar(
                  title: 'Share',
                  onBack: () => Navigator.of(context).maybePop(),
                ),

                // Preview. The RepaintBoundary wraps only the card, so the
                // export is a tight PNG. The translucent card sits over the
                // ruled paper, so the transparency is visible at a glance.
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(S.lg),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: BlocBuilder<ShareEditorCubit, ShareEditorState>(
                          buildWhen: (a, b) =>
                              a.style != b.style || a.opacity != b.opacity,
                          builder: (context, state) {
                            return RepaintBoundary(
                              key: cardKey,
                              child: SizedBox(
                                width: kShareCardWidth,
                                child: ShareCard(
                                  result: result,
                                  style: state.style,
                                  opacity: state.opacity,
                                  accent: resolvedAccent,
                                  colorFor: colorFor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Controls
                Container(
                  decoration: BoxDecoration(
                    color: pt.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(R.bar),
                    ),
                    boxShadow: pt.shadowFloat,
                  ),
                  padding: EdgeInsets.fromLTRB(S.lg, 16, S.lg, bottom + 14),
                  child: BlocBuilder<ShareEditorCubit, ShareEditorState>(
                    builder: (context, state) {
                      final cubit = context.read<ShareEditorCubit>();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STYLE', style: PT.label(pt.textMuted)),
                          const SizedBox(height: 8),
                          PickerChips(
                            labels: ShareStyle.values
                                .map((s) => s.label)
                                .toList(),
                            selected: ShareStyle.values.indexOf(state.style),
                            onSelect: (i) =>
                                cubit.setStyle(ShareStyle.values[i]),
                          ),
                          const SizedBox(height: 14),
                          TransparencySlider(
                            value: state.opacity,
                            onChanged: cubit.setOpacity,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _SecondaryButton(
                                  key: const Key('copy_text_button'),
                                  label: 'Copy text',
                                  onTap: state.busy
                                      ? null
                                      : () => _onCopyText(context),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: _PrimaryButton(
                                  key: const Key('share_button'),
                                  label: 'Share',
                                  busy: state.busy,
                                  onTap: state.busy
                                      ? null
                                      : () => _onShare(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      isButton: true,
      excludeChildSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pt.surface,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: pt.border),
        ),
        child: Text(
          label,
          style: PT.bodyStrong(pt.text2).copyWith(fontSize: 14.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.busy,
    this.onTap,
    super.key,
  });

  final String label;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      isButton: true,
      excludeChildSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pt.accent,
          borderRadius: BorderRadius.circular(R.md),
          boxShadow: pt.shadowAccent,
        ),
        child: busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(pt.accentText),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: PT.number(
                      pt.accentText,
                      size: 14.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.ios_share_rounded, size: 17, color: pt.accentText),
                ],
              ),
      ),
    );
  }
}
