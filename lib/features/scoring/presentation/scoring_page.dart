import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/features/scoring/data/scoring_repository.dart';
import 'package:scoreio/features/scoring/domain/models.dart';
import 'package:scoreio/features/scoring/presentation/cubit/scoring_cubit.dart';
import 'package:scoreio/features/scoring/presentation/widgets/app_bar_title_widget.dart';
import 'package:scoreio/features/scoring/presentation/widgets/table_widget.dart';
import 'package:scoreio/features/scoring/presentation/widgets/totals_bottom_sheet.dart';
import 'package:scoreio/features/sharing/presentation/share_sheet.dart';

class ScoringPage extends StatelessWidget {
  const ScoringPage({required this.gameId, super.key});

  final int gameId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ScoringCubit(
          gameId: gameId,
          scoringRepository: ScoringRepository(locator<AppDatabase>()),
        );
        unawaited(cubit.loadData());
        return cubit;
      },
      child: const ScoringScreen(),
    );
  }
}

class ScoringScreen extends StatelessWidget {
  const ScoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoringCubit, ScoringState>(
      builder: (context, state) {
        final title = state.game?.gameTypeNameSnapshot ?? 'Scoring';
        final isLandscape =
            MediaQuery.orientationOf(context) == Orientation.landscape;

        return Scaffold(
          appBar: AppBar(
            title: AppBarTitleMenu(
              title: title,
              gameTypeColor: state.gameTypeColor,
              lowestScoreWins: state.lowestScoreWins,
              isFinished: state.game?.finishedAt != null,
              gameTypeName: state.gameType?.name,
              onEdit: () {},
              onToggleFinished: () {
                if (state.game?.finishedAt != null) {
                  unawaited(context.read<ScoringCubit>().restoreGame());
                } else {
                  unawaited(context.read<ScoringCubit>().finishGame());
                }
              },
              onShare: () {
                unawaited(
                  ShareSheet.show(
                    context,
                    scoringData: ScoringData(
                      game: state.game,
                      gameType: state.gameType,
                      playerScores: state.playerScores,
                      roundCount: state.roundCount,
                    ),
                    lowestScoreWins: state.lowestScoreWins,
                    primaryColor: state.gameType?.color == null
                        ? null
                        : Color(state.gameType!.color!),
                  ),
                );
              },
            ),
            actionsPadding: isLandscape ? null : Spacing.horizontalPage,
            actions: [
              if (isLandscape && state.status == ScoringStatus.loaded)
                _AppBarStats(
                  state: state,
                  onOpenTotals: () => _showTotalsSheet(context, state),
                ),
              if (state.game?.finishedAt == null)
                IconButton.filled(
                  tooltip: 'Add round',
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed:
                      state.status == ScoringStatus.loaded &&
                          state.playerScores.isNotEmpty
                      ? () => _onAddRoundPressed(context, state)
                      : null,
                )
              else
                IconButton.filled(
                  tooltip: 'Share result',
                  icon: const Icon(
                    Icons.ios_share,
                    color: Colors.white,
                  ),
                  onPressed: state.status == ScoringStatus.loaded
                      ? () {
                          unawaited(
                            ShareSheet.show(
                              context,
                              scoringData: ScoringData(
                                game: state.game,
                                gameType: state.gameType,
                                playerScores: state.playerScores,
                                roundCount: state.roundCount,
                              ),
                              lowestScoreWins: state.lowestScoreWins,
                              primaryColor: state.gameType?.color == null
                                  ? null
                                  : Color(state.gameType!.color!),
                            ),
                          );
                        }
                      : null,
                ),
            ],
          ),
          body: _ScoringBody(
            state: state,
            onRetry: () => context.read<ScoringCubit>().loadData(),
            onDeleteRound: (round) => _onDeleteRoundPressed(context, round),
            onEditScore: (entryId, current) =>
                _onEditScorePressed(context, entryId, current),
            onReorderPlayers: (oldIndex, newIndex) =>
                context.read<ScoringCubit>().reorderPlayers(oldIndex, newIndex),
          ),

          // Portrait: keep the totals bar
          // Landscape: remove it so the table gets the full page
          bottomNavigationBar:
              (!isLandscape && state.status == ScoringStatus.loaded)
              ? TotalsBar(
                  state: state,
                  onShowTotals: () => _showTotalsSheet(context, state),
                )
              : null,
        );
      },
    );
  }

  // --- Screen actions (only here touches cubit) ---

  void _onAddRoundPressed(BuildContext context, ScoringState state) {
    final cubit = context.read<ScoringCubit>();

    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          // IMPORTANT: pass the same cubit to the sheet context
          return BlocProvider.value(
            value: cubit,
            child: AddRoundSheet(
              state: state,
              onSave: (scores) async {
                await cubit.addRound(scores);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _onDeleteRoundPressed(BuildContext context, int round) async {
    final cubit = context.read<ScoringCubit>();

    final ok = await confirmDialog(
      context,
      title: 'Delete round R$round?',
      message: 'This will delete scores for round $round for all players.',
      confirmText: 'Delete',
    );
    if (ok) unawaited(cubit.deleteRound(round));
  }

  Future<void> _onEditScorePressed(
    BuildContext context,
    int entryId,
    int current,
  ) async {
    final cubit = context.read<ScoringCubit>();

    final newPoints = await editPointsDialog(context, current);
    if (newPoints == null) return;
    unawaited(cubit.updateScore(entryId, newPoints));
  }

  void _showTotalsSheet(BuildContext context, ScoringState state) {
    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.80,
          child: TotalsSheet(state: state),
        ),
      ),
    );
  }
}

