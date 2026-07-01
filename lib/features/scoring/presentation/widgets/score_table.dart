import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';

/// Adaptive score table for the Notebook/Slate scoring screen.
///
/// Players are always few, rounds keep growing - so the rounds axis is the one
/// that scrolls and lazy-builds. The layout flips by orientation:
///
/// * Portrait  -> vertical ledger: players are columns, rounds are rows that
///   scroll down, totals pinned as a bottom row.
/// * Landscape -> wide grid: players are rows, rounds are columns that scroll
///   sideways, totals pinned as a right column.
///
/// The per-round winner (lowest or highest that round, per the win rule) is
/// drawn as a bold, accent-coloured number. Players can be dragged to reorder
/// (long-press) so the input order matches how people sit around the table.
class ScoreTable extends StatefulWidget {
  const ScoreTable({
    required this.state,
    this.onEditScore,
    this.onDeleteRound,
    this.onReorderPlayers,
    super.key,
  });

  final ScoringState state;

  /// Null when the party is finished (read-only).
  final FutureOr<void> Function(
    int scoreEntryId,
    int currentPoints,
    String playerName,
    int round,
  )?
  onEditScore;
  final FutureOr<void> Function(int roundNumber)? onDeleteRound;
  final FutureOr<void> Function(int oldIndex, int newIndex)? onReorderPlayers;

  static String fullName(Player p) {
    final fn = p.firstName.trim();
    final ln = (p.lastName ?? '').trim();
    return ln.isEmpty ? fn : '$fn $ln';
  }

  static String initials(Player p) {
    final fn = p.firstName.trim();
    final ln = (p.lastName ?? '').trim();
    if (fn.isEmpty) return '?';
    if (ln.isEmpty) {
      return fn.length >= 2
          ? fn.substring(0, 2).toUpperCase()
          : fn.substring(0, 1).toUpperCase();
    }
    return (fn.substring(0, 1) + ln.substring(0, 1)).toUpperCase();
  }

  @override
  State<ScoreTable> createState() => _ScoreTableState();
}

class _ScoreTableState extends State<ScoreTable> {
  // Rounds scroll controllers (only one is active per orientation).
  final _roundsV = ScrollController();
  final _roundsH = ScrollController();

  bool _showNames = false;
  int _prevRoundCount = 0;
  int? _highlightRound;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    _prevRoundCount = widget.state.roundCount;
  }

  @override
  void didUpdateWidget(covariant ScoreTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCount = widget.state.roundCount;
    if (newCount > _prevRoundCount) {
      _highlightRound = newCount;
      _highlightTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) => _onRoundAdded());
    }
    _prevRoundCount = newCount;
  }

  void _onRoundAdded() {
    if (!mounted) return;
    for (final c in [_roundsV, _roundsH]) {
      if (c.hasClients) {
        unawaited(
          c.animateTo(
            c.position.maxScrollExtent,
            duration: Motion.slow,
            curve: Motion.ease,
          ),
        );
      }
    }
    _highlightTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _highlightRound = null);
    });
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _roundsV.dispose();
    _roundsH.dispose();
    super.dispose();
  }

  void _toggleNames() => setState(() => _showNames = !_showNames);

  /// Best (winning) points value per round, honouring the win rule. Empty when
  /// a round has no entries.
  Map<int, int> _bestByRound() {
    final best = <int, int>{};
    final lowestWins = widget.state.lowestScoreWins;
    for (final ps in widget.state.playerScores) {
      ps.roundScores.forEach((round, entry) {
        final current = best[round];
        if (current == null) {
          best[round] = entry.points;
        } else {
          best[round] = lowestWins
              ? math.min(current, entry.points)
              : math.max(current, entry.points);
        }
      });
    }
    return best;
  }

  /// Best total across players, honouring the win rule (leader highlight).
  int? _bestTotal() {
    final scores = widget.state.playerScores;
    if (scores.isEmpty) return null;
    var best = scores.first.total;
    for (final ps in scores.skip(1)) {
      best = widget.state.lowestScoreWins
          ? math.min(best, ps.total)
          : math.max(best, ps.total);
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final bestByRound = _bestByRound();
    final bestTotal = _bestTotal();

    final config = _TableConfig(
      state: widget.state,
      bestByRound: bestByRound,
      bestTotal: bestTotal,
      showNames: _showNames,
      onToggleNames: _toggleNames,
      onEditScore: widget.onEditScore,
      onDeleteRound: widget.onDeleteRound,
      onReorderPlayers: widget.onReorderPlayers,
      highlightRound: _highlightRound,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(S.lg, 0, S.lg, S.sm),
      child: isLandscape
          ? _HorizontalGrid(config: config, roundsH: _roundsH)
          : _VerticalLedger(config: config, roundsV: _roundsV),
    );
  }
}

