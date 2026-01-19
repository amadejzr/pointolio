import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GameRepository _gameRepository;
  StreamSubscription? _gamesSubscription;

  HomeCubit({
    required GameRepository gameRepository,
  })  : _gameRepository = gameRepository,
        super(HomeState.initial());

  void loadGames() {
    emit(state.copyWith(status: HomeStatus.loading));

    _gamesSubscription?.cancel();
    _gamesSubscription = _gameRepository.watchAll().listen(
      (games) async {
        final gamesWithCounts = <GameWithPlayerCount>[];
        for (final game in games) {
          final count = await _gameRepository.getPlayerCount(game.id);
          gamesWithCounts.add(GameWithPlayerCount(
            game: game,
            playerCount: count,
          ));
        }
        emit(state.copyWith(
          games: gamesWithCounts,
          status: HomeStatus.loaded,
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Failed to load games: $error',
        ));
      },
    );
  }

  Future<void> deleteGame(int id) async {
    try {
      await _gameRepository.delete(id);
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'Failed to delete game: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _gamesSubscription?.cancel();
    return super.close();
  }
}
