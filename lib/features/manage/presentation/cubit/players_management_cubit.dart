import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/exception/domain_exception.dart';
import 'package:scoreio/features/manage/data/players_management_repository.dart';

part 'players_management_state.dart';

class PlayersManagementCubit extends Cubit<PlayersManagementState> {
  PlayersManagementCubit({required PlayersManagementRepository repository})
    : _repository = repository,
      super(PlayersManagementState.initial());

  final PlayersManagementRepository _repository;
  StreamSubscription<List<Player>>? _playersSubscription;

  void loadPlayers() {
    emit(state.copyWith(status: PlayersManagementStatus.loading));

    unawaited(_playersSubscription?.cancel());
    _playersSubscription = _repository.watchAllPlayers().listen(
      (players) {
        emit(
          state.copyWith(
            players: players,
            status: PlayersManagementStatus.loaded,
          ),
        );
      },
      onError: (Object _) {
        emit(
          state.copyWith(
            status: PlayersManagementStatus.error,
            errorMessage: 'Failed to load players. Please reload.',
          ),
        );
      },
    );
  }

  Future<void> addPlayer(String firstName, String? lastName) async {
    try {
      await _repository.addPlayer(
        firstName: firstName,
        lastName: lastName,
      );
      emit(
        state.copyWith(
          snackbarMessage: 'Player added successfully',
        ),
      );
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.conflict => 'A player with this name already exists',
        DomainErrorCode.validation => 'Invalid player information',
        _ => 'Failed to add player',
      };
      emit(state.copyWith(snackbarMessage: message));
    }
  }

  Future<void> updatePlayer(
    int id,
    String firstName,
    String? lastName,
  ) async {
    try {
      await _repository.updatePlayer(
        id,
        firstName: firstName,
        lastName: lastName,
      );
      emit(
        state.copyWith(
          snackbarMessage: 'Player updated successfully',
          clearPlayerToEdit: true,
        ),
      );
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.notFound => 'Player not found',
        DomainErrorCode.conflict => 'A player with this name already exists',
        DomainErrorCode.validation => 'Invalid player information',
        _ => 'Failed to update player',
      };
      emit(state.copyWith(snackbarMessage: message));
    }
  }

  Future<void> deletePlayer(int id) async {
    try {
      await _repository.deletePlayer(id);
      emit(
        state.copyWith(
          snackbarMessage: 'Player deleted successfully',
          clearPlayerToDelete: true,
        ),
      );
    } on DomainException catch (e) {
      final message = switch (e.code) {
        DomainErrorCode.notFound => 'Player not found',
        _ => 'Failed to delete player',
      };
      emit(
        state.copyWith(
          snackbarMessage: message,
          clearPlayerToDelete: true,
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

  void showDeleteConfirmation(int playerId) {
    emit(state.copyWith(playerToDeleteId: playerId));
  }

  void hideDeleteConfirmation() {
    emit(state.copyWith(clearPlayerToDelete: true));
  }

  void showEditPlayer(Player player) {
    emit(state.copyWith(playerToEdit: player));
  }

  void hideEditPlayer() {
    emit(state.copyWith(clearPlayerToEdit: true));
  }

  void clearSnackbar() {
    emit(state.copyWith(clearSnackbar: true));
  }

  @override
  Future<void> close() {
    unawaited(_playersSubscription?.cancel());
    return super.close();
  }
}
