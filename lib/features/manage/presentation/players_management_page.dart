import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/common/ui/widgets/search_scaffold.dart';
import 'package:scoreio/features/manage/data/players_management_repository.dart';
import 'package:scoreio/features/manage/presentation/cubit/players_management_cubit.dart';
import 'package:scoreio/features/manage/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:scoreio/features/manage/presentation/widgets/edit_player_dialog.dart';

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

    return BlocListener<PlayersManagementCubit, PlayersManagementState>(
      listenWhen: (prev, curr) => prev.snackbarMessage != curr.snackbarMessage,
      listener: (context, state) {
        final message = state.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          context.read<PlayersManagementCubit>().clearSnackbar();
        }
      },
      child: BlocBuilder<PlayersManagementCubit, PlayersManagementState>(
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
      ),
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
        return _PlayerCard(
          player: player,
          onTap: () => _showEditPlayerDialog(context, player),
          onDelete: () => _showDeleteConfirmation(context, player),
        );
      },
    );
  }

  Future<void> _showAddPlayerDialog(BuildContext context) async {
    final cubit = context.read<PlayersManagementCubit>();

    final result = await EditPlayerDialog.show(
      context,
      firstName: '',
    );

    if (result != null && context.mounted) {
      unawaited(
        cubit.addPlayer(
          result['firstName']!,
          result['lastName'],
        ),
      );
    }
  }

  Future<void> _showEditPlayerDialog(
    BuildContext context,
    Player player,
  ) async {
    final cubit = context.read<PlayersManagementCubit>();

    final result = await EditPlayerDialog.show(
      context,
      firstName: player.firstName,
      lastName: player.lastName,
    );

    if (result != null && context.mounted) {
      unawaited(
        cubit.updatePlayer(
          player.id,
          result['firstName']!,
          result['lastName'],
        ),
      );
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

    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'Delete Player',
      itemName: displayName,
      description: 'This action cannot be undone.',
    );

    if (confirmed && context.mounted) {
      unawaited(cubit.deletePlayer(player.id));
    }
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    this.onTap,
    this.onDelete,
  });

  final Player player;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  String get _displayName {
    if (player.lastName != null && player.lastName!.isNotEmpty) {
      return '${player.firstName} ${player.lastName}';
    }
    return player.firstName;
  }

  String get _initials {
    final first = player.firstName.isNotEmpty ? player.firstName[0] : '';
    final last = player.lastName?.isNotEmpty ?? false
        ? player.lastName![0]
        : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  _initials.isNotEmpty ? _initials : '?',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Spacing.hGap16,
              Expanded(
                child: Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
