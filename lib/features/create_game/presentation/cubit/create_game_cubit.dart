import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/create_game/data/create_game_repository.dart';
import 'package:pointolio/features/create_game/presentation/cubit/create_game_state.dart';

class CreateGameCubit extends Cubit<CreateGameState> {
  CreateGameCubit({
    required CreateGameRepository createGameRepository,
  }) : _createGameRepository = createGameRepository,
       super(CreateGameState.initial());
  final CreateGameRepository _createGameRepository;

  Future<void> loadData() async {
    emit(state.copyWith(status: CreateGameStatus.loading));

    try {
      final gameTypes = await _createGameRepository.getAllGameTypes();
      final players = await _createGameRepository.getAllPlayers();

      emit(
        state.copyWith(
          status: CreateGameStatus.initial,
          availableGameTypes: gameTypes,
          availablePlayers: players,
        ),
      );
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: CreateGameStatus.error,
          errorMessage: _mapDomainError(e, 'load data'),
        ),
      );
    } on Object catch (_) {
      emit(
        state.copyWith(
          status: CreateGameStatus.error,
          errorMessage: 'Failed to load data',
        ),
      );
    }
  }

  void clearSnackbar() {
    emit(state.copyWith());
  }

  void setGameName(String name) {
    emit(state.copyWith(gameName: name));
  }

  void setGameType(GameType? gameType) {
    emit(state.copyWith(selectedGameType: gameType));
  }

  void setGameDate(DateTime date) {
    emit(state.copyWith(gameDate: date));
  }

  void addPlayer(Player player) {
    if (state.selectedPlayers.any((p) => p.id == player.id)) return;
    emit(
      state.copyWith(
        selectedPlayers: [...state.selectedPlayers, player],
      ),
    );
  }

  void removePlayer(int id) {
    emit(
      state.copyWith(
        selectedPlayers: state.selectedPlayers
            .where((p) => p.id != id)
            .toList(),
      ),
    );
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    final players = List<Player>.from(state.selectedPlayers);

    var targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex--;
    }

    final player = players.removeAt(oldIndex);
    players.insert(targetIndex, player);

    emit(state.copyWith(selectedPlayers: players));
  }

  Future<void> addNewGameType(
    String name, {
    bool lowestScoreWins = false,
    int? color,
  }) async {
    if (name.trim().isEmpty) return;

    try {
      final id = await _createGameRepository.addGameType(
        name: name,
        lowestScoreWins: lowestScoreWins,
        color: color,
      );
      final newType = await _createGameRepository.getGameTypeById(id);

      if (newType != null) {
        final alreadyExists = state.availableGameTypes.any(
          (t) => t.id == newType.id,
        );

        emit(
          state.copyWith(
            availableGameTypes: alreadyExists
                ? state.availableGameTypes
                : [...state.availableGameTypes, newType],
            selectedGameType: newType,
          ),
        );
      }
    } on DomainException catch (e) {
      emit(
        state.copyWith(snackbarMessage: _mapDomainError(e, 'add game type')),
      );
    } on Object catch (_) {
      emit(state.copyWith(snackbarMessage: 'Failed to add game type'));
    }
  }

  Future<void> addNewPlayer(
    String firstName,
    String? lastName,
    int? color,
  ) async {
    if (firstName.trim().isEmpty) return;

    try {
      final id = await _createGameRepository.addPlayer(
        firstName: firstName,
        lastName: lastName,
        color: color,
      );
      final newPlayer = await _createGameRepository.getPlayerById(id);

      if (newPlayer != null) {
        final alreadyInAvailable = state.availablePlayers.any(
          (p) => p.id == newPlayer.id,
        );
        final alreadySelected = state.selectedPlayers.any(
          (p) => p.id == newPlayer.id,
        );

        emit(
          state.copyWith(
            availablePlayers: alreadyInAvailable
                ? state.availablePlayers
                : [...state.availablePlayers, newPlayer],
            selectedPlayers: alreadySelected
                ? state.selectedPlayers
                : [...state.selectedPlayers, newPlayer],
          ),
        );
      }
    } on DomainException catch (e) {
      emit(state.copyWith(snackbarMessage: _mapDomainError(e, 'add player')));
    } on Object catch (_) {
      emit(state.copyWith(snackbarMessage: 'Failed to add player'));
    }
  }

  Future<void> createGame() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: CreateGameStatus.loading));

    try {
      final gameId = await _createGameRepository.createGame(
        name: state.gameName,
        gameTypeId: state.selectedGameType!.id,
        gameTypeName: state.selectedGameType!.name,
        playerIds: state.selectedPlayers.map((p) => p.id).toList(),
        gameDate: state.gameDate,
      );

      emit(
        state.copyWith(
          status: CreateGameStatus.success,
          createdGameId: gameId,
        ),
      );
    } on DomainException catch (e) {
      emit(
        state.copyWith(
          status: CreateGameStatus.initial,
          snackbarMessage: _mapDomainError(e, 'create game'),
        ),
      );
    } on Object catch (_) {
      emit(
        state.copyWith(
          status: CreateGameStatus.initial,
          snackbarMessage: 'Failed to create game',
        ),
      );
    }
  }

  String _mapDomainError(DomainException e, String operation) {
    return switch (e.code) {
      DomainErrorCode.notFound => 'Resource not found',
      DomainErrorCode.conflict => 'Already exists',
      DomainErrorCode.validation => 'Invalid data',
      DomainErrorCode.storage => 'Failed to $operation',
      DomainErrorCode.unauthorized => 'Not authorized',
    };
  }
}
