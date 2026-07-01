import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/features/manage/data/game_types_management_repository.dart';
import 'package:pointolio/features/manage/presentation/cubit/game_types_management_cubit.dart';
import 'package:pointolio/features/manage/presentation/game_type_form_page.dart';
import 'package:pointolio/features/manage/presentation/widgets/delete_game_dialog.dart';
import 'package:pointolio/features/manage/presentation/widgets/game_tile.dart';
import 'package:pointolio/router/app_router.dart';

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
    // Background + floating bar are provided by HomeShell.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<GameTypesManagementCubit, GameTypesManagementState>(
          builder: (context, state) {
            return Column(
              children: [
                _GamesHeader(count: state.gameTypes.length),
                Expanded(child: _GamesBody(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GamesHeader extends StatelessWidget {
  const _GamesHeader({required this.count});

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
                  child: Text('Games', style: PT.screenTitle(pt.text)),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? 'game' : 'games'} saved',
                  style: PT.caption(pt.textMuted),
                ),
              ],
            ),
          ),
          _AddAction(onTap: () => unawaited(_showAddGameTypeDialog(context))),
        ],
      ),
    );
  }
}

class _AddAction extends StatelessWidget {
  const _AddAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Pressable(
      onTap: onTap,
      scale: 0.92,
      isButton: true,
      semanticLabel: 'Add game',
      excludeChildSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
    );
  }
}

class _GamesBody extends StatelessWidget {
  const _GamesBody({required this.state});

  final GameTypesManagementState state;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final cubit = context.read<GameTypesManagementCubit>();

    if (state.status == GameTypesManagementStatus.loading) {
      return Center(child: CircularProgressIndicator(color: pt.accent));
    }

    if (state.status == GameTypesManagementStatus.error) {
      return _ErrorState(
        message: state.errorMessage,
        onRetry: cubit.loadGameTypes,
      );
    }

    final gameTypes = state.gameTypes;

    if (gameTypes.isEmpty) {
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
      itemCount: gameTypes.length,
      itemBuilder: (context, i) {
        final gameType = gameTypes[i];
        return AnimatedEntrance(
          delay: Duration(milliseconds: 50 * i),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GameTile(
              gameType: gameType,
              onEdit: () =>
                  unawaited(_showEditGameTypeDialog(context, gameType)),
              onDelete: () =>
                  unawaited(_showDeleteConfirmation(context, gameType)),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showAddGameTypeDialog(BuildContext context) async {
  final cubit = context.read<GameTypesManagementCubit>();

  final input = await context.push<GameTypeResult>(AppRouter.gameTypeForm);

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

  final input = await context.push<GameTypeResult>(
    AppRouter.gameTypeForm,
    extra: gameType,
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

  final confirmed = await showDeleteGameDialog(
    context,
    gameName: gameType.name,
  );

  if (confirmed && context.mounted) {
    final result = await cubit.deleteGameType(gameType.id);
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
              Icons.category_outlined,
              size: 56,
              color: pt.textFaint,
              semanticLabel: 'No games',
            ),
            const SizedBox(height: S.lg),
            Semantics(
              header: true,
              child: Text('No games yet', style: PT.sectionTitle(pt.text)),
            ),
            const SizedBox(height: S.xs),
            Text(
              'Tap Add to save your first game',
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
              message ?? 'Unable to load games',
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