/// Immutable bundle of everything the two layouts need. Keeps their
/// constructors small and the callbacks consistent.
class _TableConfig {
  const _TableConfig({
    required this.state,
    required this.bestByRound,
    required this.bestTotal,
    required this.showNames,
    required this.onToggleNames,
    required this.onEditScore,
    required this.onDeleteRound,
    required this.onReorderPlayers,
    required this.highlightRound,
  });

  final ScoringState state;
  final Map<int, int> bestByRound;
  final int? bestTotal;
  final bool showNames;
  final VoidCallback onToggleNames;
  final FutureOr<void> Function(
    int scoreEntryId,
    int currentPoints,
    String playerName,
    int round,
  )?
  onEditScore;
  final FutureOr<void> Function(int roundNumber)? onDeleteRound;
  final FutureOr<void> Function(int oldIndex, int newIndex)? onReorderPlayers;
  final int? highlightRound;

  List<PlayerScore> get players => state.playerScores;
  int get roundCount => state.roundCount;
  bool get canReorder => onReorderPlayers != null;

  Color playerColor(BuildContext context, int index) {
    final stored = players[index].player.color;
    return stored != null ? Color(stored) : context.pt.playerColor(index);
  }

  bool isWinner(PlayerScore ps, int round) {
    final entry = ps.roundScores[round];
    final best = bestByRound[round];
    return entry != null && best != null && entry.points == best;
  }
}

// ============================================================ dimensions
const double _rowH = 50;
const double _headerH = 56;
const double _roundLabelW = 56; // vertical: left "Rn" column
const double _totalW = 78; // horizontal: right "Total" column
const double _roundColW = 68; // horizontal: each round column (scroll mode)

// ============================================================ VERTICAL
class _VerticalLedger extends StatelessWidget {
  const _VerticalLedger({required this.config, required this.roundsV});

  final _TableConfig config;
  final ScrollController roundsV;

  @override
  Widget build(BuildContext context) {
    final players = config.players;
    final n = math.max(players.length, 1);
    final headerH = config.showNames ? 70.0 : _headerH;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fill the width: player columns flex to share the space evenly so the
        // card spans the screen. When the roster is too large to stay legible,
        // columns fall back to a fixed min width and the grid scrolls sideways.
        final minColW = config.showNames ? 116.0 : 78.0;
        final fill = (constraints.maxWidth - _roundLabelW) / n >= minColW;
        final scrollW = _roundLabelW + minColW * players.length;

        final rounds = config.roundCount == 0
            ? const _EmptyRounds()
            : ListView.builder(
                controller: roundsV,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: config.roundCount,
                itemBuilder: (context, i) => _VRoundRow(
                  config: config,
                  round: i + 1,
                  fill: fill,
                  colW: minColW,
                  highlighted: config.highlightRound == i + 1,
                ),
              );

        final column = Column(
          children: [
            _VHeaderRow(
              config: config,
              fill: fill,
              colW: minColW,
              height: headerH,
            ),
            Expanded(child: rounds),
            _VTotalsRow(config: config, fill: fill, colW: minColW),
          ],
        );

        return _TableCard(
          child: fill
              ? column
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(width: scrollW, child: column),
                ),
        );
      },
    );
  }
}

