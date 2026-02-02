import 'package:flutter/material.dart';

class ReorderPreview extends StatelessWidget {
  const ReorderPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlayerCell(
            fullName: 'Alice',
            initials: 'A',
            color: Color(0xFF64B5F6),
          ),
          _PlayerCell(
            fullName: 'Bob',
            initials: 'B',
            color: Color(0xFF81C784),
            isDragging: true,
          ),
          _PlayerCell(
            fullName: 'Charlie',
            initials: 'C',
            color: Color(0xFFFFB74D),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// Matches _PlayerCellCompact from table_widget.dart
class _PlayerCell extends StatelessWidget {
  const _PlayerCell({
    required this.fullName,
    required this.initials,
    required this.color,
    this.isDragging = false,
    this.isLast = false,
  });

  final String fullName;
  final String initials;
  final Color color;
  final bool isDragging;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nameStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(fontWeight: FontWeight.w500);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDragging ? cs.primaryContainer.withValues(alpha: 0.5) : null,
        borderRadius: isDragging
            ? BorderRadius.circular(12)
            : isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(16))
                : null,
        border: !isLast && !isDragging
            ? Border(bottom: BorderSide(color: cs.outlineVariant))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: Text(
                initials,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: nameStyle?.copyWith(
                  color: isDragging ? cs.onPrimaryContainer : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
