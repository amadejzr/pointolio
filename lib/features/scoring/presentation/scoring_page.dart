import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/data/repositories/score_entry_repository.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/features/scoring/presentation/widgets/table_widget.dart';
import 'package:scoreio/features/scoring/presentation/widgets/totals_bottom_sheet.dart';

import 'cubit/scoring_cubit.dart';
import 'cubit/scoring_state.dart';

class ScoringPage extends StatelessWidget {
  const ScoringPage({super.key, required this.gameId});

  final int gameId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScoringCubit(
        gameId: gameId,
        gameRepository: locator<GameRepository>(),
        scoreEntryRepository: locator<ScoreEntryRepository>(),
      )..loadData(),
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

        return Scaffold(
          appBar: AppBar(
            title: _AppBarTitle(
              title: title,
              gameTypeColor: state.gameTypeColor,
              lowestScoreWins: state.lowestScoreWins,
            ),
            actions: [
              IconButton(
                tooltip: 'Add round',
                icon: const Icon(Icons.add_circle_outline),
                onPressed:
                    state.status == ScoringStatus.loaded &&
                        state.playerScores.isNotEmpty
                    ? () => _onAddRoundPressed(context, state)
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
          bottomNavigationBar: state.status == ScoringStatus.loaded
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
    );
  }

  void _onDeleteRoundPressed(BuildContext context, int round) async {
    final cubit = context.read<ScoringCubit>();

    final ok = await confirmDialog(
      context,
      title: 'Delete round R$round?',
      message: 'This will delete scores for round $round for all players.',
      confirmText: 'Delete',
    );
    if (ok) {
      cubit.deleteRound(round);
    }
  }

  void _onEditScorePressed(
    BuildContext context,
    int entryId,
    int current,
  ) async {
    final cubit = context.read<ScoringCubit>();

    final newPoints = await editPointsDialog(context, current);
    if (newPoints == null) return;
    cubit.updateScore(entryId, newPoints);
  }

  void _showTotalsSheet(BuildContext context, ScoringState state) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => TotalsSheet(state: state),
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

        return RoundsGrid(
          state: state,
          onDeleteRound: onDeleteRound,
          onEditScore: onEditScore,
          onReorderPlayers: onReorderPlayers,
        );
    }
  }
}

// =================== Dumb UI widgets ===================

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    required this.title,
    this.gameTypeColor,
    required this.lowestScoreWins,
  });

  final String title;
  final int? gameTypeColor;
  final bool lowestScoreWins;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasColor = gameTypeColor != null;
    final color = hasColor ? Color(gameTypeColor!) : cs.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color indicator
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: hasColor
                ? Text(
                    title.isNotEmpty ? title[0].toUpperCase() : '?',
                    style: tt.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : Icon(
                    Icons.sports_esports_outlined,
                    color: cs.onPrimary,
                    size: 18,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _WinConditionIndicator(lowestScoreWins: lowestScoreWins),
            ],
          ),
        ),
      ],
    );
  }
}

class _WinConditionIndicator extends StatelessWidget {
  const _WinConditionIndicator({required this.lowestScoreWins});

  final bool lowestScoreWins;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final icon = lowestScoreWins ? Icons.arrow_downward : Icons.arrow_upward;
    final label = lowestScoreWins ? 'Lowest wins' : 'Highest wins';
    final color = lowestScoreWins ? Colors.blue : Colors.orange;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
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

/// Grid:
/// - First col: Player
/// - Middle cols: rounds
/// - Last col: total

/// Grid:
/// - Normal table scrolls vertically + horizontally (like you already have)
/// - When horizontally scrolled, a small sticky left column appears (initials)
/// - Tap initials => shows full name (so you always know who is who)

/// Grid:
/// - Normal table scrolls vertically + horizontally (like you already have)
/// - When horizontally scrolled, a small sticky left column appears (initials)
/// - Tap initials => shows full name (so you always know who is who)

class TotalsBar extends StatelessWidget {
  const TotalsBar({super.key, required this.state, required this.onShowTotals});

  final ScoringState state;
  final VoidCallback onShowTotals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.only(left: 16, right:16, top: 12, bottom: MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Players: ${state.playerScores.length} • Rounds: ${state.roundCount}',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonal(
            onPressed: onShowTotals,
            child: const Text('Totals'),
          ),
        ],
      ),
    );
  }
}


class AddRoundSheet extends StatefulWidget {
  const AddRoundSheet({super.key, required this.state, required this.onSave});

  final ScoringState state;
  final FutureOr<void> Function(Map<int, int> scores)
  onSave; // gamePlayerId -> points

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
                    setState(() {});
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
        
            ...widget.state.playerScores.map((ps) {
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
                        keyboardType: TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
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

// =================== Reusable dialogs (dumb helpers) ===================

Future<int?> editPointsDialog(BuildContext context, int current) async {
  final controller = TextEditingController(text: current.toString());
  return showDialog<int>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit points'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(
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
