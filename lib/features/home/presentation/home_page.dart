import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/features/home/presentation/cubit/home_cubit.dart';
import 'package:scoreio/features/home/presentation/cubit/home_state.dart';
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

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    String gameName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Game'),
            content: Text('Are you sure you want to delete "$gameName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => previous.isEditing != current.isEditing,
      builder: (context, editState) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: const Text('My Games'),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (editState.isEditing)
                TextButton(
                  onPressed: () => context.read<HomeCubit>().exitEditMode(),
                  child: const Text('Done'),
                )
              else
                HomeOverflowMenu(
                ),
            ],
          ),
          body: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == HomeStatus.error) {
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Something went wrong',
                    style: TextStyle(color: colorScheme.error),
                  ),
                );
              }

              if (state.games.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_esports_outlined,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No games yet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to create your first game',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.games.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final gameWithCount = state.games[index];
                  return GameCard(
                    gameWithPlayerCount: gameWithCount,
                    isEditing: state.isEditing,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.scoring,
                        arguments: gameWithCount.game.id,
                      );
                    },
                    onLongPress: () {
                      context.read<HomeCubit>().toggleEditMode();
                    },
                    onDelete: () async {
                      final confirmed = await _showDeleteConfirmation(
                        context,
                        gameWithCount.game.name,
                      );
                      if (confirmed && context.mounted) {
                        context.read<HomeCubit>().deleteGame(
                          gameWithCount.game.id,
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: editState.isEditing
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.createGame);
                  },
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}
