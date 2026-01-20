import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/features/home/presentation/cubit/home_cubit.dart';
import 'package:scoreio/features/home/presentation/cubit/home_state.dart';
import 'package:scoreio/features/home/presentation/widgets/delete_game_dialog.dart';
import 'package:scoreio/features/home/presentation/widgets/game_card.dart';
import 'package:scoreio/features/home/presentation/widgets/home_menu.dart';
import 'package:scoreio/router/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeCubit(gameRepository: locator<GameRepository>())..loadGames(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: const Text('My Games'),
            actions: [
              if (state.isEditing)
                TextButton(
                  onPressed: cubit.exitEditMode,
                  child: const Text('Done'),
                )
              else
                const HomeOverflowMenu(),
            ],
          ),

          body: _HomeBody(state: state),

          floatingActionButton: state.isEditing
              ? null
              : FloatingActionButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.createGame),
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (state.status == HomeStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HomeStatus.error) {
      return Center(
        child: Text(
          state.errorMessage ?? 'Something went wrong',
          style: TextStyle(color: cs.error),
        ),
      );
    }

    if (state.games.isEmpty) {
      return const _EmptyGamesState();
    }

    return ListView.separated(
      padding: Spacing.page,
      itemCount: state.games.length,
      separatorBuilder: (_, _) => Spacing.gap12,
      itemBuilder: (context, index) {
        final gameWithCount = state.games[index];

        return GameCard(
          gameWithPlayerCount: gameWithCount,
          isEditing: state.isEditing,
          onTap: () => Navigator.pushNamed(
            context,
            AppRouter.scoring,
            arguments: gameWithCount.game.id,
          ),
          onLongPress: () => context.read<HomeCubit>().toggleEditMode(),
          onDelete: () async {
            final confirmed = await DeleteGameDialog.show(
              context,
              gameName: gameWithCount.game.name,
            );
            if (confirmed && context.mounted) {
              unawaited(
                context.read<HomeCubit>().deleteGame(gameWithCount.game.id),
              );
            }
          },
        );
      },
    );
  }
}

class _EmptyGamesState extends StatelessWidget {
  const _EmptyGamesState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: Spacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 64,
              color: cs.onSurfaceVariant,
            ),
            Spacing.gap16,
            Text(
              'No games yet',
              style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Spacing.gap8,
            Text(
              'Tap + to create your first game',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
