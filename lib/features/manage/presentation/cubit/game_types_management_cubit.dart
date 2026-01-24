import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/result/action_result.dart';
import 'package:pointolio/features/manage/data/game_types_management_repository.dart';

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

  Future<ActionResult> addGameType({
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
      return const ActionSuccess('Game added successfully');
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.conflict => 'A game with this name already exists',
        DomainErrorCode.validation => 'Invalid game information',
        _ => 'Failed to add game',
      };
      return ActionFailure(message);
    }
  }

  Future<ActionResult> updateGameType(
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
      emit(state.copyWith(clearGameTypeToEdit: true));
      return const ActionSuccess('Game updated successfully');
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.notFound => 'Game not found',
        DomainErrorCode.conflict => 'A game with this name already exists',
        DomainErrorCode.validation => 'Invalid game information',
        _ => 'Failed to update game',
      };
      return ActionFailure(message);
    }
  }

  Future<ActionResult> deleteGameType(int id) async {
    try {
      await _repository.deleteGameType(id);
      emit(state.copyWith(clearGameTypeToDelete: true));
      return const ActionSuccess('Game deleted successfully');
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.notFound => 'Game not found',
        _ => 'Failed to delete game',
      };
      emit(state.copyWith(clearGameTypeToDelete: true));
      return ActionFailure(message);
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

  @override
  Future<void> close() {
    unawaited(_gameTypesSubscription?.cancel());
    return super.close();
  }
}
