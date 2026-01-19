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
                      child: _PickerField(
                        value: state.selectedGameType?.name ?? '',
                        placeholder: 'Choose game type',
                        leading: Icons.category_outlined,
                        onTap: () async {
                          final selected = await _showPickerSheet<GameType>(
                            context: context,
                            title: 'Game types',
                            items: state.availableGameTypes,
                            itemLabel: (t) => t.name,
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

                          final selected = await _showPickerSheet<Player>(
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
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _AddGameTypeDialog(),
    );

    if (result != null && result.trim().isNotEmpty) {
      cubit.addNewGameType(result);
    }
  }

  Future<void> _showAddPlayerDialog(
    BuildContext context,
    CreateGameCubit cubit,
  ) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _AddPlayerDialog(),
    );

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

// ========================= PICKER SHEET =========================

Future<T?> _showPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T item) itemLabel,
  String? emptyTitle,
  String? emptySubtitle,
}) async {
  final cs = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return _PickerSheet<T>(
        title: title,
        items: items,
        itemLabel: itemLabel,
        emptyTitle: emptyTitle,
        emptySubtitle: emptySubtitle,
        cs: cs,
        textTheme: textTheme,
      );
    },
  );
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.cs,
    required this.textTheme,
    this.emptyTitle,
    this.emptySubtitle,
  });

  final String title;
  final List<T> items;
  final String Function(T item) itemLabel;

  final String? emptyTitle;
  final String? emptySubtitle;

  final ColorScheme cs;
  final TextTheme textTheme;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;

    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.items
        : widget.items
              .where((e) => widget.itemLabel(e).toLowerCase().contains(query))
              .toList();

    final height = MediaQuery.sizeOf(context).height;
    final maxHeight = height * 0.82;

    return SizedBox(
      height: maxHeight,
      child: Column(
        children: [
          // top handle + header
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: widget.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? _EmptySheetState(
                    title: widget.emptyTitle ?? 'Nothing here',
                    subtitle:
                        widget.emptySubtitle ?? 'Try changing your search.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final label = widget.itemLabel(item);

                      return Material(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pop<T>(context, item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: widget.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: cs.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptySheetState extends StatelessWidget {
  const _EmptySheetState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 44, color: cs.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
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

// ========================= DIALOGS =========================

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
        decoration: const InputDecoration(hintText: 'Enter game type name'),
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
            decoration: const InputDecoration(hintText: 'First name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(hintText: 'Last name (optional)'),
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
        TextButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
