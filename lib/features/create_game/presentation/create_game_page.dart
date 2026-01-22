import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/common/ui/widgets/game_type_bottom_sheet/game_type_bottom_sheet.dart';
import 'package:scoreio/common/ui/widgets/game_type_widgets.dart';
import 'package:scoreio/common/ui/widgets/picker_sheet.dart';
import 'package:scoreio/common/ui/widgets/player_bottom_sheet/player_bottom_sheet_exports.dart';
import 'package:scoreio/common/ui/widgets/player_item_widget.dart';
import 'package:scoreio/features/create_game/data/create_game_repository.dart';
import 'package:scoreio/features/create_game/presentation/cubit/create_game_cubit.dart';
import 'package:scoreio/features/create_game/presentation/cubit/create_game_state.dart';
import 'package:scoreio/features/create_game/presentation/widgets/picker_field_widget.dart';

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
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CreateGameCubit, CreateGameState>(
      listenWhen: (prev, curr) =>
          prev.snackbarMessage != curr.snackbarMessage ||
          (curr.status == CreateGameStatus.success &&
              curr.createdGameId != null),
      listener: (context, state) {
        if (state.status == CreateGameStatus.success &&
            state.createdGameId != null) {
          unawaited(
            Navigator.pushReplacementNamed(
              context,
              '/scoring',
              arguments: state.createdGameId,
            ),
          );
          return;
        }

        final message = state.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          context.read<CreateGameCubit>().clearSnackbar();
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateGameCubit>();

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: const Text('New Party'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _buildBody(context, state, cubit, cs),
          bottomNavigationBar: state.status == CreateGameStatus.error
              ? null
              : SafeArea(
                  child: Padding(
                    padding: Spacing.page,
                    child: ElevatedButton(
                      onPressed:
                          state.isValid &&
                              state.status != CreateGameStatus.loading
                          ? cubit.createGame
                          : null,
                      child: state.status == CreateGameStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Start Party'),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CreateGameState state,
    CreateGameCubit cubit,
    ColorScheme cs,
  ) {
    if (state.status == CreateGameStatus.loading &&
        state.availableGameTypes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CreateGameStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: cs.error),
              Spacing.gap16,
              Text(
                state.errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.error),
              ),
              Spacing.gap16,
              FilledButton.tonal(
                onPressed: cubit.loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: Spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Name
          const _SectionLabel(label: 'Party name'),
          Spacing.gap8,
          TextField(
            controller: _gameNameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Friday Night #1',
            ),
            onChanged: cubit.setGameName,
            textCapitalization: TextCapitalization.words,
          ),

          Spacing.gap24,

          // Game Type (picker sheet) + "New" action
          Row(
            children: [
              const _SectionLabel(label: 'Game'),
              const Spacer(),
              TextButton(
                onPressed: () => _showAddGameTypeDialog(context, cubit),
                child: const Text('New'),
              ),
            ],
          ),
          Spacing.gap8,

          if (state.selectedGameType == null)
            PickerFieldBase(
              text: 'Choose game',
              icon: Icons.category_outlined,
              onTap: () async {
                final selected = await PickerSheet.show<GameType>(
                  context: context,
                  title: 'Games',
                  items: state.availableGameTypes,
                  itemLabel: (t) => t.name,
                  itemKey: (t) => t.id,
                  itemBuilder: (context, t) => GameTypeItem(gameType: t),
                  emptyTitle: 'No game types found',
                  emptySubtitle: 'Create one with New.',
                );
                if (selected != null) cubit.setGameType(selected);
              },
            )
          else
            GameTypeItem(
              gameType: state.selectedGameType!,
              showChevron: true,
              onTap: () async {
                final selected = await PickerSheet.show<GameType>(
                  context: context,
                  title: 'Games',
                  items: state.availableGameTypes,
                  itemLabel: (t) => t.name,
                  itemKey: (t) => t.id,
                  itemBuilder: (context, t) => GameTypeItem(gameType: t),
                  emptyTitle: 'No game types found',
                  emptySubtitle: 'Create one with New.',
                );
                if (selected != null) cubit.setGameType(selected);
              },
            ),

          Spacing.gap24,

          // Players + "New" action (count moved out)
          Row(
            children: [
              const _SectionLabel(label: 'Players'),
              const Spacer(),
              TextButton(
                onPressed: () => _showAddPlayerDialog(context, cubit),
                child: const Text('New'),
              ),
            ],
          ),
          Spacing.gap8,

          PickerFieldBase(
            text: 'Add player',
            icon: Icons.person_outline,
            onTap: () async {
              final remaining = state.availablePlayers
                  .where(
                    (p) => !state.selectedPlayers.any(
                      (sp) => sp.id == p.id,
                    ),
                  )
                  .toList();

              final selected = await PickerSheet.show<Player>(
                context: context,
                title: 'Players',
                items: remaining,
                itemLabel: _playerDisplayName,
                itemBuilder: (context, player) => PlayerItem(
                  player: player,
                ),
              );
              if (selected != null) cubit.addPlayer(selected);
            },
          ),

          Spacing.gap16,

          // Players List
          if (state.selectedPlayers.isEmpty)
            _EmptyPlayersCard()
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.selectedPlayers.length,
              onReorder: cubit.reorderPlayers,
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 16,
                          offset: Offset(0, 10),
                          color: Color(0x1F000000),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
              itemBuilder: (context, index) {
                final player = state.selectedPlayers[index];
                return Padding(
                  key: ValueKey(player.id),
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: PlayerItem(
                    player: player,
                    reorderIndex: index,
                    onRemove: () => cubit.removePlayer(player.id),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _playerDisplayName(Player player) {
    if (player.lastName != null && player.lastName!.isNotEmpty) {
      return '${player.firstName} ${player.lastName}';
    }
    return player.firstName;
  }

  Future<void> _showAddGameTypeDialog(
    BuildContext context,
    CreateGameCubit cubit,
  ) async {
    final result = await GameTypeBottomSheet.show(context);

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

  Future<void> _showAddPlayerDialog(
    BuildContext context,
    CreateGameCubit cubit,
  ) async {
    final result = await PlayerBottomSheet.show(context);

    if (result != null) {
      unawaited(
        cubit.addNewPlayer(
          result.firstName,
          result.lastName,
          result.color,
        ),
      );
    }
  }
}

// ========================= UI BITS =========================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptyPlayersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 40, color: cs.onSurfaceVariant),
          Spacing.gap8,
          Text(
            'Add at least 2 players',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
