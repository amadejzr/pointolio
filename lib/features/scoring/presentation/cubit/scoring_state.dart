part of 'scoring_cubit.dart';

enum ScoringStatus { initial, loading, loaded, error }

class ScoringState extends Equatable {
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

  final int gameId;
  final Game? game;
  final GameType? gameType;
  final List<PlayerScore> playerScores;
  final int roundCount;
  final ScoringStatus status;
  final String? errorMessage;

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
