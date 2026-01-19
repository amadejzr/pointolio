import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/data/repositories/game_type_repository.dart';
import 'package:scoreio/common/data/repositories/player_repository.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/features/create_game/presentation/cubit/create_game_cubit.dart';
import 'package:scoreio/features/create_game/presentation/cubit/create_game_state.dart';
import 'package:scoreio/features/create_game/presentation/widgets/game_type_picker_sheet.dart';
import 'package:scoreio/common/ui/widgets/picker_sheet.dart';
import 'package:scoreio/features/create_game/presentation/widgets/add_player_dialog.dart';
import 'package:scoreio/features/create_game/presentation/widgets/new_game_type_bottom_sheet/new_game_type_bottom_sheet.dart';

class CreateGamePage extends StatelessWidget {
  const CreateGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateGameCubit(
        gameTypeRepository: locator<GameTypeRepository>(),
        playerRepository: locator<PlayerRepository>(),
        gameRepository: locator<GameRepository>(),
      )..loadData(),
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
      listener: (context, state) {
        if (state.status == CreateGameStatus.success &&
            state.createdGameId != null) {
          Navigator.pushReplacementNamed(
            context,
            '/scoring',
            arguments: state.createdGameId,
          );
        } else if (state.status == CreateGameStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateGameCubit>();

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: const Text('New Game'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Name
                const _SectionLabel(label: 'Game Name'),
                const SizedBox(height: 8),
                TextField(
                  controller: _gameNameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Friday Night #1',
                  ),
                  onChanged: cubit.setGameName,
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 24),

                // Game Type (picker sheet)
                const _SectionLabel(label: 'Game Type'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GameTypePickerField(
                        gameType: state.selectedGameType,
                        onTap: () async {
                          final selected = await GameTypePickerSheet.show(
                            context,
                            gameTypes: state.availableGameTypes,
                          );
                          if (selected != null) cubit.setGameType(selected);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: () => _showAddGameTypeDialog(context, cubit),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Players
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionLabel(label: 'Players'),
                    Text(
                      '${state.selectedPlayers.length} added',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        value: '',
                        placeholder: 'Add player',
                        leading: Icons.person_outline,
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
                          );
                          if (selected != null) cubit.addPlayer(selected);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: () => _showAddPlayerDialog(context, cubit),
                      icon: const Icon(Icons.person_add),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

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
                      // subtle lift, no wild scaling
                      return Material(
                        color: Colors.transparent,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                                color: Colors.black.withOpacity(0.12),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      );
                    },
                    itemBuilder: (context, index) {
                      final player = state.selectedPlayers[index];
                      return _PlayerTile(
                        key: ValueKey(player.id),
                        player: player,
                        index: index,
                        onRemove: () => cubit.removePlayer(player.id),
                      );
                    },
                  ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed:
                    state.isValid && state.status != CreateGameStatus.loading
                    ? cubit.createGame
                    : null,
                child: state.status == CreateGameStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Start Game'),
              ),
            ),
          ),
        );
      },
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
    final result = await NewGameTypeBottomSheet.show(context);

    if (result != null && result.name.trim().isNotEmpty) {
      cubit.addNewGameType(
        result.name,
        lowestScoreWins: result.lowestScoreWins,
        color: result.color,
      );
    }
  }

  Future<void> _showAddPlayerDialog(
    BuildContext context,
    CreateGameCubit cubit,
  ) async {
    final result = await AddPlayerDialog.show(context);

    if (result != null && (result['firstName'] ?? '').trim().isNotEmpty) {
      cubit.addNewPlayer(result['firstName']!, result['lastName']);
    }
  }
}

// ========================= PICKER FIELD =========================

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.leading,
  });

  final String value; // e.g. "Rummy"
  final String placeholder; // e.g. "Choose…"
  final VoidCallback onTap;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasValue = value.trim().isNotEmpty;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(leading, size: 18, color: cs.primary),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  hasValue ? value : placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: hasValue ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================= GAME TYPE PICKER FIELD =========================

class _GameTypePickerField extends StatelessWidget {
  const _GameTypePickerField({required this.gameType, required this.onTap});

  final GameType? gameType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasValue = gameType != null;
    final hasColor = gameType?.color != null;
    final color = hasColor ? Color(gameType!.color!) : cs.primary;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: hasValue && hasColor
                      ? color
                      : cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: hasValue && !hasColor
                      ? Border.all(color: cs.outlineVariant)
                      : null,
                ),
                child: Center(
                  child: hasValue && hasColor
                      ? Text(
                          gameType!.name.isNotEmpty
                              ? gameType!.name[0].toUpperCase()
                              : '?',
                          style: tt.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : Icon(
                          Icons.category_outlined,
                          size: 18,
                          color: hasValue ? cs.onSurfaceVariant : cs.primary,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasValue ? gameType!.name : 'Choose game type',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: hasValue ? cs.onSurface : cs.onSurfaceVariant,
                      ),
                    ),
                    if (hasValue) ...[
                      const SizedBox(height: 2),
                      Text(
                        gameType!.lowestScoreWins
                            ? 'Lowest wins'
                            : 'Highest wins',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================= UI BITS =========================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _EmptyPlayersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 40, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
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

class _PlayerTile extends StatelessWidget {
  final Player player;
  final int index;
  final VoidCallback onRemove;

  const _PlayerTile({
    super.key,
    required this.player,
    required this.index,
    required this.onRemove,
  });

  String get _displayName {
    if (player.lastName != null && player.lastName!.isNotEmpty) {
      return '${player.firstName} ${player.lastName}';
    }
    return player.firstName;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(
            player.firstName.isNotEmpty
                ? player.firstName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(_displayName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.close, color: cs.error),
              onPressed: onRemove,
            ),
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
