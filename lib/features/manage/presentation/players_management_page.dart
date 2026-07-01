import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/features/manage/data/players_management_repository.dart';
import 'package:pointolio/features/manage/presentation/cubit/players_management_cubit.dart';
import 'package:pointolio/features/manage/presentation/player_form_page.dart';
import 'package:pointolio/features/manage/presentation/widgets/delete_player_dialog.dart';
import 'package:pointolio/features/manage/presentation/widgets/player_tile.dart';
import 'package:pointolio/router/app_router.dart';

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
    // Background + floating bar are provided by HomeShell.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<PlayersManagementCubit, PlayersManagementState>(
          builder: (context, state) {
            return Column(
              children: [
                _PlayersHeader(count: state.players.length),
                Expanded(child: _PlayersBody(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlayersHeader extends StatelessWidget {
  const _PlayersHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(S.lg, S.sm, S.lg, S.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text('Players', style: PT.screenTitle(pt.text)),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? 'person' : 'people'}',
                  style: PT.caption(pt.textMuted),
                ),
              ],
            ),
          ),
          Pressable(
            onTap: () => unawaited(_showAddPlayerDialog(context)),
            scale: 0.92,
            isButton: true,
            semanticLabel: 'Add player',
            excludeChildSemantics: true,
            // 48px min hit target for comfortable tapping / a11y.
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: pt.accent),
                    const SizedBox(width: 3),
                    Text(
                      'Add',
                      style: PT.bodyStrong(pt.accent).copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersBody extends StatelessWidget {
  const _PlayersBody({required this.state});

  final PlayersManagementState state;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final cubit = context.read<PlayersManagementCubit>();

    if (state.status == PlayersManagementStatus.loading) {
      return Center(child: CircularProgressIndicator(color: pt.accent));
    }

    if (state.status == PlayersManagementStatus.error) {
      return _ErrorState(
        message: state.errorMessage,
        onRetry: cubit.loadPlayers,
      );
    }

    final players = state.players;

    if (players.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        S.lg,
        0,
        S.lg,
        MediaQuery.paddingOf(context).bottom + S.md,
      ),
      itemCount: players.length,
      itemBuilder: (context, i) => AnimatedEntrance(
        delay: Duration(milliseconds: 50 * i),
        child: Padding(
          padding: const EdgeInsets.only(bottom: S.sm),
          child: PlayerTile(
            player: players[i],
            colorIndex: i,
            onEdit: () => unawaited(_showEditPlayerDialog(context, players[i])),
            onDelete: () =>
                unawaited(_showDeletePlayerDialog(context, players[i])),
          ),
        ),
      ),
    );
  }
}

Future<void> _showAddPlayerDialog(BuildContext context) async {
  final cubit = context.read<PlayersManagementCubit>();

  final input = await context.push<PlayerFormResult>(AppRouter.playerForm);

  if (input != null && context.mounted) {
    final result = await cubit.addPlayer(
      input.firstName,
      input.lastName,
      input.color,
    );
    if (context.mounted) result.showToast(context);
  }
}

Future<void> _showEditPlayerDialog(BuildContext context, Player player) async {
  final cubit = context.read<PlayersManagementCubit>();

  final input = await context.push<PlayerFormResult>(
    AppRouter.playerForm,
    extra: player,
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

Future<void> _showDeletePlayerDialog(
  BuildContext context,
  Player player,
) async {
  final cubit = context.read<PlayersManagementCubit>();
  final displayName = player.lastName != null && player.lastName!.isNotEmpty
      ? '${player.firstName} ${player.lastName}'
      : player.firstName;

  final confirmed = await showDeletePlayerDialog(
    context,
    playerName: displayName,
  );

  if (confirmed && context.mounted) {
    final result = await cubit.deletePlayer(player.id);
    if (context.mounted) result.showToast(context);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 56,
              color: pt.textFaint,
              semanticLabel: 'No players',
            ),
            const SizedBox(height: S.lg),
            Semantics(
              header: true,
              child: Text('No players yet', style: PT.sectionTitle(pt.text)),
            ),
            const SizedBox(height: S.xs),
            Text(
              'Tap ＋ to add your first player',
              style: PT.body(pt.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: pt.players[3],
              semanticLabel: 'Error',
            ),
            const SizedBox(height: S.lg),
            Semantics(
              header: true,
              child: Text(
                'Something went wrong',
                style: PT.sectionTitle(pt.text),
              ),
            ),
            const SizedBox(height: S.xs),
            Text(
              message ?? 'Unable to load players',
              style: PT.body(pt.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: S.lg),
            Pressable(
              onTap: onRetry,
              scale: 0.94,
              isButton: true,
              semanticLabel: 'Retry',
              excludeChildSemantics: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: S.xl,
                  vertical: S.md,
                ),
                decoration: BoxDecoration(
                  color: pt.accentTint,
                  borderRadius: BorderRadius.circular(R.md),
                ),
                child: Text('Retry', style: PT.bodyStrong(pt.accent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
