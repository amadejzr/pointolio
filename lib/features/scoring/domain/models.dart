import 'package:equatable/equatable.dart';
import 'package:scoreio/common/data/database/database.dart';

class PlayerScore extends Equatable {
  const PlayerScore({
    required this.player,
    required this.gamePlayer,
    required this.roundScores,
    required this.total,
  });

  final Player player;
  final GamePlayer gamePlayer;
  final Map<int, ScoreEntry> roundScores;
  final int total;

  int? getScoreForRound(int round) => roundScores[round]?.points;

  @override
  List<Object?> get props => [player, gamePlayer, roundScores, total];
}

class ScoringData extends Equatable {
  const ScoringData({
    this.game,
    this.gameType,
    this.playerScores = const [],
    this.roundCount = 0,
  });

  final Game? game;
  final GameType? gameType;
  final List<PlayerScore> playerScores;
  final int roundCount;

  @override
  List<Object?> get props => [game, gameType, playerScores, roundCount];
}
