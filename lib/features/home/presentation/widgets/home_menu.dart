import 'package:flutter/material.dart';

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
            case _HomeMenuAction.managePlayers:
              // Navigator.pushNamed(context, AppRouter.managePlayers);
              break;
            case _HomeMenuAction.manageGameTypes:
              // Navigator.pushNamed(context, AppRouter.manageGameTypes);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _HomeMenuAction.managePlayers,
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                const Text('Manage players'),
              ],
            ),
          ),
          PopupMenuItem(
            value: _HomeMenuAction.manageGameTypes,
            child: Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                const Text('Manage game types'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _HomeMenuAction { managePlayers, manageGameTypes }
