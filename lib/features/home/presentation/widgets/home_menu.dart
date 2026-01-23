import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointolio/router/app_router.dart';

class HomeOverflowMenu extends StatelessWidget {
  const HomeOverflowMenu({super.key});

  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<_HomeMenuAction>(
        tooltip: 'Menu',
        position: PopupMenuPosition.under,

        icon: Icon(Icons.more_horiz, color: cs.onSurfaceVariant),

        onSelected: (action) {
          switch (action) {
            case _HomeMenuAction.manage:
              unawaited(Navigator.pushNamed(context, AppRouter.manage));
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _HomeMenuAction.manage,
            child: Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                const Text('Manage'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _HomeMenuAction { manage }
