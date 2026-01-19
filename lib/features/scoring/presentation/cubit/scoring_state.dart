import 'package:equatable/equatable.dart';
import 'package:scoreio/common/data/database/database.dart';

enum ScoringStatus { initial, loading, loaded, error }

class PlayerScore extends Equatable {
  final Player player;
  final GamePlayer gamePlayer;
  final Map<int, ScoreEntry> roundScores; // roundNumber -> ScoreEntry
  final int total;

  const PlayerScore({
    required this.player,
    required this.gamePlayer,
    required this.roundScores,
    required this.total,
  });

  int? getScoreForRound(int round) => roundScores[round]?.points;

  @override
  List<Object?> get props => [player, gamePlayer, roundScores, total];
}

class ScoringState extends Equatable {
  final int gameId;
  final Game? game;
  final List<PlayerScore> playerScores;
  final int roundCount;
  final ScoringStatus status;
  final String? errorMessage;

  const ScoringState({
    required this.gameId,
    this.game,
    this.playerScores = const [],
    this.roundCount = 0,
    this.status = ScoringStatus.initial,
    this.errorMessage,
  });

  factory ScoringState.initial(int gameId) => ScoringState(gameId: gameId);

  ScoringState copyWith({
    int? gameId,
    Game? game,
    List<PlayerScore>? playerScores,
    int? roundCount,
    ScoringStatus? status,
    String? errorMessage,
  }) {
    return ScoringState(
      gameId: gameId ?? this.gameId,
      game: game ?? this.game,
      playerScores: playerScores ?? this.playerScores,
      roundCount: roundCount ?? this.roundCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        gameId,
        game,
        playerScores,
        roundCount,
        status,
        errorMessage,
      ];
}
