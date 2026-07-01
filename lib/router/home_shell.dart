import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/notebook_background.dart';
import 'package:pointolio/router/app_router.dart';

/// Height of the floating navigation pill (excludes the gap below it).
const double kFloatingNavBarHeight = 64;

/// Hosts the three shell branches (Parties, Players, Games) in an
/// [IndexedStack] over a full-screen notebook background, with a floating,
/// frosted bottom bar overlaid on top. Pages extend behind the bar; extra
/// bottom padding is injected so their content and FABs clear it.
class HomeShell extends StatelessWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops it back to the branch root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final mq = MediaQuery.of(context);

    // Space the bar occupies above the system inset (pill + gap below it).
    const barReserve = kFloatingNavBarHeight + S.sm;

    return Scaffold(
      backgroundColor: pt.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NotebookBackground()),
          // Give pages enough bottom padding to clear the floating bar.
          MediaQuery(
            data: mq.copyWith(
              padding: mq.padding.copyWith(
                bottom: mq.padding.bottom + barReserve,
              ),
            ),
            child: navigationShell,
          ),
          Positioned(
            left: S.lg,
            right: S.lg,
            bottom: mq.padding.bottom + S.sm,
            child: _FloatingNavBar(
              currentIndex: navigationShell.currentIndex,
              onTabSelected: _goBranch,
              onCreate: () => unawaited(context.push(AppRouter.createGame)),
            ),
          ),
        ],
      ),
    );
  }
}

const _tabs = <({IconData icon, String label})>[
  (icon: Icons.grid_view_rounded, label: 'Parties'),
  (icon: Icons.people_alt_rounded, label: 'Players'),
  (icon: Icons.casino_rounded, label: 'Games'),
];

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCreate,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(R.bar),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: kFloatingNavBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: S.md),
          decoration: BoxDecoration(
            color: pt.surface.withValues(alpha: isDark ? 0.62 : 0.78),
            borderRadius: BorderRadius.circular(R.bar),
            border: Border.all(color: pt.border),
            boxShadow: pt.shadowFloat,
          ),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _Tab(
                    icon: _tabs[i].icon,
                    label: _tabs[i].label,
                    selected: i == currentIndex,
                    onTap: () {
                      if (i != currentIndex) {
                        unawaited(HapticFeedback.selectionClick());
                        onTabSelected(i);
                      }
                    },
                  ),
                ),
              const SizedBox(width: S.xs),
              _AddButton(onTap: onCreate),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Motion.base;

    return Pressable(
      onTap: onTap,
      scale: 0.88,
      isButton: true,
      selected: selected,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: selected ? 1 : 0),
        duration: duration,
        curve: Motion.ease,
        builder: (context, t, _) {
          final color = Color.lerp(pt.textMuted, pt.accent, t)!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, -2 * t),
                child: Icon(icon, size: 23, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: PT
                    .tab(color)
                    .copyWith(
                      fontWeight: FontWeight.lerp(
                        FontWeight.w600,
                        FontWeight.w700,
                        t,
                      ),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Pressable(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      scale: 0.9,
      isButton: true,
      semanticLabel: 'Create game',
      excludeChildSemantics: true,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: pt.accent,
          shape: BoxShape.circle,
          boxShadow: pt.shadowAccent,
        ),
        child: Icon(Icons.add_rounded, size: 26, color: pt.accentText),
      ),
    );
  }
}
