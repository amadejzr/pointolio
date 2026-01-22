import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/common/ui/widgets/game_type_bottom_sheet/game_type_bottom_sheet.dart';
import 'package:scoreio/common/ui/widgets/search_scaffold.dart';
import 'package:scoreio/features/manage/data/game_types_management_repository.dart';
import 'package:scoreio/features/manage/presentation/cubit/game_types_management_cubit.dart';
import 'package:scoreio/features/manage/presentation/widgets/delete_confirmation_dialog.dart';

class GameTypesManagementPage extends StatelessWidget {
  const GameTypesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameTypesManagementCubit(
        repository: locator<GameTypesManagementRepository>(),
      )..loadGameTypes(),
      child: const _GameTypesManagementView(),
    );
  }
}

class _GameTypesManagementView extends StatelessWidget {
  const _GameTypesManagementView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<GameTypesManagementCubit, GameTypesManagementState>(
      listenWhen: (prev, curr) => prev.snackbarMessage != curr.snackbarMessage,
      listener: (context, state) {
        final message = state.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          context.read<GameTypesManagementCubit>().clearSnackbar();
        }
      },
      child: BlocBuilder<GameTypesManagementCubit, GameTypesManagementState>(
        builder: (context, state) {
          return SearchScaffold(
            backgroundColor: cs.surface,
            body: _buildBody(context, state),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddGameTypeDialog(context),
              child: const Icon(Icons.add),
            ),
            title: const Text('Games'),
            onSearchChanged: (value) {
              context.read<GameTypesManagementCubit>().setSearchQuery(value);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, GameTypesManagementState state) {
    final cubit = context.read<GameTypesManagementCubit>();

    if (state.status == GameTypesManagementStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == GameTypesManagementStatus.error) {
      return _ErrorState(
        message: state.errorMessage,
        onRetry: cubit.loadGameTypes,
      );
    }

    final gameTypes = state.filteredGameTypes;

    if (gameTypes.isEmpty) {
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        return _NoSearchResultsState(query: state.searchQuery!);
      }
      return const _EmptyGameTypesState();
    }

    return ListView.separated(
      padding: Spacing.page,
      itemCount: gameTypes.length,
      separatorBuilder: (_, _) => Spacing.gap12,
      itemBuilder: (context, index) {
        final gameType = gameTypes[index];
        return _GameTypeCard(
          gameType: gameType,
          onTap: () => _showEditGameTypeDialog(context, gameType),
          onDelete: () => _showDeleteConfirmation(context, gameType),
        );
      },
    );
  }

  Future<void> _showAddGameTypeDialog(BuildContext context) async {
    final cubit = context.read<GameTypesManagementCubit>();

    final result = await GameTypeBottomSheet.show(context);

    if (result != null && context.mounted) {
      unawaited(
        cubit.addGameType(
          name: result.name,
          lowestScoreWins: result.lowestScoreWins,
          color: result.color,
        ),
      );
    }
  }

  Future<void> _showEditGameTypeDialog(
    BuildContext context,
    GameType gameType,
  ) async {
    final cubit = context.read<GameTypesManagementCubit>();

    final result = await GameTypeBottomSheet.showForEdit(
      context,
      name: gameType.name,
      lowestScoreWins: gameType.lowestScoreWins,
      color: gameType.color,
    );

    if (result != null && context.mounted) {
      unawaited(
        cubit.updateGameType(
          gameType.id,
          name: result.name,
          lowestScoreWins: result.lowestScoreWins,
          color: result.color,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    GameType gameType,
  ) async {
    final cubit = context.read<GameTypesManagementCubit>();

    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'Delete Game Type',
      itemName: gameType.name,
      description: 'This action cannot be undone.',
    );

    if (confirmed && context.mounted) {
      unawaited(cubit.deleteGameType(gameType.id));
    }
  }
}

class _GameTypeCard extends StatelessWidget {
  const _GameTypeCard({
    required this.gameType,
    this.onTap,
    this.onDelete,
  });

  final GameType gameType;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  String get _initial =>
      gameType.name.isNotEmpty ? gameType.name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasColor = gameType.color != null;
    final typeColor = hasColor ? Color(gameType.color!) : cs.primaryContainer;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: Spacing.page,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(12),
                  border: hasColor
                      ? null
                      : Border.all(color: cs.outlineVariant),
                ),
                child: Center(
                  child: hasColor
                      ? Text(
                          _initial,
                          style: tt.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : Icon(
                          Icons.category_outlined,
                          color: cs.onPrimaryContainer,
                        ),
                ),
              ),
              Spacing.hGap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gameType.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Spacing.hGap8,
                        _WinConditionChip(
                          lowestScoreWins: gameType.lowestScoreWins,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacing.hGap12,
              IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinConditionChip extends StatelessWidget {
  const _WinConditionChip({required this.lowestScoreWins});

  final bool lowestScoreWins;

  @override
  Widget build(BuildContext context) {
    final icon = lowestScoreWins ? Icons.arrow_downward : Icons.arrow_upward;
    final color = lowestScoreWins ? Colors.blue : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            lowestScoreWins ? 'Low' : 'High',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGameTypesState extends StatelessWidget {
  const _EmptyGameTypesState();

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
              Icons.category_outlined,
              size: 64,
              color: cs.onSurfaceVariant,
            ),
            Spacing.gap16,
            Text(
              'No game types yet',
              style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Spacing.gap8,
            Text(
              'Tap + to create your first game type',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResultsState extends StatelessWidget {
  const _NoSearchResultsState({required this.query});

  final String query;

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
              Icons.search_off,
              size: 64,
              color: cs.onSurfaceVariant,
            ),
            Spacing.gap16,
            Text(
              'No results found',
              style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Spacing.gap8,
            Text(
              'No game types match "$query"',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
    this.message,
  });

  final VoidCallback onRetry;
  final String? message;

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
              Icons.error_outline,
              size: 64,
              color: cs.error,
            ),
            Spacing.gap16,
            Text(
              'Something went wrong',
              style: tt.titleMedium?.copyWith(color: cs.error),
            ),
            Spacing.gap8,
            Text(
              message ?? 'Unable to load game types',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Spacing.gap16,
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
