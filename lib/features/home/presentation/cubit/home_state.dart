import 'package:equatable/equatable.dart';
import 'package:scoreio/common/data/database/database.dart';

enum HomeStatus { initial, loading, loaded, error }

class GameWithPlayerCount extends Equatable {
  const GameWithPlayerCount({
    required this.game,
    required this.playerCount,
    this.gameType,
  });

  final Game game;
  final int playerCount;
  final GameType? gameType;

  @override
  List<Object?> get props => [game, playerCount, gameType];
}

class HomeState extends Equatable {
  const HomeState({
    this.games = const [],
    this.status = HomeStatus.initial,
    this.errorMessage,
    this.snackbarMessage,
    this.isEditing = false,
    this.showCompleted = false,
  });

  factory HomeState.initial() => const HomeState();

  final List<GameWithPlayerCount> games;
  final HomeStatus status;
  final String? errorMessage;
  final String? snackbarMessage;
  final bool isEditing;
  final bool showCompleted;

  HomeState copyWith({
    List<GameWithPlayerCount>? games,
    HomeStatus? status,
    String? errorMessage,
    String? snackbarMessage,
    bool? isEditing,
    bool? showCompleted,
    bool clearSnackbar = false,
  }) {
    return HomeState(
      games: games ?? this.games,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      snackbarMessage:
          clearSnackbar ? null : snackbarMessage ?? this.snackbarMessage,
      isEditing: isEditing ?? this.isEditing,
      showCompleted: showCompleted ?? this.showCompleted,
    );
  }

  @override
  List<Object?> get props => [
        games,
        status,
        errorMessage,
        snackbarMessage,
        isEditing,
        showCompleted,
      ];
}
