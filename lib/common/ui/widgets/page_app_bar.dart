import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// Header for full-screen pushed pages in the Notebook/Slate theme.
///
/// A round grey back button on the left, the page title beside it, and an
/// optional trailing [action]. Pair it with a `NotebookBackground` behind a
/// transparent Scaffold - see `SettingsPage` for the reference layout.
///
/// [onBack] defaults to popping the current route via go_router.
class PageAppBar extends StatelessWidget {
  const PageAppBar({
    required this.title,
    super.key,
    this.onBack,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(S.lg, S.sm, S.lg, S.md),
      child: Row(
        children: [
          Pressable(
            onTap: onBack ?? () => context.pop(),
            scale: 0.9,
            isButton: true,
            semanticLabel: 'Back',
            excludeChildSemantics: true,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: pt.surface,
                shape: BoxShape.circle,
                border: Border.all(color: pt.border),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 19,
                color: pt.textMuted,
              ),
            ),
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: PT.screenTitle(pt.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
