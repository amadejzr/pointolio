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
  final GameType? gameType;
  final List<PlayerScore> playerScores;
  final int roundCount;
  final ScoringStatus status;
  final String? errorMessage;

  const ScoringState({
    required this.gameId,
    this.game,
    this.gameType,
    this.playerScores = const [],
    this.roundCount = 0,
    this.status = ScoringStatus.initial,
    this.errorMessage,
  });

  factory ScoringState.initial(int gameId) => ScoringState(gameId: gameId);

  /// Returns true if lowest score wins for this game type
  bool get lowestScoreWins => gameType?.lowestScoreWins ?? false;

  /// Returns the game type color if set
  int? get gameTypeColor => gameType?.color;

  ScoringState copyWith({
    int? gameId,
    Game? game,
    GameType? Function()? gameType,
    List<PlayerScore>? playerScores,
    int? roundCount,
    ScoringStatus? status,
    String? errorMessage,
  }) {
    return ScoringState(
      gameId: gameId ?? this.gameId,
      game: game ?? this.game,
      gameType: gameType != null ? gameType() : this.gameType,
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
        gameType,
        playerScores,
        roundCount,
        status,
        errorMessage,
      ];
}
