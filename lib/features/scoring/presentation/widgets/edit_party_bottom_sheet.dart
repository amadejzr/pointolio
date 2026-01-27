import 'package:flutter/material.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/common/ui/widgets/picker_sheet.dart';
import 'package:pointolio/common/ui/widgets/player_item_widget.dart';
import 'package:pointolio/common/ui/widgets/toast_message.dart';

/// Result data returned from EditPartyBottomSheet.
class EditPartyResult {
  EditPartyResult({
    required this.name,
    required this.players,
  });

  final String name;
  final List<Player> players;
}

/// A bottom sheet for editing a party/game's name and player list.
///
/// Supports:
/// - Editing party name
/// - Reordering players
/// - Adding players from available player list
/// - Removing players from the party
///
/// Returns [EditPartyResult] when saved, or null if cancelled.
class EditPartyBottomSheet extends StatelessWidget {
  const EditPartyBottomSheet._({
    required this.initialName,
    required this.initialPlayers,
    required this.availablePlayers,
  });

  final String initialName;
  final List<Player> initialPlayers;
  final List<Player> availablePlayers;

  /// Shows the edit party bottom sheet.
  ///
  /// [context] - The build context
  /// [initialName] - The current party name
  /// [initialPlayers] - The current list of players in the party
  /// [availablePlayers] - All available players that can be added
  ///
  /// Returns [EditPartyResult] if saved, null if cancelled.
  static Future<EditPartyResult?> show(
    BuildContext context, {
    required String initialName,
    required List<Player> initialPlayers,
    required List<Player> availablePlayers,
  }) {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet<EditPartyResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => EditPartyBottomSheet._(
        initialName: initialName,
        initialPlayers: initialPlayers,
        availablePlayers: availablePlayers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _EditPartyContent(
      initialName: initialName,
      initialPlayers: initialPlayers,
      availablePlayers: availablePlayers,
    );
  }
}

class _EditPartyContent extends StatefulWidget {
  const _EditPartyContent({
    required this.initialName,
    required this.initialPlayers,
    required this.availablePlayers,
  });

  final String initialName;
  final List<Player> initialPlayers;
  final List<Player> availablePlayers;

  @override
  State<_EditPartyContent> createState() => _EditPartyContentState();
}

class _EditPartyContentState extends State<_EditPartyContent> {
  late final TextEditingController _nameController;
  late List<Player> _selectedPlayers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedPlayers = List.from(widget.initialPlayers);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedPlayers.length >= 2;
  }

  Future<void> _onAddPlayer() async {
    final remaining = widget.availablePlayers
        .where(
          (p) => !_selectedPlayers.any((sp) => sp.id == p.id),
        )
        .toList();

    if (remaining.isEmpty) {
      ToastMessage.info(context, 'All players have been added');
      return;
    }

    final selected = await PickerSheet.show<Player>(
      context: context,
      title: 'Add Player',
      items: remaining,
      itemLabel: _playerDisplayName,
      itemBuilder: (context, player) => PlayerItem(player: player),
      emptyTitle: 'No players available',
      emptySubtitle: 'All players have been added',
    );

    if (selected != null) {
      setState(() {
        _selectedPlayers.add(selected);
      });
    }
  }

  void _onRemovePlayer(int playerId) {
    setState(() {
      _selectedPlayers.removeWhere((p) => p.id == playerId);
    });
  }

  void _onReorderPlayers(int oldIndex, int newIndex) {
    setState(() {
      var adjustedIndex = newIndex;
      if (adjustedIndex > oldIndex) {
        adjustedIndex -= 1;
      }
      final player = _selectedPlayers.removeAt(oldIndex);
      _selectedPlayers.insert(adjustedIndex, player);
    });
  }

  void _onSave() {
    if (!_isValid) return;

    ToastMessage.success(context, 'Edit successfull');

    Navigator.pop(
      context,
      EditPartyResult(
        name: _nameController.text.trim(),
        players: _selectedPlayers,
      ),
    );
  }

  String _playerDisplayName(Player player) {
    if (player.lastName != null && player.lastName!.isNotEmpty) {
      return '${player.firstName} ${player.lastName}';
    }
    return player.firstName;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final maxHeight = MediaQuery.sizeOf(context).height * 0.90;

    return SizedBox(
      height: maxHeight,
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacing.gap8,
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Spacing.gap12,

              // Header
              Padding(
                padding: Spacing.sheetHorizontal,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Edit Party',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
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

              Spacing.gap24,

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Party Name
                      const _SectionTitle('Party Name'),
                      Spacing.gap8,
                      Padding(
                        padding: Spacing.sheetHorizontal,
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Friday Night #1',
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),

                      Spacing.gap24,

                      // Players Section Header
                      Padding(
                        padding: Spacing.sheetHorizontal,
                        child: Row(
                          children: [
                            const _SectionTitle('Players'),
                            const SizedBox(width: 8),
                            Text(
                              '(${_selectedPlayers.length})',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _onAddPlayer,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                      ),
                      Spacing.gap12,

                      // Players List
                      if (_selectedPlayers.isEmpty)
                        _EmptyPlayersCard()
                      else
                        Padding(
                          padding: Spacing.sheetHorizontal,
                          child: ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedPlayers.length,
                            onReorder: _onReorderPlayers,
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
                              final player = _selectedPlayers[index];
                              return Padding(
                                key: ValueKey(player.id),
                                padding: const EdgeInsets.only(
                                  bottom: Spacing.xs,
                                ),
                                child: PlayerItem(
                                  player: player,
                                  reorderIndex: index,
                                  onRemove: () => _onRemovePlayer(player.id),
                                ),
                              );
                            },
                          ),
                        ),

                      // Validation message
                      if (_selectedPlayers.isNotEmpty &&
                          _selectedPlayers.length < 2)
                        Padding(
                          padding: Spacing.sheetHorizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(top: Spacing.xs),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: cs.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'At least 2 players required',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      Spacing.gap24,
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              Padding(
                padding: Spacing.sheetBottom,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isValid ? _onSave : null,
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: Spacing.sheetHorizontal,
      child: Text(
        text,
        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _EmptyPlayersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: Spacing.sheetHorizontal,
      child: Container(
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
              'No players added',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Add" to add players',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
