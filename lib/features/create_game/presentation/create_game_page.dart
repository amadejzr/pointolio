import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/form/form.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/notebook_background.dart';
import 'package:pointolio/common/ui/widgets/toast_message.dart';
import 'package:pointolio/features/create_game/data/create_game_repository.dart';
import 'package:pointolio/features/create_game/presentation/cubit/create_game_cubit.dart';
import 'package:pointolio/features/create_game/presentation/cubit/create_game_state.dart';
import 'package:pointolio/features/manage/presentation/game_type_form_page.dart';
import 'package:pointolio/features/manage/presentation/player_form_page.dart';
import 'package:pointolio/router/app_router.dart';

class CreateGamePage extends StatelessWidget {
  const CreateGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CreateGameCubit(
          createGameRepository: locator<CreateGameRepository>(),
        );

        unawaited(cubit.loadData());

        return cubit;
      },
      child: const _CreateGameView(),
    );
  }
}

class _CreateGameView extends StatefulWidget {
  const _CreateGameView();

  @override
  State<_CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<_CreateGameView> {
  final _gameNameController = TextEditingController();

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return BlocConsumer<CreateGameCubit, CreateGameState>(
      listenWhen: (prev, curr) =>
          prev.snackbarMessage != curr.snackbarMessage ||
          (curr.status == CreateGameStatus.success &&
              curr.createdGameId != null),
      listener: (context, state) {
        if (state.status == CreateGameStatus.success &&
            state.createdGameId != null) {
          context.pushReplacement(AppRouter.scoringPath(state.createdGameId!));
          return;
        }

        final message = state.snackbarMessage;
        if (message != null) {
          ToastMessage.error(context, message);
          context.read<CreateGameCubit>().clearSnackbar();
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateGameCubit>();

        return Scaffold(
          backgroundColor: pt.bg,
          body: Stack(
            children: [
              const Positioned.fill(child: NotebookBackground()),
              Column(
                children: [
                  FormAppBar(
                    title: 'New party',
                    onCancel: context.pop,
                    actionLabel: 'Start',
                    actionEnabled: state.isValid,
                    onAction: cubit.createGame,
                  ),
                  Expanded(child: _buildBody(context, state, cubit)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CreateGameState state,
    CreateGameCubit cubit,
  ) {
    final pt = context.pt;

    if (state.status == CreateGameStatus.loading &&
        state.availableGameTypes.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(pt.accent),
        ),
      );
    }

    if (state.status == CreateGameStatus.error) {
      return _ErrorState(
        message: state.errorMessage ?? 'Something went wrong',
        onRetry: cubit.loadData,
      );
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(S.lg, S.sm, S.lg, S.lg),
            children: [
              // Party name
              FormSection(
                label: 'Party name',
                child: PtTextField(
                  controller: _gameNameController,
                  hint: 'e.g. Friday Night #1',
                  semanticLabel: 'Party name',
                  onChanged: cubit.setGameName,
                ),
              ),
              const SectionGap(),

              // Game
              FormSection(
                label: 'Game',
                trailing: _NewTextAction(
                  onTap: () => _showAddGameType(context, cubit),
                ),
                child: GamePickerField(
                  gameType: state.selectedGameType,
                  onTap: () => _pickGame(context, cubit, state),
                ),
              ),
              const SectionGap(),

              // Players
              FormSection(
                label: 'Players',
                trailing: Text(
                  '${state.selectedPlayers.length} added',
                  style: PT.caption(pt.textMuted),
                ),
                child: PlayerSelector(
                  players: state.selectedPlayers,
                  onRemove: (p) => cubit.removePlayer(p.id),
                  onAddExisting: () => _addExisting(context, cubit, state),
                  onNewPlayer: () => _showAddPlayer(context, cubit),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(S.lg, S.sm, S.lg, bottomInset + S.lg),
          child: PrimaryButton(
            label: 'Start party',
            enabled: state.isValid,
            loading: state.status == CreateGameStatus.loading,
            onTap: cubit.createGame,
          ),
        ),
      ],
    );
  }

  Future<void> _pickGame(
    BuildContext context,
    CreateGameCubit cubit,
    CreateGameState state,
  ) async {
    final picked = await GamePickerSheet.show(
      context,
      gameTypes: state.availableGameTypes,
      selected: state.selectedGameType,
    );
    if (picked != null) cubit.setGameType(picked);
  }

  Future<void> _addExisting(
    BuildContext context,
    CreateGameCubit cubit,
    CreateGameState state,
  ) async {
    final pool = state.availablePlayers
        .where((p) => !state.selectedPlayers.any((sp) => sp.id == p.id))
        .toList();

    final toAdd = await ExistingPlayersSheet.show(context, available: pool);
    if (toAdd == null) return;
    toAdd.forEach(cubit.addPlayer);
  }

  Future<void> _showAddGameType(
    BuildContext context,
    CreateGameCubit cubit,
  ) async {
    final result = await context.push<GameTypeResult>(AppRouter.gameTypeForm);

    if (result != null && result.name.trim().isNotEmpty) {
      unawaited(
        cubit.addNewGameType(
          result.name,
          lowestScoreWins: result.lowestScoreWins,
          color: result.color,
        ),
      );
    }
  }

  Future<void> _showAddPlayer(
    BuildContext context,
    CreateGameCubit cubit,
  ) async {
    final result = await context.push<PlayerFormResult>(AppRouter.playerForm);

    if (result != null) {
      unawaited(
        cubit.addNewPlayer(result.firstName, result.lastName, result.color),
      );
    }
  }
}

/// Small "New" text action used next to the Game section label.
class _NewTextAction extends StatelessWidget {
  const _NewTextAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      isButton: true,
      semanticLabel: 'New game',
      excludeChildSemantics: true,
      child: Container(
        // Right-aligned and flush with the content edge so it lines up under
        // the app bar's Start action; the hit target extends to the left.
        constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
        alignment: Alignment.centerRight,
        child: Text(
          'New',
          style: PT.bodyStrong(pt.accent).copyWith(fontSize: 13),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final danger = pt.players[3];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44, color: danger),
            const SizedBox(height: S.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: PT.body(pt.textMuted),
            ),
            const SizedBox(height: S.lg),
            SizedBox(
              width: 160,
              child: PrimaryButton(label: 'Retry', onTap: onRetry),
            ),
          ],
        ),
      ),
    );
  }
}
