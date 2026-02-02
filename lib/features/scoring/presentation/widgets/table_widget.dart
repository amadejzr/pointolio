import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';

class RoundsGrid extends StatefulWidget {
  const RoundsGrid({
    required this.state,
    this.onDeleteRound,
    this.onEditScore,
    this.onReorderPlayers,
    super.key,
  });

  final ScoringState state;
  final FutureOr<void> Function(int roundNumber)? onDeleteRound;
  final FutureOr<void> Function(
    int scoreEntryId,
    int currentPoints,
    String playerName,
    int round,
  )? onEditScore;
  final FutureOr<void> Function(int oldIndex, int newIndex)? onReorderPlayers;

  static const initialsColWidth = 90.0;
  static const expandedColWidth = 220.0;
  static const roundColWidth = 92.0;

  static const headerHeight = 48.0;
  static const rowHeight = 52.0;
  static const rowGap = 6.0;

  @override
  State<RoundsGrid> createState() => _RoundsGridState();

  static String fullName(PlayerScore ps) {
    final fn = ps.player.firstName.trim();
    final ln = (ps.player.lastName ?? '').trim();
    return ln.isEmpty ? fn : '$fn $ln';
  }

  static String initialsFromName(String name) {
    final parts = name.split(' ').where((p) => p.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.length >= 2
          ? p.substring(0, 2).toUpperCase()
          : p.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

class _RoundsGridState extends State<RoundsGrid>
    with SingleTickerProviderStateMixin {
  final _vLeft = ScrollController();
  final _vRight = ScrollController();

  // ✅ right-table horizontal controller (header + rows share one scroll)
  final _h = ScrollController();

  bool _syncing = false;
  bool _showFullNames = false;
  int? _dragIndex;

  // ✅ round-add animation state
  int _prevRoundCount = 0;
  int? _highlightRound; // 1-based
  late final AnimationController _pulse;

  void _toggleNames() => setState(() => _showFullNames = !_showFullNames);

  void _syncVertical({required bool fromLeft}) {
    if (_syncing) return;

    final src = fromLeft ? _vLeft : _vRight;
    final dst = fromLeft ? _vRight : _vLeft;

    if (!src.hasClients || !dst.hasClients) return;

    _syncing = true;
    final offset = src.offset.clamp(
      dst.position.minScrollExtent,
      dst.position.maxScrollExtent,
    );
    dst.jumpTo(offset);
    _syncing = false;
  }

  @override
  void initState() {
    super.initState();
    _vLeft.addListener(() => _syncVertical(fromLeft: true));
    _vRight.addListener(() => _syncVertical(fromLeft: false));

    _prevRoundCount = widget.state.roundCount;

    _pulse =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 650),
        )..addListener(() {
          if (mounted) setState(() {});
        });
  }

  @override
  void didUpdateWidget(covariant RoundsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newCount = widget.state.roundCount;
    final oldCount = _prevRoundCount;

    if (newCount > oldCount) {
      _highlightRound = newCount;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (_h.hasClients) {
          unawaited(
            _h.animateTo(
              _h.position.maxScrollExtent,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
            ),
          );
        }

        unawaited(
          _pulse.forward(from: 0).then((_) {
            if (!mounted) return;
            Future<void>.delayed(const Duration(milliseconds: 250), () {
              if (mounted) setState(() => _highlightRound = null);
            });
          }),
        );
      });
    }

