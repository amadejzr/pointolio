import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/features/sharing/domain/share_result.dart';
import 'package:pointolio/features/sharing/presentation/widgets/glass_panel.dart';
import 'package:pointolio/features/sharing/presentation/widgets/share_bits.dart';

/// Fixed width the card lays out and is captured at. Height hugs its content,
/// so the exported PNG is a tight card with no dead space.
const double kShareCardWidth = 340;

// Fixed on-card palette (independent of the live theme, so the capture is
// identical off-screen). The card itself is a dark translucent panel.
const _cream = Color(0xFFB9C6E6);
const _dim = Color(0xFF9AA0B0);
const _rowText = Color(0xFFCDD2DD);
const _hair = Color(0x14FFFFFF);

/// Renders the selected [ShareStyle] as a compact translucent card. The card
/// hugs its content; [opacity] drives the fill so the transparency control
/// affects every style uniformly.
///
/// Colours (accent + per-player hue) are passed in from the live theme so the
/// card is self-contained for off-screen capture.
class ShareCard extends StatelessWidget {
  const ShareCard({
    required this.result,
    required this.style,
    required this.opacity,
    required this.accent,
    required this.colorFor,
    super.key,
  });

  final ShareResult result;
  final ShareStyle style;
  final double opacity;
  final Color accent;
  final Color Function(Standing standing) colorFor;

  @override
  Widget build(BuildContext context) {
    if (result.isEmpty) {
      return GlassPanel(
        opacity: opacity,
        child: Text(
          result.partyName,
          style: PT.number(Colors.white, size: 20),
          textAlign: TextAlign.center,
        ),
      );
    }

    return switch (style) {
      ShareStyle.spotlight => _Spotlight(
        result: result,
        opacity: opacity,
        accent: accent,
        colorFor: colorFor,
      ),
      ShareStyle.podium => _Podium(
        result: result,
        opacity: opacity,
        accent: accent,
        colorFor: colorFor,
      ),
      ShareStyle.ticket => _Ticket(
        result: result,
        opacity: opacity,
        accent: accent,
        colorFor: colorFor,
      ),
      ShareStyle.minimal => _Minimal(
        result: result,
        opacity: opacity,
        accent: accent,
        colorFor: colorFor,
      ),
    };
  }
}

/// "Rummy · 7 rounds" - the real metadata line above a title.
String _meta(ShareResult r) {
  final rounds = r.roundCount == 1 ? '1 round' : '${r.roundCount} rounds';
  return [if (r.gameName.isNotEmpty) r.gameName, rounds].join(' · ');
}

/// 1 - SPOTLIGHT: winner as the hero, then a tight standings list. Default.
class _Spotlight extends StatelessWidget {
  const _Spotlight({
    required this.result,
    required this.opacity,
    required this.accent,
    required this.colorFor,
  });

  final ShareResult result;
  final double opacity;
  final Color accent;
  final Color Function(Standing) colorFor;

  @override
  Widget build(BuildContext context) {
    final w = result.winner;
    // Everyone below the displayed winner - includes co-winners on a tie.
    final rest = result.standings.skip(1).take(5).toList();
    return GlassPanel(
      opacity: opacity,
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Eyebrow(_meta(result)),
          const SizedBox(height: 3),
          Text(
            result.partyName,
            style: PT.number(Colors.white, size: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ShareAvatar(
                initial: w.initial,
                color: colorFor(w),
                size: 46,
                ring: Colors.white.withValues(alpha: 0.18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.firstName,
                      style: PT.number(Colors.white, size: 19),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.isTie ? 'TIE' : 'WINNER',
                      style: PT.label(accent).copyWith(letterSpacing: 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text('${w.total}', style: PT.number(accent, size: 38)),
            ],
          ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _Hairline(),
            const SizedBox(height: 8),
            for (final s in rest) _StandingRow(s: s),
          ],
          const SizedBox(height: 16),
          const _Hairline(),
          const SizedBox(height: 12),
          const ShareWatermark(color: _dim),
        ],
      ),
    );
  }
}

/// 2 - PODIUM: the top three on compact tiered blocks.
class _Podium extends StatelessWidget {
  const _Podium({
    required this.result,
    required this.opacity,
    required this.accent,
    required this.colorFor,
  });

  final ShareResult result;
  final double opacity;
  final Color accent;
  final Color Function(Standing) colorFor;

