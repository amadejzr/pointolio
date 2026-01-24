import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/common/ui/widgets/confirm_dialog.dart';
import 'package:pointolio/common/ui/widgets/game_type_bottom_sheet/game_type_bottom_sheet.dart';
import 'package:pointolio/common/ui/widgets/game_type_widgets.dart';
import 'package:pointolio/common/ui/widgets/search_scaffold.dart';
import 'package:pointolio/features/manage/data/game_types_management_repository.dart';
import 'package:pointolio/features/manage/presentation/cubit/game_types_management_cubit.dart';

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

    return BlocBuilder<GameTypesManagementCubit, GameTypesManagementState>(
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
        return GameTypeItem(
          gameType: gameType,
          showDelete: true,
          onTap: () => _showEditGameTypeDialog(context, gameType),
          onDelete: () => _showDeleteConfirmation(context, gameType),
        );
      },
    );
  }

  Future<void> _showAddGameTypeDialog(BuildContext context) async {
    final cubit = context.read<GameTypesManagementCubit>();

    final input = await GameTypeBottomSheet.show(context);

    if (input != null && context.mounted) {
      final result = await cubit.addGameType(
        name: input.name,
        lowestScoreWins: input.lowestScoreWins,
        color: input.color,
      );
      if (context.mounted) result.showToast(context);
    }
  }

  Future<void> _showEditGameTypeDialog(
    BuildContext context,
    GameType gameType,
  ) async {
    final cubit = context.read<GameTypesManagementCubit>();

    final input = await GameTypeBottomSheet.showForEdit(
      context,
      name: gameType.name,
      lowestScoreWins: gameType.lowestScoreWins,
      color: gameType.color,
    );

    if (input != null && context.mounted) {
      final result = await cubit.updateGameType(
        gameType.id,
        name: input.name,
        lowestScoreWins: input.lowestScoreWins,
        color: input.color,
      );
      if (context.mounted) result.showToast(context);
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    GameType gameType,
  ) async {
    final cubit = context.read<GameTypesManagementCubit>();

    final confirmed = await ConfirmDialog.showDelete(
      context,
      title: 'Delete Game',
      itemName: gameType.name,
      description: 'This action cannot be undone.',
    );

    if (confirmed && context.mounted) {
      final result = await cubit.deleteGameType(gameType.id);
      if (context.mounted) result.showToast(context);
    }
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
              'No games',
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
