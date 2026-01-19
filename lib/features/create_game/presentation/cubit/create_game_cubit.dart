import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/data/repositories/game_type_repository.dart';
import 'package:scoreio/common/data/repositories/player_repository.dart';
import 'package:scoreio/features/create_game/presentation/cubit/create_game_state.dart';

class CreateGameCubit extends Cubit<CreateGameState> {
  final GameTypeRepository _gameTypeRepository;
  final PlayerRepository _playerRepository;
  final GameRepository _gameRepository;

  CreateGameCubit({
    required GameTypeRepository gameTypeRepository,
    required PlayerRepository playerRepository,
    required GameRepository gameRepository,
  })  : _gameTypeRepository = gameTypeRepository,
        _playerRepository = playerRepository,
        _gameRepository = gameRepository,
        super(CreateGameState.initial());

  Future<void> loadData() async {
    try {
      final gameTypes = await _gameTypeRepository.getAll();
      final players = await _playerRepository.getAll();

      emit(state.copyWith(
        availableGameTypes: gameTypes,
        availablePlayers: players,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreateGameStatus.error,
        errorMessage: 'Failed to load data: $e',
      ));
    }
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
    emit(state.copyWith(
      selectedPlayers: [...state.selectedPlayers, player],
    ));
  }

  void removePlayer(int id) {
    emit(state.copyWith(
      selectedPlayers: state.selectedPlayers.where((p) => p.id != id).toList(),
    ));
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    final players = List<Player>.from(state.selectedPlayers);
    if (newIndex > oldIndex) newIndex--;
    final player = players.removeAt(oldIndex);
    players.insert(newIndex, player);
    emit(state.copyWith(selectedPlayers: players));
  }

  Future<void> addNewGameType(
    String name, {
    bool lowestScoreWins = false,
    int? color,
  }) async {
    if (name.trim().isEmpty) return;

    try {
      final id = await _gameTypeRepository.add(
        name,
        lowestScoreWins: lowestScoreWins,
        color: color,
      );
      final newType = await _gameTypeRepository.getById(id);

      if (newType != null) {
        emit(state.copyWith(
          availableGameTypes: [...state.availableGameTypes, newType],
          selectedGameType: newType,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CreateGameStatus.error,
        errorMessage: 'Failed to add game type: $e',
      ));
    }
  }

  Future<void> addNewPlayer(String firstName, String? lastName) async {
    if (firstName.trim().isEmpty) return;

    try {
      final id = await _playerRepository.add(
        firstName: firstName,
        lastName: lastName,
      );
      final newPlayer = await _playerRepository.getById(id);

      if (newPlayer != null) {
        emit(state.copyWith(
          availablePlayers: [...state.availablePlayers, newPlayer],
          selectedPlayers: [...state.selectedPlayers, newPlayer],
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CreateGameStatus.error,
        errorMessage: 'Failed to add player: $e',
      ));
    }
  }

  Future<void> createGame() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: CreateGameStatus.loading));

    try {
      final gameId = await _gameRepository.create(
        name: state.gameName,
        gameTypeId: state.selectedGameType!.id,
        gameTypeName: state.selectedGameType!.name,
        playerIds: state.selectedPlayers.map((p) => p.id).toList(),
        gameDate: state.gameDate,
      );

      emit(state.copyWith(
        status: CreateGameStatus.success,
        createdGameId: gameId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreateGameStatus.error,
        errorMessage: 'Failed to create game: $e',
      ));
    }
  }
}