  @override
  Widget build(BuildContext context) {
    // On a draw every co-champion gets an equal tallest block; otherwise the
    // classic 2nd / 1st / 3rd arrangement with short tiered blocks.
    final List<(Standing, double)> order;
    if (result.isTie) {
      order = [for (final s in result.topRanked) (s, 46.0)];
    } else {
      final top = result.standings.take(3).toList();
      order = [
        if (top.length > 1) (top[1], 32),
        (top[0], 46),
        if (top.length > 2) (top[2], 24),
      ];
    }
    return GlassPanel(
      opacity: opacity,
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Eyebrow(_meta(result)),
          const SizedBox(height: 3),
          Text(
            result.partyName,
            style: PT.number(Colors.white, size: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (s, h) in order)
                Expanded(
                  child: _PodiumTile(
                    s: s,
                    barHeight: h,
                    color: colorFor(s),
                    accent: accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const ShareWatermark(color: _dim),
        ],
      ),
    );
  }
}

class _PodiumTile extends StatelessWidget {
  const _PodiumTile({
    required this.s,
    required this.barHeight,
    required this.color,
    required this.accent,
  });

  final Standing s;
  final double barHeight;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isWinner = s.rank == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShareAvatar(
            initial: s.initial,
            color: color,
            size: isWinner ? 50 : 40,
          ),
          const SizedBox(height: 8),
          Text(
            s.firstName,
            style: PT.bodyStrong(Colors.white).copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${s.total}',
            style: PT.number(
              isWinner ? accent : _dim,
              size: isWinner ? 18 : 15,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: barHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: (isWinner ? accent : Colors.white).withValues(
                alpha: isWinner ? 0.85 : 0.14,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${s.rank}',
              style: PT.number(isWinner ? Colors.white : _cream, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3 - SCORECARD (ticket): the full ranked list, receipt-style.
class _Ticket extends StatelessWidget {
  const _Ticket({
    required this.result,
    required this.opacity,
    required this.accent,
    required this.colorFor,
  });

  final ShareResult result;
  final double opacity;
  final Color accent;
  final Color Function(Standing) colorFor;

  @override
  Widget build(BuildContext context) {
    final subtitle = '${_meta(result)} · ${result.winRuleText}';
    final standings = result.standings;
    return GlassPanel(
      opacity: opacity,
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            result.partyName,
            style: PT.number(Colors.white, size: 20),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: PT.caption(_cream).copyWith(fontSize: 10.5),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          const _Dashed(),
          const SizedBox(height: 4),
          for (final s in standings) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    child: Text(
                      '${s.rank}',
                      style: PT.number(s.rank == 1 ? accent : _dim, size: 15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShareAvatar(initial: s.initial, color: colorFor(s), size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.fullName,
                      style: PT
                          .bodyStrong(
                            s.rank == 1 ? Colors.white : _rowText,
                          )
                          .copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${s.total}',
                    style: PT.number(s.rank == 1 ? accent : Colors.white),
                  ),
                ],
              ),
            ),
            if (s != standings.last) const _Hairline(),
          ],
          const SizedBox(height: 4),
          const _Dashed(),
          const SizedBox(height: 12),
          const ShareWatermark(color: _dim),
        ],
      ),
    );
  }
}

/// 4 - MINIMAL: just the winner and the number. Ultra clean.
class _Minimal extends StatelessWidget {
  const _Minimal({
    required this.result,
    required this.opacity,
    required this.accent,
    required this.colorFor,
  });

  final ShareResult result;
  final double opacity;
  final Color accent;
  final Color Function(Standing) colorFor;

  @override
  Widget build(BuildContext context) {
    final w = result.winner;
    final others = result.standings.skip(1).take(5).toList();
    return GlassPanel(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Eyebrow(result.partyName),
          const SizedBox(height: 16),
          Text(
            result.isTie ? 'TIE' : 'WINNER',
            style: PT.label(accent).copyWith(letterSpacing: 2.5),
          ),
          const SizedBox(height: 4),
          Text(
            w.firstName,
            style: PT.number(Colors.white, size: 34),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${w.total}', style: PT.number(accent, size: 60)),
              const SizedBox(width: 8),
              Text('pts', style: PT.number(_dim, size: 16)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            result.winRuleText,
            style: PT.caption(_cream).copyWith(fontSize: 11),
          ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _Hairline(),
            const SizedBox(height: 8),
            for (final s in others) _StandingRow(s: s),
          ],
          const SizedBox(height: 18),
          const ShareWatermark(color: _dim),
        ],
      ),
    );
  }
}

/// A ranked standings row (rank · name · score).
class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.s});

  final Standing s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text('${s.rank}', style: PT.number(_dim, size: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s.firstName,
              style: PT.body(_rowText).copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text('${s.total}', style: PT.number(Colors.white, size: 14)),
        ],
      ),
    );
  }
}

/// The small caps metadata line above a card title.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: PT.label(_dim).copyWith(letterSpacing: 1.8),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => Container(height: 1, color: _hair);
}

class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final n = (c.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            n,
            (_) => Container(
              width: 4,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
        );
      },
    );
  }
}