/// One player column in a ledger row - flexes to fill in [fill] mode, otherwise
/// takes a fixed [colW] (horizontal-scroll mode for large rosters).
class _PlayerSlot extends StatelessWidget {
  const _PlayerSlot({
    required this.fill,
    required this.colW,
    required this.child,
  });

  final bool fill;
  final double colW;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return fill ? Expanded(child: child) : SizedBox(width: colW, child: child);
  }
}

/// The surface the grid sits on - opaque so the ruled notebook background
/// never bleeds through the numbers.
class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    // Fill + shadow on the outer box (no border here - a bordered Container
    // would inset its child by the border width). The border is painted as a
    // non-insetting foreground layer over the clipped content.
    return Container(
      decoration: BoxDecoration(
        color: pt.surface,
        borderRadius: BorderRadius.circular(R.lg),
        boxShadow: pt.shadowCard,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(R.lg),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(R.lg),
            border: Border.all(color: pt.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _VHeaderRow extends StatelessWidget {
  const _VHeaderRow({
    required this.config,
    required this.fill,
    required this.colW,
    required this.height,
  });

  final _TableConfig config;
  final bool fill;
  final double colW;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: pt.surfaceMuted,
        border: Border(bottom: BorderSide(color: pt.border)),
      ),
      child: Row(
        children: [
          _CornerToggle(config: config, width: _roundLabelW, height: height),
          for (var i = 0; i < config.players.length; i++)
            _PlayerSlot(
              fill: fill,
              colW: colW,
              child: _ReorderablePlayer(
                index: i,
                enabled: config.canReorder,
                axis: Axis.horizontal,
                onReorder: config.onReorderPlayers,
                child: _PlayerColumnHead(
                  config: config,
                  index: i,
                  height: height,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerColumnHead extends StatelessWidget {
  const _PlayerColumnHead({
    required this.config,
    required this.index,
    required this.height,
  });

  final _TableConfig config;
  final int index;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final ps = config.players[index];
    final color = config.playerColor(context, index);

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              ScoreTable.initials(ps.player),
              style: PT.number(pt.onPlayer, size: 13),
            ),
          ),
          if (config.showNames) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                ps.player.firstName.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PT.caption(pt.text2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VRoundRow extends StatelessWidget {
  const _VRoundRow({
    required this.config,
    required this.round,
    required this.fill,
    required this.colW,
    required this.highlighted,
  });

  final _TableConfig config;
  final int round;
  final bool fill;
  final double colW;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return AnimatedContainer(
      duration: Motion.base,
      curve: Motion.ease,
      height: _rowH,
      color: highlighted
          ? pt.accentTint
          : (round.isEven ? pt.surfaceSunken : pt.surface),
      child: Row(
        children: [
          _RoundLabel(config: config, round: round, width: _roundLabelW),
          for (var i = 0; i < config.players.length; i++)
            _PlayerSlot(
              fill: fill,
              colW: colW,
              child: _ScoreCell(config: config, playerIndex: i, round: round),
            ),
        ],
      ),
    );
  }
}

class _VTotalsRow extends StatelessWidget {
  const _VTotalsRow({
    required this.config,
    required this.fill,
    required this.colW,
  });

  final _TableConfig config;
  final bool fill;
  final double colW;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Container(
      height: _headerH,
      decoration: BoxDecoration(
        color: pt.surfaceMuted,
        border: Border(top: BorderSide(color: pt.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _roundLabelW,
            child: Center(
              child: Icon(
                Icons.functions_rounded,
                size: 18,
                color: pt.textMuted,
              ),
            ),
          ),
          for (var i = 0; i < config.players.length; i++)
            _PlayerSlot(
              fill: fill,
              colW: colW,
              child: _TotalCell(config: config, index: i),
            ),
        ],
      ),
    );
  }
}

// ============================================================ HORIZONTAL
class _HorizontalGrid extends StatelessWidget {
  const _HorizontalGrid({required this.config, required this.roundsH});

  final _TableConfig config;
  final ScrollController roundsH;

  @override
  Widget build(BuildContext context) {
    final players = config.players;
    final nameW = config.showNames ? 184.0 : 100.0;
    final contentH = _headerH + players.length * _rowH;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fill the width: names pinned left, totals pinned right, and the round
        // columns in between flex to share the space. With lots of rounds they
        // fall back to a fixed width and the strip scrolls sideways.
        final availForRounds = constraints.maxWidth - nameW - _totalW;
        final fits =
            config.roundCount > 0 &&
            _roundColW * config.roundCount <= availForRounds;

        final Widget middle;
        if (config.roundCount == 0) {
          middle = const _EmptyRounds();
        } else if (fits) {
          middle = _HRoundsBody(config: config, fill: true);
        } else {
          middle = SingleChildScrollView(
            controller: roundsH,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: _HRoundsBody(config: config, fill: false),
          );
        }

        final grid = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HNameColumn(config: config, width: nameW),
            Expanded(child: middle),
            _HTotalsColumn(config: config, width: _totalW),
          ],
        );

        return _TableCard(
          child: contentH > constraints.maxHeight
              ? SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(height: contentH, child: grid),
                )
              : grid,
        );
      },
    );
  }
}

class _HNameColumn extends StatelessWidget {
  const _HNameColumn({required this.config, required this.width});

  final _TableConfig config;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          _CornerToggle(config: config, width: width, height: _headerH),
          for (var i = 0; i < config.players.length; i++)
            SizedBox(
              height: _rowH,
              child: _ReorderablePlayer(
                index: i,
                enabled: config.canReorder,
                axis: Axis.vertical,
                onReorder: config.onReorderPlayers,
                child: _PlayerNameCell(config: config, index: i),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerNameCell extends StatelessWidget {
  const _PlayerNameCell({required this.config, required this.index});

  final _TableConfig config;
  final int index;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final ps = config.players[index];
    final color = config.playerColor(context, index);

    return Container(
      height: _rowH,
      color: index.isEven ? pt.surfaceSunken : pt.surface,
      padding: const EdgeInsets.symmetric(horizontal: S.sm),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              ScoreTable.initials(ps.player),
              style: PT.number(pt.onPlayer, size: 11),
            ),
          ),
          if (config.showNames) ...[
            const SizedBox(width: S.sm),
            Expanded(
              child: Text(
                ScoreTable.fullName(ps.player),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PT.bodyStrong(pt.text).copyWith(fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HRoundsBody extends StatelessWidget {
  const _HRoundsBody({required this.config, required this.fill});

  final _TableConfig config;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Round header.
        SizedBox(
          height: _headerH,
          child: Row(
            children: [
              for (var r = 1; r <= config.roundCount; r++)
                _RoundSlot(
                  fill: fill,
                  child: _RoundLabel(
                    config: config,
                    round: r,
                    width: fill ? null : _roundColW,
                    header: true,
                  ),
                ),
            ],
          ),
        ),
        for (var i = 0; i < config.players.length; i++)
          Container(
            height: _rowH,
            color: i.isEven ? context.pt.surfaceSunken : context.pt.surface,
            child: Row(
              children: [
                for (var r = 1; r <= config.roundCount; r++)
                  _RoundSlot(
                    fill: fill,
                    child: _ScoreCell(
                      config: config,
                      playerIndex: i,
                      round: r,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One round column - flexes to fill in [fill] mode, else a fixed width in the
/// horizontal-scroll fallback for many rounds.
class _RoundSlot extends StatelessWidget {
  const _RoundSlot({required this.fill, required this.child});

  final bool fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return fill
        ? Expanded(child: child)
        : SizedBox(width: _roundColW, child: child);
  }
}

class _HTotalsColumn extends StatelessWidget {
  const _HTotalsColumn({required this.config, required this.width});

  final _TableConfig config;
  final double width;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            height: _headerH,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pt.surfaceMuted,
              border: Border(left: BorderSide(color: pt.border)),
            ),
            child: Text('TOTAL', style: PT.label(pt.textMuted)),
          ),
          for (var i = 0; i < config.players.length; i++)
            Container(
              height: _rowH,
              decoration: BoxDecoration(
                color: pt.surfaceMuted,
                border: Border(left: BorderSide(color: pt.border)),
              ),
              child: _TotalCell(config: config, index: i),
            ),
        ],
      ),
    );
  }
}

// ============================================================ shared cells
class _ScoreCell extends StatelessWidget {
  const _ScoreCell({
    required this.config,
    required this.playerIndex,
    required this.round,
  });

  final _TableConfig config;
  final int playerIndex;
  final int round;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final ps = config.players[playerIndex];
    final entry = ps.roundScores[round];
    final winner = config.isWinner(ps, round);

    final base = entry == null
        ? PT.number(pt.textFaint, size: 18, weight: FontWeight.w500)
        : winner
        ? PT.number(pt.accent, size: 20, weight: FontWeight.w800)
        : PT.number(pt.text, size: 19, weight: FontWeight.w600);
    final style = base.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final content = Center(
      child: AnimatedDefaultTextStyle(
        duration: Motion.base,
        curve: Motion.ease,
        style: style,
        child: Text(entry?.points.toString() ?? '·'),
      ),
    );

    final divider = Border(
      right: BorderSide(color: pt.border.withValues(alpha: 0.5)),
    );

    if (entry == null || config.onEditScore == null) {
      return DecoratedBox(
        decoration: BoxDecoration(border: divider),
        child: content,
      );
    }

    final name = ScoreTable.fullName(ps.player);

    return Pressable(
      onTap: () => config.onEditScore!(entry.id, entry.points, name, round),
      scale: 0.9,
      isButton: true,
      semanticLabel: '$name, round $round, ${entry.points} points',
      excludeChildSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(border: divider),
        child: content,
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  const _TotalCell({required this.config, required this.index});

  final _TableConfig config;
  final int index;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final ps = config.players[index];
    final isLeader = config.bestTotal != null && ps.total == config.bestTotal;

    return Center(
      child: AnimatedDefaultTextStyle(
        duration: Motion.base,
        curve: Motion.ease,
        style: PT.number(
          isLeader ? pt.accent : pt.text,
          size: 20,
          weight: isLeader ? FontWeight.w800 : FontWeight.w700,
        ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        child: Text(ps.total.toString()),
      ),
    );
  }
}

class _RoundLabel extends StatelessWidget {
  const _RoundLabel({
    required this.config,
    required this.round,
    this.width,
    this.header = false,
  });

  final _TableConfig config;
  final int round;

  /// Fixed width, or null to fill its slot (flexed round columns).
  final double? width;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final canDelete = config.onDeleteRound != null;
    final highlighted = config.highlightRound == round;

    final label = Container(
      width: width,
      height: header ? _headerH : _rowH,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: header
            ? (highlighted ? pt.accentTint : pt.surfaceMuted)
            : Colors.transparent,
        border: Border(right: BorderSide(color: pt.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'R$round',
            style: PT.number(
              highlighted ? pt.accent : pt.textMuted,
              size: 13,
            ),
          ),
          // A quiet caret hints the label is tappable (opens delete confirm).
          if (canDelete) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more_rounded,
              size: 13,
              color: highlighted ? pt.accent : pt.textFaint,
            ),
          ],
        ],
      ),
    );

    if (!canDelete) return label;

    return Pressable(
      onTap: () => config.onDeleteRound!(round),
      scale: 0.9,
      isButton: true,
      semanticLabel: 'Round $round',
      semanticHint: 'Delete this round',
      excludeChildSemantics: true,
      child: label,
    );
  }
}

/// The top-left corner cell doubles as the show/hide names toggle.
class _CornerToggle extends StatelessWidget {
  const _CornerToggle({
    required this.config,
    required this.width,
    required this.height,
  });

  final _TableConfig config;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Pressable(
      onTap: config.onToggleNames,
      scale: 0.9,
      isButton: true,
      semanticLabel: config.showNames ? 'Hide names' : 'Show names',
      excludeChildSemantics: true,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: pt.border)),
        ),
        child: Icon(
          config.showNames
              ? Icons.unfold_less_rounded
              : Icons.badge_outlined,
          size: 18,
          color: pt.textMuted,
        ),
      ),
    );
  }
}

