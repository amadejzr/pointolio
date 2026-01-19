import 'package:flutter/material.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';

class GameTypePickerSheet extends StatefulWidget {
  const GameTypePickerSheet({super.key, required this.gameTypes});

  final List<GameType> gameTypes;

  static Future<GameType?> show(
    BuildContext context, {
    required List<GameType> gameTypes,
  }) {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet<GameType>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => GameTypePickerSheet(gameTypes: gameTypes),
    );
  }

  @override
  State<GameTypePickerSheet> createState() => _GameTypePickerSheetState();
}

class _GameTypePickerSheetState extends State<GameTypePickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GameType> get _filteredGameTypes {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.gameTypes;
    return widget.gameTypes
        .where((t) => t.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final height = MediaQuery.sizeOf(context).height;
    final maxHeight = height * 0.82;

    return SizedBox(
      height: maxHeight,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(99),
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
                    'Game Types',
                    style: tt.titleMedium?.copyWith(
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

          // Search
          Padding(
            padding: Spacing.search,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // List
          Expanded(
            child: _filteredGameTypes.isEmpty
                ? const _EmptyState(
                    title: 'No game types found',
                    subtitle: 'Try a different search term.',
                  )
                : ListView.separated(
                    padding: Spacing.list,
                    itemCount: _filteredGameTypes.length,
                    separatorBuilder: (_, __) => Spacing.gap12,
                    itemBuilder: (context, index) {
                      final gameType = _filteredGameTypes[index];
                      return _GameTypeTile(
                        gameType: gameType,
                        onTap: () => Navigator.pop(context, gameType),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GameTypeTile extends StatelessWidget {
  const _GameTypeTile({required this.gameType, required this.onTap});

  final GameType gameType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasColor = gameType.color != null;
    final color = hasColor ? Color(gameType.color!) : cs.primary;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // was 14 -> use a token instead (closest = 12)
          padding: Spacing.card,
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasColor ? color : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: hasColor
                      ? null
                      : Border.all(color: cs.outlineVariant, width: 2),
                ),
                child: Center(
                  child: hasColor
                      ? Text(
                          gameType.name.isNotEmpty
                              ? gameType.name[0].toUpperCase()
                              : '?',
                          style: tt.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : Icon(
                          Icons.category_outlined,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                ),
              ),
              Spacing.hGap12,

              // Name and badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameType.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacing.gap4,
                    _WinConditionBadge(
                      lowestScoreWins: gameType.lowestScoreWins,
                    ),
                  ],
                ),
              ),

              Spacing.hGap8,
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinConditionBadge extends StatelessWidget {
  const _WinConditionBadge({required this.lowestScoreWins});

  final bool lowestScoreWins;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final icon = lowestScoreWins ? Icons.arrow_downward : Icons.arrow_upward;
    final label = lowestScoreWins ? 'Lowest wins' : 'Highest wins';
    final color = lowestScoreWins ? Colors.blue : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          Spacing
              .hGap8, // was 4; 8 is fine, but if you want exact: keep SizedBox(width: 4)
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: Spacing.page, // was 24; your tokens use 16/24 - this is fine
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 44, color: cs.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
