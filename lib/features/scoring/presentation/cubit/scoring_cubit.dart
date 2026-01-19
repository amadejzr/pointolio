import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/data/repositories/score_entry_repository.dart';
import 'package:scoreio/features/scoring/presentation/cubit/scoring_state.dart';

class ScoringCubit extends Cubit<ScoringState> {
  final GameRepository _gameRepository;
  final ScoreEntryRepository _scoreEntryRepository;

  StreamSubscription? _playersSubscription;
  StreamSubscription? _scoresSubscription;

  ScoringCubit({
    required int gameId,
    required GameRepository gameRepository,
    required ScoreEntryRepository scoreEntryRepository,
  })  : _gameRepository = gameRepository,
        _scoreEntryRepository = scoreEntryRepository,
        super(ScoringState.initial(gameId));

  Future<void> loadData() async {
    emit(state.copyWith(status: ScoringStatus.loading));

    try {
      final game = await _gameRepository.getById(state.gameId);
      final gameType = await _gameRepository.getGameType(game?.gameTypeId);
      emit(state.copyWith(
        game: game,
        gameType: () => gameType,
      ));

      _playersSubscription?.cancel();
      _playersSubscription =
          _gameRepository.watchGamePlayers(state.gameId).listen((players) {
        _loadScores(players);
      });

      _scoresSubscription?.cancel();
      _scoresSubscription =
          _scoreEntryRepository.watchByGameId(state.gameId).listen((_) {
        _reloadScores();
      });
    } catch (e) {
      emit(state.copyWith(
        status: ScoringStatus.error,
        errorMessage: 'Failed to load game: $e',
      ));
    }
  }

  Future<void> _loadScores(List<(Player, GamePlayer)> players) async {
    try {
      final scores = await _scoreEntryRepository.getByGameId(state.gameId);
      _processScores(players, scores);
    } catch (e) {
      emit(state.copyWith(
        status: ScoringStatus.error,
        errorMessage: 'Failed to load scores: $e',
      ));
    }
  }

  Future<void> _reloadScores() async {
    try {
      final players = await _gameRepository.getGamePlayers(state.gameId);
      final scores = await _scoreEntryRepository.getByGameId(state.gameId);
      _processScores(players, scores);
    } catch (e) {
      emit(state.copyWith(
        status: ScoringStatus.error,
        errorMessage: 'Failed to reload scores: $e',
      ));
    }
  }

  void _processScores(
      List<(Player, GamePlayer)> players, List<ScoreEntry> scores) {
    int maxRound = 0;
    final playerScores = <PlayerScore>[];

    for (final (player, gamePlayer) in players) {
      final playerEntries =
          scores.where((s) => s.gamePlayerId == gamePlayer.id).toList();

      final roundScores = <int, ScoreEntry>{};
      int total = 0;

      for (final entry in playerEntries) {
        roundScores[entry.roundNumber] = entry;
        total += entry.points;
        if (entry.roundNumber > maxRound) {
          maxRound = entry.roundNumber;
        }
      }

      playerScores.add(PlayerScore(
        player: player,
        gamePlayer: gamePlayer,
        roundScores: roundScores,
        total: total,
      ));
    }

    emit(state.copyWith(
      playerScores: playerScores,
      roundCount: maxRound,
      status: ScoringStatus.loaded,
    ));
  }

  Future<void> addRound(Map<int, int> scores) async {
    // scores: gamePlayerId -> points
    try {
      final newRound = state.roundCount + 1;

      for (final entry in scores.entries) {
        await _scoreEntryRepository.add(
          gamePlayerId: entry.key,
          roundNumber: newRound,
          points: entry.value,
        );
      }
    } catch (e) {
      emit(state.copyWith(
        status: ScoringStatus.error,
        errorMessage: 'Failed to add round: $e',
      ));
    }
  }

  Future<void> updateScore(int scoreEntryId, int newPoints) async {
    try {
      await _scoreEntryRepository.update(id: scoreEntryId, points: newPoints);
    } catch (e) {
      emit(state.copyWith(
        status: ScoringStatus.error,
        errorMessage: 'Failed to update score: $e',
      ));
    }
  }

  Future<void> deleteRound(int roundNumber) async {
    try {
      await _scoreEntryRepository.deleteRound(state.gameId, roundNumber);
    } catch (e) {
      emit(state.copyWith(
        status: ScoringStatus.error,
        errorMessage: 'Failed to delete round: $e',
      ));
    }
  }

  Future<void> reorderPlayers(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    // Optimistic UI update - reorder immediately to prevent flicker
    final reorderedScores = List<PlayerScore>.from(state.playerScores);
    final moved = reorderedScores.removeAt(oldIndex);
    reorderedScores.insert(newIndex, moved);
    emit(state.copyWith(playerScores: reorderedScores));

    try {
      // Persist the new order
      final gamePlayerIds = reorderedScores.map((ps) => ps.gamePlayer.id).toList();
      await _gameRepository.reorderPlayers(gamePlayerIds);
    } catch (e) {
      // Revert on error
      emit(state.copyWith(
        playerScores: state.playerScores,
        status: ScoringStatus.error,
        errorMessage: 'Failed to reorder players: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _playersSubscription?.cancel();
    _scoresSubscription?.cancel();
    return super.close();
  }
}
