import 'package:flutter/material.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/ui/widgets/small_action_buttons.dart';

class PlayerItem extends StatelessWidget {
  const PlayerItem({
    required this.player,
    this.onTap,
    this.onDelete,
    this.onRemove,
    this.reorderIndex,
    super.key,
  });

  final Player player;

  /// Main tap (picker / open details)
  final VoidCallback? onTap;

  /// Destructive delete (trash icon)
  final VoidCallback? onDelete;

  /// Remove from list (X icon)
  final VoidCallback? onRemove;

  /// If provided, shows drag handle
  final int? reorderIndex;

  String get _displayName {
    if (player.lastName != null && player.lastName!.isNotEmpty) {
      return '${player.firstName} ${player.lastName}';
    }
    return player.firstName;
  }

  String get _initials {
    final first = player.firstName.isNotEmpty ? player.firstName[0] : '';
    final last = player.lastName?.isNotEmpty ?? false
        ? player.lastName![0]
        : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasColor = player.color != null;
    final avatarColor = hasColor ? Color(player.color!) : cs.primaryContainer;
    final textColor = hasColor ? Colors.white : cs.onPrimaryContainer;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor,
                child: Text(
                  _initials.isNotEmpty ? _initials : '?',
                  style: tt.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // --- TRAILING ACTIONS (ordered, predictable) ---
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                SmallActionButton.delete(onPressed: onDelete),
              ],

              if (onRemove != null) ...[
                const SizedBox(width: 4),
                SmallActionButton(
                  tooltip: 'Remove player',
                  icon: Icons.close,
                  colorOverride: cs.error,
                  onPressed: onRemove,
                ),
              ],

              if (reorderIndex != null) ...[
                const SizedBox(width: 8),
                ReorderableDragStartListener(
                  index: reorderIndex!,
                  child: SmallActionButton(
                    tooltip: 'Reorder players',
                    icon: Icons.drag_indicator_outlined,
                    colorOverride: cs.onSurfaceVariant,
                    onPressed: () {},
                  ),
                ),
              ],

              if (onDelete == null &&
                  onRemove == null &&
                  reorderIndex == null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
