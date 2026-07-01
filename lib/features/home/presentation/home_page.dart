import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/toast_message.dart';
import 'package:pointolio/features/home/data/home_repository.dart';
import 'package:pointolio/features/home/presentation/cubit/home_cubit.dart';
import 'package:pointolio/features/home/presentation/cubit/home_state.dart';
import 'package:pointolio/features/home/presentation/widgets/delete_party_dialog.dart';
import 'package:pointolio/features/home/presentation/widgets/party_card.dart';
import 'package:pointolio/router/app_router.dart';

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
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (prev, curr) => prev.snackbarMessage != curr.snackbarMessage,
      listener: (context, state) {
        final message = state.snackbarMessage;
        if (message != null) {
          ToastMessage.error(context, message);
          context.read<HomeCubit>().clearSnackbar();
        }
      },
      // Background + floating bar are provided by HomeShell.
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return Column(
                children: [
                  _PartiesHeader(state: state),
                  Expanded(child: _HomeBody(state: state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PartiesHeader extends StatelessWidget {
  const _PartiesHeader({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    final active = state.games.where((g) => g.game.finishedAt == null).length;
    final finished = state.games
        .where((g) => g.game.finishedAt != null)
        .length;

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
                  child: Text('Parties', style: PT.screenTitle(pt.text)),
                ),
                const SizedBox(height: 2),
                Text(
                  '$active active · $finished finished',
                  style: PT.caption(pt.textMuted),
                ),
              ],
            ),
          ),
          Pressable(
            onTap: () => unawaited(context.push(AppRouter.settings)),
            scale: 0.9,
            isButton: true,
            semanticLabel: 'Settings',
            excludeChildSemantics: true,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: pt.surface,
                shape: BoxShape.circle,
                border: Border.all(color: pt.border),
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 19,
                color: pt.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final cubit = context.read<HomeCubit>();

    if (state.status == HomeStatus.loading) {
      return Center(child: CircularProgressIndicator(color: pt.accent));
    }

    if (state.status == HomeStatus.error) {
      return _ErrorState(
        message: state.errorMessage,
        onRetry: cubit.loadGames,
      );
    }

    if (state.games.isEmpty) {
      return const _EmptyState();
    }

    final activeGames = state.games
        .where((g) => g.game.finishedAt == null)
        .toList();
    final completedGames = state.games
        .where((g) => g.game.finishedAt != null)
        .toList();

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        S.lg,
        0,
        S.lg,
        MediaQuery.paddingOf(context).bottom + S.md,
      ),
      children: [
        if (activeGames.isNotEmpty)
          for (var i = 0; i < activeGames.length; i++)
            AnimatedEntrance(
              delay: Duration(milliseconds: 60 * i),
              child: Padding(
                padding: const EdgeInsets.only(bottom: S.md),
                child: _buildCard(context, activeGames[i]),
              ),
            )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              completedGames.isNotEmpty
                  ? 'No active parties'
                  : 'No parties yet',
              style: PT.bodyStrong(pt.textMuted),
            ),
          ),
        if (completedGames.isNotEmpty) ...[
          const SizedBox(height: S.sm),
          _CompletedHeader(
            count: completedGames.length,
            expanded: state.showCompleted,
            onTap: cubit.toggleShowCompleted,
          ),
          if (state.showCompleted) ...[
            const SizedBox(height: S.md),
            for (var i = 0; i < completedGames.length; i++)
              AnimatedEntrance(
                delay: Duration(milliseconds: 40 * i),
                offsetY: 8,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: S.md),
                  child: _buildCard(context, completedGames[i]),
                ),
              ),
          ],
        ],
      ],
    );
  }

  Widget _buildCard(BuildContext context, GameWithPlayerCount gameWithCount) {
    final cubit = context.read<HomeCubit>();
    final game = gameWithCount.game;
    final isFinished = game.finishedAt != null;

    return PartyCard(
      gameWithPlayerCount: gameWithCount,
      isFinished: isFinished,
      onTap: () => unawaited(context.push(AppRouter.scoringPath(game.id))),
      onToggleFinished: () => unawaited(
        cubit.setFinished(game.id, isFinished: !isFinished),
      ),
      onDelete: () async {
        final confirmed = await showDeletePartyDialog(
          context,
          partyName: game.name,
        );
        if (confirmed && context.mounted) {
          unawaited(cubit.deleteGame(game.id));
        }
      },
    );
  }
}

class _CompletedHeader extends StatelessWidget {
  const _CompletedHeader({
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Pressable(
      onTap: onTap,
      scale: 0.98,
      isButton: true,
      semanticLabel: '$count completed ${count == 1 ? 'party' : 'parties'}',
      semanticHint: expanded ? 'Collapse' : 'Expand',
      excludeChildSemantics: true,
      child: Column(
        children: [
          Divider(height: 1, thickness: 1, color: pt.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Row(
              children: [
                Text('COMPLETED', style: PT.label(pt.textMuted)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: pt.surfaceMuted,
                    borderRadius: BorderRadius.circular(R.pill),
                  ),
                  child: Text('$count', style: PT.chip(pt.textMuted)),
                ),
                const Spacer(),
                AnimatedRotation(
                  duration: Motion.base,
                  turns: expanded ? 0.5 : 0,
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: pt.textMuted,
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
              Icons.celebration_outlined,
              size: 56,
              color: pt.textFaint,
              semanticLabel: 'No parties',
            ),
            const SizedBox(height: S.lg),
            Semantics(
              header: true,
              child: Text('No parties yet', style: PT.sectionTitle(pt.text)),
            ),
            const SizedBox(height: S.xs),
            Text(
              'Tap ＋ to start your first party',
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
              message ?? 'Unable to load parties',
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
