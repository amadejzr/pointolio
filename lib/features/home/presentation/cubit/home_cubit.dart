import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/exception/domain_exception.dart';
import 'package:scoreio/features/home/data/home_repository.dart';
import 'package:scoreio/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required HomeRepository homeRepository})
    : _repository = homeRepository,
      super(HomeState.initial());
  final HomeRepository _repository;
  StreamSubscription<List<Game>>? _gamesSubscription;

  void loadGames() {
    emit(state.copyWith(status: HomeStatus.loading));

    unawaited(_gamesSubscription?.cancel());
    _gamesSubscription = _repository.watchAllGames().listen(
      (games) async {
        final gamesWithCounts = <GameWithPlayerCount>[];
        for (final game in games) {
          final count = await _repository.getPlayerCount(game.id);
          final gameType = await _repository.getGameType(game.gameTypeId);
          gamesWithCounts.add(
            GameWithPlayerCount(
              game: game,
              playerCount: count,
              gameType: gameType,
            ),
          );
        }
        emit(state.copyWith(games: gamesWithCounts, status: HomeStatus.loaded));
      },
      onError: (Object _) {
        emit(
          state.copyWith(
            status: HomeStatus.error,
            errorMessage: 'Failed to load games. Please reload.',
          ),
        );
      },
    );
  }

  Future<void> deleteGame(int id) async {
    try {
      await _repository.deleteGame(id);
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.notFound => 'Game not found',
        _ => 'Failed to delete game',
      };
      emit(state.copyWith(snackbarMessage: message));
    }
  }

  void clearSnackbar() {
    emit(state.copyWith(clearSnackbar: true));
  }

  void toggleEditMode() {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  void exitEditMode() {
    emit(state.copyWith(isEditing: false));
  }

  @override
  Future<void> close() {
    unawaited(_gamesSubscription?.cancel());
    return super.close();
  }
}