// ============================================================ reorder
/// Wraps a player cell so it can be long-press dragged to reorder. Uses
/// [LongPressDraggable] + [DragTarget] (not ReorderableListView) so it works
/// identically for a horizontal header row and a vertical name column, and
/// keeps the calm Notebook motion.
class _ReorderablePlayer extends StatefulWidget {
  const _ReorderablePlayer({
    required this.index,
    required this.enabled,
    required this.axis,
    required this.onReorder,
    required this.child,
  });

  final int index;
  final bool enabled;
  final Axis axis;
  final FutureOr<void> Function(int oldIndex, int newIndex)? onReorder;
  final Widget child;

  @override
  State<_ReorderablePlayer> createState() => _ReorderablePlayerState();
}

class _ReorderablePlayerState extends State<_ReorderablePlayer> {
  bool _hovering = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    if (!widget.enabled) return widget.child;

    final target = DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != widget.index,
      onAcceptWithDetails: (details) {
        setState(() => _hovering = false);
        final result = widget.onReorder?.call(details.data, widget.index);
        if (result is Future) unawaited(result);
      },
      onLeave: (_) => setState(() => _hovering = false),
      onMove: (_) {
        if (!_hovering) setState(() => _hovering = true);
      },
      builder: (context, candidate, rejected) {
        return AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.ease,
          decoration: BoxDecoration(
            color: _hovering ? pt.accentTint : Colors.transparent,
            border: _hovering
                ? Border.all(color: pt.accentBorder)
                : null,
          ),
          child: AnimatedOpacity(
            duration: Motion.fast,
            opacity: _dragging ? 0.35 : 1,
            child: widget.child,
          ),
        );
      },
    );

    return LongPressDraggable<int>(
      data: widget.index,
      axis: widget.axis,
      onDragStarted: () => setState(() => _dragging = true),
      onDragEnd: (_) => setState(() => _dragging = false),
      onDraggableCanceled: (_, _) => setState(() => _dragging = false),
      feedback: _DragFeedback(child: widget.child),
      childWhenDragging: Opacity(opacity: 0.25, child: widget.child),
      child: target,
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    // Feedback floats without an intrinsic size from the layout, so give it a
    // comfortable width and the floating shadow for a "lifted" feel.
    return Material(
      type: MaterialType.transparency,
      child: Transform.scale(
        scale: 1.06,
        child: Container(
          constraints: const BoxConstraints(minWidth: 96, maxWidth: 200),
          decoration: BoxDecoration(
            color: pt.surface,
            borderRadius: BorderRadius.circular(R.md),
            border: Border.all(color: pt.accentBorder),
            boxShadow: pt.shadowFloat,
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}

class _EmptyRounds extends StatelessWidget {
  const _EmptyRounds();

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_view_rounded, size: 40, color: pt.textFaint),
            const SizedBox(height: S.md),
            Text('No rounds yet', style: PT.sectionTitle(pt.text)),
            const SizedBox(height: S.xs),
            Text(
              'Add a round to start scoring',
              style: PT.body(pt.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
