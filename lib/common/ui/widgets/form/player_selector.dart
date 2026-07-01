import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/form/primary_button.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/player_avatar.dart';

String _initial(Player p) =>
    p.firstName.isNotEmpty ? p.firstName[0].toUpperCase() : '?';

Color _playerColor(BuildContext context, Player p, int fallbackIndex) =>
    p.color != null ? Color(p.color!) : context.pt.playerColor(fallbackIndex);

/// A removable player pill (mini avatar + first name + remove). [colorIndex] is
/// the palette fallback for players that have no saved colour.
class PlayerChip extends StatelessWidget {
  const PlayerChip({
    required this.player,
    required this.colorIndex,
    required this.onRemove,
    super.key,
  });

  final Player player;
  final int colorIndex;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Semantics(
      container: true,
      label: player.firstName,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
        decoration: BoxDecoration(
          color: pt.surface,
          borderRadius: BorderRadius.circular(R.pill),
          border: Border.all(color: pt.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlayerAvatar(
              initial: _initial(player),
              color: _playerColor(context, player, colorIndex),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              player.firstName,
              style: PT.bodyStrong(pt.text).copyWith(fontSize: 13.5),
            ),
            const SizedBox(width: 2),
            Pressable(
              onTap: onRemove,
              scale: 0.85,
              isButton: true,
              semanticLabel: 'Remove ${player.firstName}',
              excludeChildSemantics: true,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: pt.textFaint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed "+ Add existing" / "+ New player" chip. [accent] tints it azure.
class DashedActionChip extends StatelessWidget {
  const DashedActionChip({
    required this.label,
    required this.onTap,
    super.key,
    this.accent = false,
  });

  final String label;
  final bool accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final color = accent ? pt.accent : pt.textMuted;
    final line = accent ? pt.accentBorder : pt.borderStrong;
    return Pressable(
      onTap: onTap,
      scale: 0.94,
      isButton: true,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: DashedBorder(
        color: line,
        radius: R.pill,
        // Solid white fill so the ruled paper doesn't show through; the dashes
        // are drawn on top of it.
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pt.surface,
            borderRadius: BorderRadius.circular(R.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16, color: color),
              const SizedBox(width: 5),
              Text(label, style: PT.bodyStrong(color).copyWith(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The party roster editor: selected players as removable chips plus the two
/// add actions, laid out in a [Wrap]. Wire [onAddExisting] to
/// [ExistingPlayersSheet.show] and [onNewPlayer] to your New Player flow.
class PlayerSelector extends StatelessWidget {
  const PlayerSelector({
    required this.players,
    required this.onRemove,
    required this.onAddExisting,
    required this.onNewPlayer,
    super.key,
  });

  final List<Player> players;
  final ValueChanged<Player> onRemove;
  final VoidCallback onAddExisting;
  final VoidCallback onNewPlayer;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: S.sm,
      runSpacing: S.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < players.length; i++)
          PlayerChip(
            player: players[i],
            colorIndex: i,
            onRemove: () => onRemove(players[i]),
          ),
        DashedActionChip(label: 'Add existing', onTap: onAddExisting),
        DashedActionChip(label: 'New player', accent: true, onTap: onNewPlayer),
      ],
    );
  }
}

/// Multi-select sheet to pull in existing people. `available` should already
/// be filtered to players not yet in the party. Returns the list the user
/// chose to add (empty/null if they cancel).
///
/// When everyone is already in the party (`available` is empty) the sheet
/// shows a guiding empty state whose button closes the sheet and calls
/// `onNewPlayer` so the caller can open its New Player flow.
///
///   final toAdd = await ExistingPlayersSheet.show(context,
///       available: pool, onNewPlayer: () => _openNewPlayerForm());
class ExistingPlayersSheet {
  const ExistingPlayersSheet._();

  static Future<List<Player>?> show(
    BuildContext context, {
    required List<Player> available,
    required VoidCallback onNewPlayer,
  }) {
    return showModalBottomSheet<List<Player>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _ExistingPlayersSheet(available: available, onNewPlayer: onNewPlayer),
    );
  }
}

class _ExistingPlayersSheet extends StatefulWidget {
  const _ExistingPlayersSheet({
    required this.available,
    required this.onNewPlayer,
  });

  final List<Player> available;
  final VoidCallback onNewPlayer;

  @override
  State<_ExistingPlayersSheet> createState() => _ExistingPlayersSheetState();
}

class _ExistingPlayersSheetState extends State<_ExistingPlayersSheet> {
  final Set<int> _picked = {};

  String _displayName(Player p) {
    final last = p.lastName;
    return (last != null && last.isNotEmpty)
        ? '${p.firstName} $last'
        : p.firstName;
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final empty = widget.available.isEmpty;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: pt.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(R.bar)),
      ),
      padding: EdgeInsets.only(
        left: S.lg,
        right: S.lg,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + S.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: pt.borderStrong,
                borderRadius: BorderRadius.circular(R.pill),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text('Add players', style: PT.sectionTitle(pt.text)),
          ),
          const SizedBox(height: 12),
          if (empty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 44,
                    color: pt.textFaint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No one to add',
                    textAlign: TextAlign.center,
                    style: PT.cardTitle(pt.text),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create a new player to bring someone new into '
                    'this party.',
                    textAlign: TextAlign.center,
                    style: PT.body(pt.textMuted),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.available.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = widget.available[i];
                  final on = _picked.contains(p.id);
                  return Pressable(
                    onTap: () => setState(
                      () => on ? _picked.remove(p.id) : _picked.add(p.id),
                    ),
                    isButton: true,
                    selected: on,
                    semanticLabel: _displayName(p),
                    excludeChildSemantics: true,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: on ? pt.accentTint : pt.surface,
                        borderRadius: BorderRadius.circular(R.md),
                        border: Border.all(
                          color: on ? pt.accentBorder : pt.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          PlayerAvatar(
                            initial: _initial(p),
                            color: _playerColor(context, p, i),
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _displayName(p),
                              style: PT.bodyStrong(pt.text),
                            ),
                          ),
                          Icon(
                            on
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: on ? pt.accent : pt.textFaint,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 14),
          if (empty)
            PrimaryButton(
              label: 'New player',
              onTap: () {
                Navigator.of(context).pop();
                widget.onNewPlayer();
              },
            )
          else
            PrimaryButton(
              label: 'Done',
              onTap: () {
                final chosen = widget.available
                    .where((p) => _picked.contains(p.id))
                    .toList();
                Navigator.of(context).pop(chosen);
              },
            ),
        ],
      ),
    );
  }
}

/// Draws a dashed rounded-rect border around [child] (Flutter has no native
/// dashed border). Used by the add-player chips.
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    required this.child,
    required this.color,
    super.key,
    this.radius = 12,
    this.strokeWidth = 1.5,
    this.dash = 5,
    this.gap = 4,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // Foreground so the dashes sit on top of the child's fill.
      foregroundPainter: _DashedPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
        dash: dash,
        gap: gap,
      ),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(math.min(radius, size.height / 2)),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final len = math.min(dash, metric.length - dist);
        canvas.drawPath(metric.extractPath(dist, dist + len), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}
