import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/data/repositories/game_type_repository.dart';
import 'package:scoreio/common/data/repositories/player_repository.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/features/create_game/presentation/cubit/create_game_cubit.dart';
import 'package:scoreio/features/create_game/presentation/cubit/create_game_state.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<CreateGameCubit, CreateGameState>(
      listener: (context, state) {
        if (state.status == CreateGameStatus.success) {
          Navigator.pop(context, state.createdGameId);
        } else if (state.status == CreateGameStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Something went wrong')),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateGameCubit>();

        return Scaffold(
          backgroundColor: colorScheme.surface,
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
                // Game Name Field
                _SectionLabel(label: 'Game Name'),
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

                // Game Type Dropdown
                _SectionLabel(label: 'Game Type'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        key: ValueKey('gameType_${state.availableGameTypes.length}'),
                        value: state.selectedGameType?.id,
                        decoration: const InputDecoration(
                          hintText: 'Select game type',
                        ),
                        items: state.availableGameTypes.map((type) {
                          return DropdownMenuItem(
                            value: type.id,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            final gameType = state.availableGameTypes
                                .firstWhere((t) => t.id == id);
                            cubit.setGameType(gameType);
                          }
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

                // Players Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionLabel(label: 'Players'),
                    Text(
                      '${state.selectedPlayers.length} added',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Player Dropdown + Add Button
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        key: ValueKey('players_${state.availablePlayers.length}_${state.selectedPlayers.length}'),
                        value: null,
                        decoration: const InputDecoration(
                          hintText: 'Add player',
                        ),
                        items: state.availablePlayers
                            .where((p) => !state.selectedPlayers
                                .any((sp) => sp.id == p.id))
                            .map((player) {
                          return DropdownMenuItem(
                            value: player.id,
                            child: Text(_playerDisplayName(player)),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            final player = state.availablePlayers
                                .firstWhere((p) => p.id == id);
                            cubit.addPlayer(player);
                          }
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 40,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add at least 2 players',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.selectedPlayers.length,
                    onReorder: cubit.reorderPlayers,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                        child: child,
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
                onPressed: state.isValid && state.status != CreateGameStatus.loading
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
      BuildContext context, CreateGameCubit cubit) async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _AddGameTypeDialog();
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      cubit.addNewGameType(result);
    }
  }

  Future<void> _showAddPlayerDialog(
      BuildContext context, CreateGameCubit cubit) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return _AddPlayerDialog();
      },
    );

    if (result != null && result['firstName']!.trim().isNotEmpty) {
      cubit.addNewPlayer(result['firstName']!, result['lastName']);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            player.firstName.isNotEmpty ? player.firstName[0].toUpperCase() : '?',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(_displayName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.close, color: colorScheme.error),
              onPressed: onRemove,
            ),
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddGameTypeDialog extends StatefulWidget {
  @override
  State<_AddGameTypeDialog> createState() => _AddGameTypeDialogState();
}

class _AddGameTypeDialogState extends State<_AddGameTypeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Game Type'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter game type name',
        ),
        textCapitalization: TextCapitalization.words,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _AddPlayerDialog extends StatefulWidget {
  @override
  State<_AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<_AddPlayerDialog> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Player'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'First name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              hintText: 'Last name (optional)',
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
