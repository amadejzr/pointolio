import 'package:equatable/equatable.dart';
import 'package:pointolio/common/data/database/database.dart';

enum HomeStatus { initial, loading, loaded, error }

class GameWithPlayerCount extends Equatable {
  const GameWithPlayerCount({
    required this.game,
    required this.playerCount,
    this.gameType,
    this.players = const [],
    this.roundCount = 0,
    this.winnerName,
  });

  final Game game;
  final int playerCount;
  final GameType? gameType;

  /// Roster, ordered as it appears in the game.
  final List<Player> players;

  /// Highest round number recorded (0 if the party has not started).
  final int roundCount;

  /// First name of the winner, only set once the party is finished.
  final String? winnerName;

  @override
  List<Object?> get props => [
    game,
    playerCount,
    gameType,
    players,
    roundCount,
    winnerName,
  ];
}

class HomeState extends Equatable {
  const HomeState({
    this.games = const [],
    this.status = HomeStatus.initial,
    this.errorMessage,
    this.snackbarMessage,
    this.showCompleted = false,
  });

  factory HomeState.initial() => const HomeState();

  final List<GameWithPlayerCount> games;
  final HomeStatus status;
  final String? errorMessage;
  final String? snackbarMessage;
  final bool showCompleted;

  HomeState copyWith({
    List<GameWithPlayerCount>? games,
    HomeStatus? status,
    String? errorMessage,
    String? snackbarMessage,
    bool? showCompleted,
    bool clearSnackbar = false,
  }) {
    return HomeState(
      games: games ?? this.games,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      snackbarMessage:
          clearSnackbar ? null : snackbarMessage ?? this.snackbarMessage,
      showCompleted: showCompleted ?? this.showCompleted,
    );
  }

  @override
  List<Object?> get props => [
    games,
    status,
    errorMessage,
    snackbarMessage,
    showCompleted,
  ];
}