class _ScoringBody extends StatelessWidget {
  const _ScoringBody({
    required this.state,
    required this.onRetry,
    required this.onDeleteRound,
    required this.onEditScore,
    required this.onReorderPlayers,
  });

  final ScoringState state;
  final VoidCallback onRetry;
  final FutureOr<void> Function(int roundNumber) onDeleteRound;
  final FutureOr<void> Function(int scoreEntryId, int currentPoints)
  onEditScore;
  final FutureOr<void> Function(int oldIndex, int newIndex) onReorderPlayers;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ScoringStatus.initial:
      case ScoringStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ScoringStatus.error:
        return ErrorView(
          message: state.errorMessage ?? 'Unknown error',
          onRetry: onRetry,
        );

      case ScoringStatus.loaded:
        if (state.playerScores.isEmpty) {
          return const Center(child: Text('No players in this game.'));
        }

        return SafeArea(
          child: RoundsGrid(
            state: state,
            onDeleteRound: onDeleteRound,
            onEditScore: onEditScore,
            onReorderPlayers: onReorderPlayers,
          ),
        );
    }
  }
}

// =================== AppBar UI ===================

/// Landscape-only: compact stats in AppBar with tooltips on long-press/hover
class _AppBarStats extends StatelessWidget {
  const _AppBarStats({
    required this.state,
    required this.onOpenTotals,
  });

  final ScoringState state;
  final VoidCallback onOpenTotals;