    _prevRoundCount = newCount;
  }

  @override
  void dispose() {
    _vLeft.dispose();
    _vRight.dispose();
    _h.dispose();
    _pulse.dispose();
    super.dispose();
  }

  double get _pulse01 {
    // 0..1..0 (nice “flicker”)
    final t = _pulse.value;
    return math.sin(math.pi * t).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final roundCount = widget.state.roundCount;

    // Table spacing
    const colGap = 0.0; // ✅ table style => no gaps between columns
    const scoreSidePad = 10.0;

    final scoresWidth = roundCount == 0
        ? 1.0
        : (roundCount * RoundsGrid.roundColWidth) +
              ((roundCount - 1) * colGap) +
              (scoreSidePad * 2);

    final leftWidth = _showFullNames
        ? RoundsGrid.expandedColWidth
        : RoundsGrid.initialsColWidth;

    // Cleaner zebra + slightly stronger for readability
    Color zebraBg(int index) => index.isEven
        ? cs.surfaceContainerHighest.withValues(alpha: 0.62)
        : cs.surfaceContainerHighest.withValues(alpha: 0.30);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fallback = MediaQuery.sizeOf(context).height * 0.62;
        final tableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : math.max(320, fallback);

        return SizedBox(
          height: tableHeight.toDouble(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ================= LEFT (players) =================
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  width: leftWidth,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      _PlayersHeaderCompact(
                        expanded: _showFullNames,
                        onTap: _toggleNames,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ReorderableListView.builder(
                          scrollController: _vLeft,
                          physics: const ClampingScrollPhysics(),
                          buildDefaultDragHandles: false,
                          padding: EdgeInsets.zero,
                          onReorderStart: (i) => setState(() => _dragIndex = i),
                          onReorderEnd: (_) =>
                              setState(() => _dragIndex = null),
                          onReorder: (oldIndex, newIndex) async {
                            if (widget.onReorderPlayers == null) return;
                            if (newIndex > oldIndex) {
                              newIndex--;
                            }
                            widget.onReorderPlayers!(oldIndex, newIndex);
                          },
                          proxyDecorator: (child, index, animation) {
                            final ps = widget.state.playerScores[index];
                            final name = RoundsGrid.fullName(ps);
                            final initials = RoundsGrid.initialsFromName(name);

                            return Material(
                              color: Colors.transparent,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: RoundsGrid.rowGap,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: cs.primaryContainer.withValues(
                                    alpha: 0.30,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 16,
                                      offset: const Offset(0, 12),
                                      color: Colors.black.withValues(
                                        alpha: 0.14,
                                      ),
                                    ),
                                  ],
                                ),
                                child: _PlayerCellCompact(
                                  height: RoundsGrid.rowHeight,
                                  expanded: _showFullNames,
                                  color: ps.player.color != null
                                      ? Color(ps.player.color!)
                                      : null,
                                  fullName: name,
                                  initials: initials,
                                  animate: false,
                                ),
                              ),
                            );
                          },
                          itemCount: widget.state.playerScores.length,
                          itemBuilder: (context, index) {
                            final ps = widget.state.playerScores[index];
                            final name = RoundsGrid.fullName(ps);
                            final initials = RoundsGrid.initialsFromName(name);
                            final isDragging = _dragIndex == index;
                            final canReorder = widget.onReorderPlayers != null;

                            final cell = Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: RoundsGrid.rowGap,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: isDragging
                                    ? cs.primaryContainer.withValues(
                                        alpha: 0.22,
                                      )
                                    : zebraBg(index),
                              ),
                              child: _PlayerCellCompact(
                                color: ps.player.color != null
                                    ? Color(ps.player.color!)
                                    : null,
                                height: RoundsGrid.rowHeight,
                                expanded: _showFullNames,
                                fullName: name,
                                initials: initials,
                              ),
                            );

                            if (!canReorder) {
                              return KeyedSubtree(
                                key: ValueKey(ps.gamePlayer.id),
                                child: cell,
                              );
                            }

                            return ReorderableDelayedDragStartListener(
                              key: ValueKey(ps.gamePlayer.id),
                              index: index,
                              child: cell,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ================= RIGHT (table scores) =================
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: ClipRect(
                      child: LayoutBuilder(
                        builder: (context, rightConstraints) {
                          return SingleChildScrollView(
                            controller:
                                _h, // ✅ used for auto-scroll to last round
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: math.max(
                                scoresWidth,
                                rightConstraints.maxWidth,
                              ),
                              child: Column(
                                children: [
                                  _RoundsHeaderRowTable(
                                    roundCount: roundCount,
                                    sidePad: scoreSidePad,
                                    onDeleteRound: widget.onDeleteRound,
                                    highlightRound: _highlightRound,
                                    pulse01: _pulse01,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      controller: _vRight,
                                      padding: const EdgeInsets.only(bottom: 2),
                                      itemCount:
                                          widget.state.playerScores.length,
                                      itemBuilder: (context, index) {
                                        final ps =
                                            widget.state.playerScores[index];
                                        final isDragging = _dragIndex == index;

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: RoundsGrid.rowGap,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: scoreSidePad,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            color: isDragging
                                                ? cs.primaryContainer
                                                      .withValues(alpha: 0.18)
                                                : zebraBg(
                                                    index,
                                                  ).withValues(alpha: 0.95),
                                          ),
                                          child: _RoundsPlayerRowTable(
                                            playerScore: ps,
                                            roundCount: roundCount,
                                            onEditScore: widget.onEditScore,
                                            highlightRound: _highlightRound,
                                            pulse01: _pulse01,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =================== LEFT ===================

class _PlayersHeaderCompact extends StatelessWidget {
  const _PlayersHeaderCompact({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: RoundsGrid.headerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: cs.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            const Icon(Icons.people_outline, size: 18),
            if (expanded) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Players',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ] else ...[
              const Spacer(),
            ],
            Icon(
              expanded ? Icons.chevron_left : Icons.chevron_right,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCellCompact extends StatelessWidget {
  const _PlayerCellCompact({
    required this.height,
    required this.expanded,
    required this.fullName,
    required this.initials,
    this.animate = true,
    this.color,
  });

  final double height;
  final bool expanded;
  final String fullName;
  final String initials;
  final bool animate;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final nameStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500);

    return SizedBox(
      height: height,
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

            // ✅ Name reveal animation (clean & subtle)
            Expanded(
              child: AnimatedSwitcher(
                duration: animate
                    ? const Duration(milliseconds: 140)
                    : Duration.zero,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(-0.05, 0), // ~6px
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: expanded
                    ? Align(
                        key: const ValueKey('name'),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: nameStyle,
                        ),
                      )
                    : const SizedBox(key: ValueKey('empty')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== RIGHT (TABLE STYLE) ===================

class _RoundsHeaderRowTable extends StatelessWidget {
  const _RoundsHeaderRowTable({
    required this.roundCount,
    required this.sidePad,
    required this.highlightRound,
    required this.pulse01,
    this.onDeleteRound,
  });

  final int roundCount;
  final double sidePad;
  final FutureOr<void> Function(int roundNumber)? onDeleteRound;

  final int? highlightRound; // 1-based
  final double pulse01;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (roundCount == 0) return const SizedBox(height: RoundsGrid.headerHeight);

    return Container(
      height: RoundsGrid.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: sidePad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          for (int r = 1; r <= roundCount; r++) ...[
            _TableHeaderCell(
              width: RoundsGrid.roundColWidth,
              label: 'R$r',
              showDivider: r != roundCount,
              onLongPress: onDeleteRound == null
                  ? null
                  : () => onDeleteRound!(r),
              highlight: highlightRound == r,
              pulse01: pulse01,
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundsPlayerRowTable extends StatelessWidget {
  const _RoundsPlayerRowTable({
    required this.playerScore,
    required this.roundCount,
    required this.highlightRound,
    required this.pulse01,
    this.onEditScore,
  });

  final PlayerScore playerScore;
  final int roundCount;
  final FutureOr<void> Function(
    int scoreEntryId,
    int currentPoints,
    String playerName,
    int round,
  )? onEditScore;

  final int? highlightRound;
  final double pulse01;

  @override
  Widget build(BuildContext context) {
    if (roundCount == 0) return const SizedBox(height: RoundsGrid.rowHeight);

    return SizedBox(
      height: RoundsGrid.rowHeight,
      child: Row(
        children: [
          for (int r = 1; r <= roundCount; r++) ...[
            _TableScoreCell(
              width: RoundsGrid.roundColWidth,
              playerScore: playerScore,
              round: r,
              showDivider: r != roundCount,
              onEdit: onEditScore,
              highlight: highlightRound == r,
              pulse01: pulse01,
            ),
          ],
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell({
    required this.width,
    required this.label,
    required this.showDivider,
    required this.highlight,
    required this.pulse01,
    this.onLongPress,
  });

  final double width;
  final String label;
  final bool showDivider;
  final VoidCallback? onLongPress;

  final bool highlight;
  final double pulse01;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final highlightBg = highlight
        ? cs.primaryContainer.withValues(alpha: 0.08 + (0.20 * pulse01))
        : Colors.transparent;

    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: width,
        height: RoundsGrid.headerHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlightBg,
          border: showDivider
              ? Border(
                  right: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                  ),
                )
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _TableScoreCell extends StatelessWidget {
  const _TableScoreCell({
    required this.width,
    required this.playerScore,
    required this.round,
    required this.showDivider,
    required this.highlight,
    required this.pulse01,
    this.onEdit,
  });

  final double width;
  final PlayerScore playerScore;
  final int round;
  final bool showDivider;
  final FutureOr<void> Function(
    int scoreEntryId,
    int currentPoints,
    String playerName,
    int round,
  )? onEdit;

  final bool highlight;
  final double pulse01;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final entry = playerScore.roundScores[round];
    final value = entry?.points;

    final highlightBg = highlight
        ? cs.primaryContainer.withValues(alpha: 0.06 + (0.18 * pulse01))
        : Colors.transparent;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      width: width,
      height: RoundsGrid.rowHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlightBg,
        border: showDivider
            ? Border(
                right: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
              )
            : null,
      ),
      child: Text(
        value?.toString() ?? '-',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
    );

    final playerName = [
      playerScore.player.firstName,
      if ((playerScore.player.lastName ?? '').trim().isNotEmpty)
        playerScore.player.lastName!.trim(),
    ].join(' ');

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: entry == null || onEdit == null
          ? null
          : () => onEdit!(entry.id, entry.points, playerName, round),
      child: child,
    );
  }
}
