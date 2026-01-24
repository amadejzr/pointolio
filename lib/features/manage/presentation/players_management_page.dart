import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/common/ui/widgets/confirm_dialog.dart';
import 'package:pointolio/common/ui/widgets/player_bottom_sheet/player_bottom_sheet_exports.dart';
import 'package:pointolio/common/ui/widgets/player_item_widget.dart';
import 'package:pointolio/common/ui/widgets/search_scaffold.dart';
import 'package:pointolio/features/manage/data/players_management_repository.dart';
import 'package:pointolio/features/manage/presentation/cubit/players_management_cubit.dart';

class PlayersManagementPage extends StatelessWidget {
  const PlayersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayersManagementCubit(
        repository: locator<PlayersManagementRepository>(),
      )..loadPlayers(),
      child: const _PlayersManagementView(),
    );
  }
}

class _PlayersManagementView extends StatelessWidget {
  const _PlayersManagementView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<PlayersManagementCubit, PlayersManagementState>(
      builder: (context, state) {
        return SearchScaffold(
          backgroundColor: cs.surface,
          title: const Text('Players'),
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddPlayerDialog(context),
            child: const Icon(Icons.add),
          ),
          onSearchChanged: context
              .read<PlayersManagementCubit>()
              .setSearchQuery,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PlayersManagementState state) {
    final cubit = context.read<PlayersManagementCubit>();

    if (state.status == PlayersManagementStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PlayersManagementStatus.error) {
      return _ErrorState(
        message: state.errorMessage,
        onRetry: cubit.loadPlayers,
      );
    }

    final players = state.filteredPlayers;

    if (players.isEmpty) {
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        return _NoSearchResultsState(query: state.searchQuery!);
      }
      return const _EmptyPlayersState();
    }

    return ListView.separated(
      padding: Spacing.page,
      itemCount: players.length,
      separatorBuilder: (_, _) => Spacing.gap12,
      itemBuilder: (context, index) {
        final player = players[index];
        return PlayerItem(
          player: player,
          onTap: () => _showEditPlayerDialog(context, player),
          onDelete: () => _showDeleteConfirmation(context, player),
        );
      },
    );
  }

  Future<void> _showAddPlayerDialog(BuildContext context) async {
    final cubit = context.read<PlayersManagementCubit>();

    final input = await PlayerBottomSheet.show(context);

    if (input != null && context.mounted) {
      final result = await cubit.addPlayer(
        input.firstName,
        input.lastName,
        input.color,
      );
      if (context.mounted) result.showToast(context);
    }
  }

  Future<void> _showEditPlayerDialog(
    BuildContext context,
    Player player,
  ) async {
    final cubit = context.read<PlayersManagementCubit>();

    final input = await PlayerBottomSheet.showForEdit(
      context,
      firstName: player.firstName,
      lastName: player.lastName,
      color: player.color,
    );

    if (input != null && context.mounted) {
      final result = await cubit.updatePlayer(
        player.id,
        input.firstName,
        input.lastName,
        input.color,
      );
      if (context.mounted) result.showToast(context);
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Player player,
  ) async {
    final cubit = context.read<PlayersManagementCubit>();
    final displayName = player.lastName != null
        ? '${player.firstName} ${player.lastName}'
        : player.firstName;

    final confirmed = await ConfirmDialog.showDelete(
      context,
      title: 'Delete Player',
      itemName: displayName,
      description: 'This action cannot be undone.',
    );

    if (confirmed && context.mounted) {
      final result = await cubit.deletePlayer(player.id);
      if (context.mounted) result.showToast(context);
    }
  }
}

class _EmptyPlayersState extends StatelessWidget {
  const _EmptyPlayersState();

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
              Icons.people_outline,
              size: 64,
              color: cs.onSurfaceVariant,
            ),
            Spacing.gap16,
            Text(
              'No players yet',
              style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Spacing.gap8,
            Text(
              'Tap + to add your first player',
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
              'No players match "$query"',
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
              message ?? 'Unable to load players',
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
