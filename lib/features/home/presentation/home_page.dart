import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/common/ui/widgets/confirm_dialog.dart';
import 'package:scoreio/common/ui/widgets/toast_message.dart';
import 'package:scoreio/features/home/data/home_repository.dart';
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
          HomeCubit(homeRepository: locator<HomeRepository>())..loadGames(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (prev, curr) => prev.snackbarMessage != curr.snackbarMessage,
      listener: (context, state) {
        final message = state.snackbarMessage;
        if (message != null) {
          ToastMessage.error(context, message);
          context.read<HomeCubit>().clearSnackbar();
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();

          return Scaffold(
            backgroundColor: cs.surface,
            appBar: AppBar(
              title: const Text('My Parties'),
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
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<HomeCubit>();

    if (state.status == HomeStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HomeStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.errorMessage ?? 'Something went wrong',
              style: TextStyle(color: cs.error),
            ),
            Spacing.gap16,
            FilledButton.tonal(
              onPressed: cubit.loadGames,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.games.isEmpty) {
      return const _EmptyGamesState();
    }

    final activeGames = state.games
        .where((g) => g.game.finishedAt == null)
        .toList();
    final completedGames = state.games
        .where((g) => g.game.finishedAt != null)
        .toList();

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: Spacing.page,
      children: [
        // ===== Active =====
        if (activeGames.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeGames.length,
            separatorBuilder: (_, _) => Spacing.gap12,
            itemBuilder: (context, index) {
              final gameWithCount = activeGames[index];
              final game = gameWithCount.game;

              return GameCard(
                gameWithPlayerCount: gameWithCount,
                isEditing: state.isEditing,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.scoring,
                  arguments: game.id,
                ),
                onLongPress: cubit.toggleEditMode,
                isFinished: game.finishedAt != null,
                onDelete: () async {
                  final confirmed = await ConfirmDialog.showDelete(
                    context,
                    title: 'Delete Party',
                    itemName: game.name,
                  );
                  if (confirmed && context.mounted) {
                    unawaited(cubit.deleteGame(game.id));
                  }
                },
                onToggleFinished: () {
                  final isFinished = game.finishedAt != null;
                  unawaited(
                    cubit.setFinished(
                      game.id,
                      isFinished: !isFinished,
                    ),
                  );
                },
              );
            },
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              completedGames.isNotEmpty
                  ? 'No active parties'
                  : 'No parties yet',
              style: tt.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // ===== Completed (collapsed by default) =====
        if (completedGames.isNotEmpty) ...[
          if (activeGames.isNotEmpty) Spacing.gap24 else Spacing.gap12,
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: cubit.toggleShowCompleted,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  Text(
                    'Completed (${completedGames.length})',
                    style: tt.titleSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 160),
                    turns: state.showCompleted ? 0.5 : 0.0,
                    child: Icon(
                      Icons.expand_more,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (state.showCompleted) ...[
            Spacing.gap12,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: completedGames.length,
              separatorBuilder: (_, _) => Spacing.gap12,
              itemBuilder: (context, index) {
                final gameWithCount = completedGames[index];
                final game = gameWithCount.game;

                return GameCard(
                  gameWithPlayerCount: gameWithCount,
                  isEditing: state.isEditing,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.scoring,
                    arguments: game.id,
                  ),
                  onLongPress: cubit.toggleEditMode,
                  isFinished: game.finishedAt != null,
                  onDelete: () async {
                    final confirmed = await ConfirmDialog.showDelete(
                      context,
                      title: 'Delete Party',
                      itemName: game.name,
                    );
                    if (confirmed && context.mounted) {
                      unawaited(cubit.deleteGame(game.id));
                    }
                  },
                  onToggleFinished: () {
                    final isFinished = game.finishedAt != null;
                    unawaited(
                      cubit.setFinished(
                        game.id,
                        isFinished: !isFinished,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ],
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
              'No parties yet',
              style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Spacing.gap8,
            Text(
              'Tap + to create your first party',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
