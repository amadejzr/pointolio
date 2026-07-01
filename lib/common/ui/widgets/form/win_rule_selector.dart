import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/form/segmented_control.dart';

/// "Who wins" toggle for a game type - Highest vs Lowest. Maps to the domain
/// [lowestScoreWins] flag (true => lowest total wins).
class WinRuleSelector extends StatelessWidget {
  const WinRuleSelector({
    required this.lowestScoreWins,
    required this.onChanged,
    super.key,
  });

  final bool lowestScoreWins;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedControl<bool>(
      value: lowestScoreWins,
      onChanged: onChanged,
      options: const [
        SegmentOption(false, 'Highest wins'),
        SegmentOption(true, 'Lowest wins'),
      ],
    );
  }
}

/// Optional helper note under the selector, explaining the ranking.
class WinRuleNote extends StatelessWidget {
  const WinRuleNote({
    required this.lowestScoreWins,
    required this.gameName,
    super.key,
  });

  final bool lowestScoreWins;
  final String gameName;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final word = lowestScoreWins ? 'lowest' : 'highest';
    final name = gameName.trim().isEmpty ? 'this game' : gameName.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: pt.accentTint,
        borderRadius: BorderRadius.circular(R.sm),
        border: Border.all(color: pt.accentBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: pt.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'In $name the $word total takes the win - '
              "we'll rank the board that way.",
              style: PT.caption(pt.accentDeep).copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
