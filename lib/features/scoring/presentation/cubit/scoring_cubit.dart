import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/scoring/data/scoring_repository.dart';
import 'package:pointolio/features/scoring/domain/models.dart';

part 'scoring_state.dart';

class ScoringCubit extends Cubit<ScoringState> {
  ScoringCubit({
    required int gameId,
    required ScoringRepository scoringRepository,
  }) : _repository = scoringRepository,
       super(ScoringState.initial(gameId));

  final ScoringRepository _repository;

  StreamSubscription<List<(Player, GamePlayer)>>? _playersSubscription;
  StreamSubscription<List<ScoreEntry>>? _scoresSubscription;

  Future<void> loadData() async {
    emit(state.copyWith(status: ScoringStatus.loading));

    try {
      final game = await _repository.getGame(state.gameId);
      final gameType = await _repository.getGameType(game?.gameTypeId);
      emit(
        state.copyWith(
          game: game,
          gameType: () => gameType,
        ),
      );

      unawaited(_playersSubscription?.cancel());
      _playersSubscription = _repository
          .watchGamePlayers(state.gameId)
          .listen(
            _loadScores,
            onError: (Object e) {
              emit(
                state.copyWith(
                  status: ScoringStatus.error,
                  errorMessage: _mapErrorMessage(e, 'load players'),
                ),
              );
            },
          );

      unawaited(_scoresSubscription?.cancel());
      _scoresSubscription = _repository
          .watchScoreEntries(state.gameId)
          .listen(
            (_) => _reloadScores(),
            onError: (Object e) {
              emit(
                state.copyWith(
                  status: ScoringStatus.error,
                  errorMessage: _mapErrorMessage(e, 'watch scores'),
                ),
              );
            },
          );
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'load game'),
        ),
      );
    }
  }

  Future<void> _loadScores(List<(Player, GamePlayer)> players) async {
    try {
      final scores = await _repository.getPlayerScores(state.gameId);
      _processScores(players, scores);
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'load scores'),
        ),
      );
    }
  }

  Future<void> _reloadScores() async {
    try {
      final scores = await _repository.getPlayerScores(state.gameId);
      emit(
        state.copyWith(
          playerScores: scores,
          roundCount: _calculateMaxRound(scores),
          status: ScoringStatus.loaded,
        ),
      );
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'reload scores'),
        ),
      );
    }
  }

  void _processScores(
    List<(Player, GamePlayer)> players,
    List<PlayerScore> scores,
  ) {
    emit(
      state.copyWith(
        playerScores: scores,
        roundCount: _calculateMaxRound(scores),
        status: ScoringStatus.loaded,
      ),
    );
  }

  int _calculateMaxRound(List<PlayerScore> scores) {
    var maxRound = 0;
    for (final playerScore in scores) {
      for (final roundNumber in playerScore.roundScores.keys) {
        if (roundNumber > maxRound) {
          maxRound = roundNumber;
        }
      }
    }
    return maxRound;
  }

  Future<void> addRound(Map<int, int> scores) async {
    try {
      final newRound = state.roundCount + 1;
      await _repository.addRound(roundNumber: newRound, scores: scores);
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'add round'),
        ),
      );
    }
  }

  Future<void> updateScore(int scoreEntryId, int newPoints) async {
    try {
      await _repository.updateScore(
        scoreEntryId: scoreEntryId,
        points: newPoints,
      );
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'update score'),
        ),
      );
    }
  }

  Future<void> deleteRound(int roundNumber) async {
    try {
      await _repository.deleteRound(
        gameId: state.gameId,
        roundNumber: roundNumber,
      );
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'delete round'),
        ),
      );
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
      final gamePlayerIds = reorderedScores
          .map((ps) => ps.gamePlayer.id)
          .toList();
      await _repository.reorderPlayers(gamePlayerIds);
    } on DomainException catch (e) {
      // Revert on error
      emit(
        state.copyWith(
          playerScores: state.playerScores,
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'reorder players'),
        ),
      );
    }
  }

  Future<void> finishGame() async {
    try {
      await _repository.setGameFinished(state.gameId, finished: true);
      // Reload game to get updated finishedAt
      final game = await _repository.getGame(state.gameId);
      emit(state.copyWith(game: game));
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'finish game'),
        ),
      );
    }
  }

  Future<void> restoreGame() async {
    try {
      await _repository.setGameFinished(state.gameId, finished: false);
      // Reload game to get updated finishedAt
      final game = await _repository.getGame(state.gameId);
      emit(state.copyWith(game: game));
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'restore game'),
        ),
      );
    }
  }

  /// Returns all available players for editing the party.
  Future<List<Player>> getAllPlayers() async {
    try {
      return await _repository.getAllPlayers();
    } on DomainException {
      return [];
    }
  }

  /// Updates the game party name and player list.
  Future<void> updateParty({
    required String name,
    required List<Player> players,
  }) async {
    try {
      await _repository.updateGameParty(
        gameId: state.gameId,
        name: name,
        playerIds: players.map((p) => p.id).toList(),
      );
      // Reload game to get updated name
      final game = await _repository.getGame(state.gameId);
      emit(state.copyWith(game: game));
      // Players will be updated reactively via the stream subscription
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: ScoringStatus.error,
          errorMessage: _mapDomainError(e, 'update party'),
        ),
      );
    }
  }

  String _mapDomainError(DomainException e, String operation) {
    return switch (e.code) {
      DomainErrorCode.notFound => 'Could not find the requested data',
      DomainErrorCode.conflict => 'A conflict occurred while saving',
      DomainErrorCode.validation => 'Invalid data provided',
      DomainErrorCode.unauthorized => 'Not authorized to perform this action',
      DomainErrorCode.storage => 'Failed to $operation',
    };
  }

  String _mapErrorMessage(Object e, String operation) {
    if (e is DomainException) {
      return _mapDomainError(e, operation);
    }
    return 'Failed to $operation';
  }

  @override
  Future<void> close() {
    unawaited(_playersSubscription?.cancel());
    unawaited(_scoresSubscription?.cancel());
    return super.close();
  }
}
