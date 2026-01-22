import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/exception/domain_exception.dart';
import 'package:scoreio/features/manage/data/game_types_management_repository.dart';

part 'game_types_management_state.dart';

class GameTypesManagementCubit extends Cubit<GameTypesManagementState> {
  GameTypesManagementCubit({required GameTypesManagementRepository repository})
      : _repository = repository,
        super(GameTypesManagementState.initial());

  final GameTypesManagementRepository _repository;
  StreamSubscription<List<GameType>>? _gameTypesSubscription;

  void loadGameTypes() {
    emit(state.copyWith(status: GameTypesManagementStatus.loading));

    unawaited(_gameTypesSubscription?.cancel());
    _gameTypesSubscription = _repository.watchAllGameTypes().listen(
      (gameTypes) {
        emit(
          state.copyWith(
            gameTypes: gameTypes,
            status: GameTypesManagementStatus.loaded,
          ),
        );
      },
      onError: (Object _) {
        emit(
          state.copyWith(
            status: GameTypesManagementStatus.error,
            errorMessage: 'Failed to load game types. Please reload.',
          ),
        );
      },
    );
  }

  Future<void> addGameType({
    required String name,
    required bool lowestScoreWins,
    int? color,
  }) async {
    try {
      await _repository.addGameType(
        name: name,
        lowestScoreWins: lowestScoreWins,
        color: color,
      );
      emit(
        state.copyWith(
          snackbarMessage: 'Game type added successfully',
        ),
      );
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.conflict => 'A game type with this name already exists',
        DomainErrorCode.validation => 'Invalid game type information',
        _ => 'Failed to add game type',
      };
      emit(state.copyWith(snackbarMessage: message));
    }
  }

  Future<void> updateGameType(
    int id, {
    required String name,
    required bool lowestScoreWins,
    int? color,
  }) async {
    try {
      await _repository.updateGameType(
        id,
        name: name,
        lowestScoreWins: lowestScoreWins,
        color: color,
      );
      emit(
        state.copyWith(
          snackbarMessage: 'Game type updated successfully',
          clearGameTypeToEdit: true,
        ),
      );
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.notFound => 'Game type not found',
        DomainErrorCode.conflict => 'A game type with this name already exists',
        DomainErrorCode.validation => 'Invalid game type information',
        _ => 'Failed to update game type',
      };
      emit(state.copyWith(snackbarMessage: message));
    }
  }

  Future<void> deleteGameType(int id) async {
    try {
      await _repository.deleteGameType(id);
      emit(
        state.copyWith(
          snackbarMessage: 'Game type deleted successfully',
          clearGameTypeToDelete: true,
        ),
      );
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.notFound => 'Game type not found',
        _ => 'Failed to delete game type',
      };
      emit(
        state.copyWith(
          snackbarMessage: message,
          clearGameTypeToDelete: true,
        ),
      );
    }
  }

  void setSearchQuery(String? query) {
    emit(
      state.copyWith(
        searchQuery: query,
        clearSearchQuery: query == null || query.trim().isEmpty,
      ),
    );
  }

  void showDeleteConfirmation(int gameTypeId) {
    emit(state.copyWith(gameTypeToDeleteId: gameTypeId));
  }

  void hideDeleteConfirmation() {
    emit(state.copyWith(clearGameTypeToDelete: true));
  }

  void showEditGameType(GameType gameType) {
    emit(state.copyWith(gameTypeToEdit: gameType));
  }

  void hideEditGameType() {
    emit(state.copyWith(clearGameTypeToEdit: true));
  }

  void clearSnackbar() {
    emit(state.copyWith(clearSnackbar: true));
  }

  @override
  Future<void> close() {
    unawaited(_gameTypesSubscription?.cancel());
    return super.close();
  }
}
