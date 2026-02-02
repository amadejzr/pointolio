import 'package:flutter/material.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/features/home/presentation/cubit/home_state.dart';
import 'package:pointolio/features/home/presentation/widgets/game_card.dart';

class QuickActionsPreview extends StatelessWidget {
  const QuickActionsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GameCard(
            isEditing: true,
            onToggleFinished: () {},
            gameWithPlayerCount: GameWithPlayerCount(
              game: Game(
                id: 1,
                name: 'Rummy',
                createdAt: DateTime.now(),
                gameDate: DateTime.now(),
              ),
              playerCount: 5,
            ),
          ),
          Positioned(
            left: 16,
            bottom: -20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 14,
                  color: cs.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Long press',
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
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
