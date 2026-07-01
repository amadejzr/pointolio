import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/notebook_background.dart';
import 'package:pointolio/common/ui/widgets/page_app_bar.dart';
import 'package:pointolio/features/scoring/data/scoring_repository.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';
import 'package:pointolio/features/scoring/presentation/widgets/add_round_sheet.dart';
import 'package:pointolio/features/scoring/presentation/widgets/edit_party_bottom_sheet.dart';
import 'package:pointolio/features/scoring/presentation/widgets/leaderboard_view.dart';
import 'package:pointolio/features/scoring/presentation/widgets/score_table.dart';
import 'package:pointolio/features/scoring/presentation/widgets/scoring_dialogs.dart';
import 'package:pointolio/features/scoring/presentation/widgets/scoring_hint_banner.dart';
import 'package:pointolio/features/scoring/presentation/widgets/scoring_menu.dart';
import 'package:pointolio/features/sharing/presentation/share_page.dart';

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

enum ScoringView { table, standings }

class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key});

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  ScoringView _view = ScoringView.table;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Scaffold(
      backgroundColor: pt.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NotebookBackground()),
          SafeArea(
            bottom: false,
            child: BlocBuilder<ScoringCubit, ScoringState>(
              builder: (context, state) {
                final isFinished = state.game?.finishedAt != null;
                final isLoaded = state.status == ScoringStatus.loaded;

                return Column(
                  children: [
                    PageAppBar(
                      title: state.game?.name ?? 'Scoring',
                      action: _MoreButton(
                        isFinished: isFinished,
                        onEdit: () => _onEditParty(context, state),
                        onToggleFinished: () =>
                            _onToggleFinished(context, state),
                        onShare: () => _onShare(context, state),
                      ),
                    ),
                    if (isLoaded) _MetaStrip(state: state),
                    if (isLoaded && state.playerScores.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          S.lg,
                          S.xs,
                          S.lg,
                          S.sm,
                        ),
                        child: _ViewToggle(
                          view: _view,
                          onChanged: (v) => setState(() => _view = v),
                        ),
                      ),
                    if (isLoaded &&
                        !isFinished &&
                        _view == ScoringView.table &&
                        state.playerScores.isNotEmpty)
                      ScoringHintBanner(
                        canReorder: state.playerScores.length >= 2,
                      ),
                    Expanded(child: _body(context, state, isFinished)),
                    if (isLoaded)
                      _BottomBar(
                        state: state,
                        isFinished: isFinished,
                        onAddRound: () => _onAddRound(context, state),
                        onShare: () => _onShare(context, state),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ScoringState state, bool isFinished) {
    final pt = context.pt;

    switch (state.status) {
      case ScoringStatus.initial:
      case ScoringStatus.loading:
        return Center(child: CircularProgressIndicator(color: pt.accent));

      case ScoringStatus.error:
        return _ErrorState(
          message: state.errorMessage ?? 'Unknown error',
          onRetry: () => context.read<ScoringCubit>().loadData(),
        );

      case ScoringStatus.loaded:
        if (state.playerScores.isEmpty) {
          return const _MessageState(
            icon: Icons.groups_outlined,
            title: 'No players',
            message: 'Edit the party to add players.',
          );
        }

        return AnimatedSwitcher(
          duration: Motion.base,
          switchInCurve: Motion.ease,
          switchOutCurve: Motion.ease,
          child: _view == ScoringView.table
              ? KeyedSubtree(
                  key: const ValueKey('table'),
                  child: ScoreTable(
                    state: state,
                    onEditScore: isFinished
                        ? null
                        : (id, current, name, round) =>
                              _onEditScore(context, id, current, name, round),
                    onDeleteRound: isFinished
                        ? null
                        : (round) => _onDeleteRound(context, round),
                    onReorderPlayers: isFinished
                        ? null
                        : (o, n) =>
                              context.read<ScoringCubit>().reorderPlayers(o, n),
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey('standings'),
                  child: LeaderboardView(state: state),
                ),
        );
    }
  }

  // --- Screen actions (only here touches the cubit) ---

  Future<void> _onEditParty(BuildContext context, ScoringState state) async {
    final cubit = context.read<ScoringCubit>();
    final initialPlayers = state.playerScores.map((ps) => ps.player).toList();
    final allPlayers = await cubit.getAllPlayers();
    if (!context.mounted) return;

    final result = await EditPartyBottomSheet.show(
      context,
      initialName: state.game?.name ?? '',
      initialPlayers: initialPlayers,
      availablePlayers: allPlayers,
    );

    if (result != null) {
      unawaited(cubit.updateParty(name: result.name, players: result.players));
    }
  }

  void _onToggleFinished(BuildContext context, ScoringState state) {
    final cubit = context.read<ScoringCubit>();
    if (state.game?.finishedAt != null) {
      unawaited(cubit.restoreGame());
    } else {
      unawaited(cubit.finishGame());
    }
  }

  void _onAddRound(BuildContext context, ScoringState state) {
    final cubit = context.read<ScoringCubit>();
    final pt = context.pt;

    unawaited(
      showModalBottomSheet(
        isDismissible: false,
        context: context,
        isScrollControlled: true,
        // No drag handle / drag-to-dismiss - the sheet is committed with the
        // Save/Cancel buttons, so the drag affordance is just noise.
        showDragHandle: false,
        enableDrag: false,
        useSafeArea: true,
        backgroundColor: pt.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.xl)),
        ),
        builder: (sheetContext) {
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

  Future<void> _onDeleteRound(BuildContext context, int round) async {
    final cubit = context.read<ScoringCubit>();
    final ok = await confirmDeleteRound(context, round: round);
    if (ok) unawaited(cubit.deleteRound(round));
  }

  Future<void> _onEditScore(
    BuildContext context,
    int entryId,
    int current,
    String playerName,
    int round,
  ) async {
    final cubit = context.read<ScoringCubit>();
    final newPoints = await editPointsDialog(
      context,
      current: current,
      playerName: playerName,
      round: round,
    );
    if (newPoints == null) return;
    unawaited(cubit.updateScore(entryId, newPoints));
  }

  void _onShare(BuildContext context, ScoringState state) {
    unawaited(
      SharePage.show(
        context,
        scoringData: ScoringData(
          game: state.game,
          gameType: state.gameType,
          playerScores: state.playerScores,
          roundCount: state.roundCount,
        ),
        lowestScoreWins: state.lowestScoreWins,
        accent: state.gameType?.color == null
            ? null
            : Color(state.gameType!.color!),
      ),
    );
  }
}

// =================== Header pieces ===================

class _MoreButton extends StatelessWidget {
  const _MoreButton({
    required this.isFinished,
    required this.onEdit,
    required this.onToggleFinished,
    required this.onShare,
  });

  final bool isFinished;
  final VoidCallback onEdit;
  final VoidCallback onToggleFinished;
  final VoidCallback onShare;

  Future<void> _open(BuildContext context) async {
    final action = await showScoringMenu(context, isFinished: isFinished);
    switch (action) {
      case ScoringMenuAction.toggleFinished:
        onToggleFinished();
      case ScoringMenuAction.edit:
        onEdit();
      case ScoringMenuAction.share:
        onShare();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Pressable(
      onTap: () => unawaited(_open(context)),
      scale: 0.9,
      isButton: true,
      semanticLabel: 'Game menu',
      excludeChildSemantics: true,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: pt.surface,
          shape: BoxShape.circle,
          border: Border.all(color: pt.border),
        ),
        child: Icon(Icons.more_horiz_rounded, size: 20, color: pt.textMuted),
      ),
    );
  }
}

/// Compact strip under the header: win rule + game type + player/round counts.
class _MetaStrip extends StatelessWidget {
  const _MetaStrip({required this.state});

  final ScoringState state;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final lowest = state.lowestScoreWins;
    final typeName = state.gameType?.name;
    final typeColor = state.gameType?.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(S.lg, 0, S.lg, S.xs),
      child: Row(
        children: [
          _MetaPill(
            icon: lowest
                ? Icons.south_rounded
                : Icons.north_rounded,
            label: lowest ? 'Lowest wins' : 'Highest wins',
            color: pt.accent,
            tint: pt.accentTint,
          ),
          if (typeName != null) ...[
            const SizedBox(width: S.sm),
            _MetaPill(
              dotColor: typeColor != null ? Color(typeColor) : pt.textMuted,
              label: typeName,
              color: pt.text2,
              tint: pt.surfaceMuted,
            ),
          ],
          const Spacer(),
          Text(
            '${state.playerScores.length} · ${state.roundCount} '
            '${state.roundCount == 1 ? 'round' : 'rounds'}',
            style: PT.caption(pt.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    required this.color,
    required this.tint,
    this.icon,
    this.dotColor,
  });

  final String label;
  final Color color;
  final Color tint;
  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.sm, vertical: 5),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(R.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 13, color: color)
          else if (dotColor != null)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 5),
          Text(label, style: PT.chip(color)),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.view, required this.onChanged});

  final ScoringView view;
  final ValueChanged<ScoringView> onChanged;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final isTable = view == ScoringView.table;

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: pt.surfaceMuted,
        borderRadius: BorderRadius.circular(R.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segW = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedAlign(
                duration: Motion.base,
                curve: Motion.ease,
                alignment: isTable
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: segW,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: pt.surface,
                    borderRadius: BorderRadius.circular(R.sm),
                    boxShadow: pt.shadowCard,
                  ),
                ),
              ),
              Row(
                children: [
                  _ToggleSegment(
                    label: 'Table',
                    selected: isTable,
                    onTap: () => onChanged(ScoringView.table),
                  ),
                  _ToggleSegment(
                    label: 'Standings',
                    selected: !isTable,
                    onTap: () => onChanged(ScoringView.standings),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Expanded(
      child: Pressable(
        onTap: onTap,
        scale: 0.97,
        isButton: true,
        selected: selected,
        semanticLabel: label,
        excludeChildSemantics: true,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: Motion.fast,
            style: PT.bodyStrong(
              selected ? pt.text : pt.textMuted,
            ).copyWith(fontSize: 13.5),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

// =================== Bottom bar ===================

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.state,
    required this.isFinished,
    required this.onAddRound,
    required this.onShare,
  });

  final ScoringState state;
  final bool isFinished;
  final VoidCallback onAddRound;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final canAdd = state.playerScores.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        S.lg,
        S.sm,
        S.lg,
        MediaQuery.paddingOf(context).bottom + S.sm,
      ),
      child: isFinished
          ? _PrimaryButton(
              icon: Icons.ios_share_rounded,
              label: 'Share result',
              onTap: onShare,
              filled: false,
            )
          : _PrimaryButton(
              icon: Icons.add_rounded,
              label: 'Add round',
              onTap: canAdd ? onAddRound : null,
              filled: true,
            ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final enabled = onTap != null;

    return Pressable(
      onTap: onTap,
      scale: 0.97,
      isButton: true,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? pt.accent : pt.surface,
            borderRadius: BorderRadius.circular(R.lg),
            border: Border.all(color: filled ? pt.accent : pt.border),
            boxShadow: filled && enabled ? pt.shadowAccent : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: filled ? pt.accentText : pt.text,
              ),
              const SizedBox(width: S.sm),
              Text(
                label,
                style: PT.bodyStrong(filled ? pt.accentText : pt.text)
                    .copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== States ===================

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: pt.textFaint),
            const SizedBox(height: S.lg),
            Semantics(
              header: true,
              child: Text(title, style: PT.sectionTitle(pt.text)),
            ),
            const SizedBox(height: S.xs),
            Text(
              message,
              style: PT.body(pt.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 52, color: pt.players[3]),
            const SizedBox(height: S.lg),
            Semantics(
              header: true,
              child: Text(
                'Something went wrong',
                style: PT.sectionTitle(pt.text),
              ),
            ),
            const SizedBox(height: S.xs),
            Text(
              message,
              style: PT.body(pt.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: S.lg),
            Pressable(
              onTap: onRetry,
              scale: 0.94,
              isButton: true,
              semanticLabel: 'Retry',
              excludeChildSemantics: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: S.xl,
                  vertical: S.md,
                ),
                decoration: BoxDecoration(
                  color: pt.accentTint,
                  borderRadius: BorderRadius.circular(R.md),
                ),
                child: Text('Retry', style: PT.bodyStrong(pt.accent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
