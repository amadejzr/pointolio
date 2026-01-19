import 'package:equatable/equatable.dart';
import 'package:scoreio/common/data/database/database.dart';

enum HomeStatus { initial, loading, loaded, error }

class GameWithPlayerCount extends Equatable {
  final Game game;
  final int playerCount;
  final GameType? gameType;

  const GameWithPlayerCount({
    required this.game,
    required this.playerCount,
    this.gameType,
  });

  @override
  List<Object?> get props => [game, playerCount, gameType];
}

class HomeState extends Equatable {
  final List<GameWithPlayerCount> games;
  final HomeStatus status;
  final String? errorMessage;
  final bool isEditing;

  const HomeState({
    this.games = const [],
    this.status = HomeStatus.initial,
    this.errorMessage,
    this.isEditing = false,
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    List<GameWithPlayerCount>? games,
    HomeStatus? status,
    String? errorMessage,
    bool? isEditing,
  }) {
    return HomeState(
      games: games ?? this.games,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [games, status, errorMessage, isEditing];
}