  @override
  Widget build(BuildContext context) {
    final playersCount = state.playerScores.length;
    final roundsCount = state.roundCount;

    final leader = _leaderLabel(state);
    final leaderTooltip = state.lowestScoreWins
        ? 'Leader (lowest total)'
        : 'Leader (highest total)';

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Players',
            waitDuration: const Duration(milliseconds: 350),
            child: _MiniChip(
              icon: Icons.people_outline,
              label: '$playersCount',
              onTap: null,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Rounds',
            waitDuration: const Duration(milliseconds: 350),
            child: _MiniChip(
              icon: Icons.grid_view_rounded,
              label: '$roundsCount',
              onTap: null,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: leaderTooltip,
            waitDuration: const Duration(milliseconds: 350),
            child: _MiniChip(
              icon: Icons.emoji_events_outlined,
              label: leader,
              onTap: onOpenTotals, // nice: tap leader => totals
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Totals',
            onPressed: onOpenTotals,
            icon: const Icon(Icons.summarize_outlined),
          ),
        ],
      ),
    );
  }

  String _leaderLabel(ScoringState state) {
    if (state.playerScores.isEmpty) return '-';

    // Determine best total based on scoring mode
    var best = state.playerScores.first;

    for (final ps in state.playerScores.skip(1)) {
      final isBetter = state.lowestScoreWins
          ? ps.total < best.total
          : ps.total > best.total;
      if (isBetter) best = ps;
    }

    // Handle ties (optional but nice)
    final bestTotal = best.total;
    final tied = state.playerScores
        .where((ps) => ps.total == bestTotal)
        .toList();
    if (tied.length > 1) {
      return 'Tie';
    }

    // Keep it short for appbar: "Maj J."
    final full = _playerDisplayName(best.player);
    final parts = full.split(' ').where((e) => e.trim().isNotEmpty).toList();
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts[1][0].toUpperCase()}.';
  }

  String _playerDisplayName(Player player) {
    if ((player.lastName ?? '').trim().isNotEmpty) {
      return '${player.firstName} ${player.lastName!.trim()}';
    }
    return player.firstName;
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

// =================== Dumb widgets ===================

class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 36, color: cs.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// =================== AddRoundSheet + dialogs (unchanged) ===================

class AddRoundSheet extends StatefulWidget {
  const AddRoundSheet({required this.state, required this.onSave, super.key});

  final ScoringState state;
  final FutureOr<void> Function(Map<int, int> scores) onSave;

  @override
  State<AddRoundSheet> createState() => _AddRoundSheetState();
}

class _AddRoundSheetState extends State<AddRoundSheet> {
  late final Map<int, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final ps in widget.state.playerScores)
        ps.gamePlayer.id: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveRound() async {
    final scores = <int, int>{};
    for (final e in _controllers.entries) {
      scores[e.key] = int.tryParse(e.value.text.trim()) ?? 0;
    }
    await widget.onSave(scores);
  }

  @override
  Widget build(BuildContext context) {
    final roundNumber = widget.state.roundCount + 1;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Add Round R$roundNumber',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    for (final c in _controllers.values) {
                      c.clear();
                    }
                    setState(() {});
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.state.playerScores.asMap().entries.map((entry) {
              final index = entry.key;
              final ps = entry.value;

              final isFirst = index == 0;
              final isLast = index == widget.state.playerScores.length - 1;

              final name = [
                ps.player.firstName,
                if ((ps.player.lastName ?? '').trim().isNotEmpty)
                  ps.player.lastName!.trim(),
              ].join(' ');

              final ctrl = _controllers[ps.gamePlayer.id]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: ctrl,
                        autofocus: isFirst,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        textInputAction: isLast
                            ? TextInputAction.done
                            : TextInputAction.next,
                        onSubmitted: isLast ? (_) => _saveRound() : null,
                        decoration: const InputDecoration(labelText: 'Points'),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Row(
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
                    onPressed: () async {
                      final scores = <int, int>{};
                      for (final e in _controllers.entries) {
                        scores[e.key] = int.tryParse(e.value.text.trim()) ?? 0;
                      }
                      await widget.onSave(scores);
                    },
                    child: const Text('Save round'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

Future<int?> editPointsDialog(BuildContext context, int current) async {
  final controller = TextEditingController(text: current.toString());
  return showDialog<int>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit points'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter points (e.g. 10, -2)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final v = int.tryParse(controller.text.trim());
            if (v == null) return;
            Navigator.pop(context, v);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
}) async {
  return (await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        ),
      )) ??
      false;
}
