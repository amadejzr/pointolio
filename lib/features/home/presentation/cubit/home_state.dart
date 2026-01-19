import 'package:equatable/equatable.dart';
import 'package:scoreio/common/data/database/database.dart';

enum HomeStatus { initial, loading, loaded, error }

class GameWithPlayerCount extends Equatable {
  final Game game;
  final int playerCount;

  const GameWithPlayerCount({
    required this.game,
    required this.playerCount,
  });

  @override
  List<Object?> get props => [game, playerCount];
}

class HomeState extends Equatable {
  final List<GameWithPlayerCount> games;
  final HomeStatus status;
  final String? errorMessage;

  const HomeState({
    this.games = const [],
    this.status = HomeStatus.initial,
    this.errorMessage,
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    List<GameWithPlayerCount>? games,
    HomeStatus? status,
    String? errorMessage,
  }) {
    return HomeState(
      games: games ?? this.games,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [games, status, errorMessage];
}
