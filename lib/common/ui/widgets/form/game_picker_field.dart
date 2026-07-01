import 'package:flutter/material.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

String _ruleLabel(GameType g) =>
    g.lowestScoreWins ? 'Lowest wins' : 'Highest wins';

/// The "chosen game" row used in New/Edit party. Tapping it opens the picker
/// (wire [onTap] to [GamePickerSheet.show]). When [gameType] is null it shows a
/// "Choose game" placeholder; otherwise the game's colour bar, name and rule.
class GamePickerField extends StatelessWidget {
  const GamePickerField({
    required this.gameType,
    required this.onTap,
    super.key,
    this.hasError = false,
  });

  final GameType? gameType;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final danger = pt.players[3];
    final g = gameType;

    final semantics = g == null
        ? 'Choose a game'
        : 'Game: ${g.name}, ${_ruleLabel(g)}';

    return Pressable(
      onTap: onTap,
      isButton: true,
      semanticLabel: semantics,
      semanticHint: 'Opens the game picker',
      excludeChildSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: pt.surface,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: hasError ? danger : pt.border),
        ),
        child: g == null
            ? Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 20,
                    color: pt.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choose game',
                      style: PT
                          .bodyStrong(
                            pt.textMuted,
                          )
                          .copyWith(fontSize: 14.5),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: pt.textFaint,
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 10,
                    height: 30,
                    decoration: BoxDecoration(
                      color: g.color != null ? Color(g.color!) : pt.accent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          g.name,
                          style: PT
                              .bodyStrong(
                                pt.text,
                              )
                              .copyWith(fontSize: 14.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _ruleLabel(g),
                          style: PT
                              .caption(
                                pt.textMuted,
                              )
                              .copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Change',
                    style: PT.bodyStrong(pt.accent).copyWith(fontSize: 13),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Bottom-sheet picker for choosing which saved game type a party uses.
///
///   final game = await GamePickerSheet.show(context,
///       gameTypes: state.availableGameTypes,
///       selected: state.selectedGameType);
class GamePickerSheet {
  const GamePickerSheet._();

  static Future<GameType?> show(
    BuildContext context, {
    required List<GameType> gameTypes,
    GameType? selected,
  }) {
    return showModalBottomSheet<GameType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _GamePickerSheet(gameTypes: gameTypes, selected: selected),
    );
  }
}

class _GamePickerSheet extends StatelessWidget {
  const _GamePickerSheet({required this.gameTypes, this.selected});

  final List<GameType> gameTypes;
  final GameType? selected;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
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
            child: Text('Choose a game', style: PT.sectionTitle(pt.text)),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: gameTypes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final g = gameTypes[i];
                final isSel = g.id == selected?.id;
                return Pressable(
                  onTap: () => Navigator.of(context).pop(g),
                  isButton: true,
                  selected: isSel,
                  semanticLabel: '${g.name}, ${_ruleLabel(g)}',
                  excludeChildSemantics: true,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 56),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSel ? pt.accentTint : pt.surface,
                      borderRadius: BorderRadius.circular(R.md),
                      border: Border.all(
                        color: isSel ? pt.accentBorder : pt.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 30,
                          decoration: BoxDecoration(
                            color: g.color != null
                                ? Color(g.color!)
                                : pt.accent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(g.name, style: PT.cardTitle(pt.text)),
                              Text(
                                _ruleLabel(g),
                                style: PT.caption(pt.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (isSel)
                          Icon(
                            Icons.check_circle_rounded,
                            color: pt.accent,
                            size: 22,
                          ),
                      ],
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
