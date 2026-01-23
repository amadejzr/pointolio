import 'package:equatable/equatable.dart';
import 'package:pointolio/common/data/database/database.dart';

enum CreateGameStatus { initial, loading, success, error }

class CreateGameState extends Equatable {
  const CreateGameState({
    required this.gameDate,
    this.gameName = '',
    this.selectedGameType,
    this.selectedPlayers = const [],
    this.status = CreateGameStatus.initial,
    this.errorMessage,
    this.snackbarMessage,
    this.createdGameId,
    this.availableGameTypes = const [],
    this.availablePlayers = const [],
  });
  factory CreateGameState.initial() {
    return CreateGameState(
      gameDate: DateTime.now(),
    );
  }
  final String gameName;
  final GameType? selectedGameType;
  final List<Player> selectedPlayers;
  final DateTime gameDate;
  final CreateGameStatus status;
  final String? errorMessage; // blocking error (failed to load data)
  final String? snackbarMessage; // transient error (failed to add player, etc.)
  final int? createdGameId;

  // Available options from DB
  final List<GameType> availableGameTypes;
  final List<Player> availablePlayers;

  bool get isValid =>
      gameName.trim().isNotEmpty &&
      selectedGameType != null &&
      selectedPlayers.length >= 2;

  CreateGameState copyWith({
    String? gameName,
    GameType? selectedGameType,
    List<Player>? selectedPlayers,
    DateTime? gameDate,
    CreateGameStatus? status,
    String? errorMessage,
    String? snackbarMessage,
    int? createdGameId,
    List<GameType>? availableGameTypes,
    List<Player>? availablePlayers,
  }) {
    return CreateGameState(
      gameName: gameName ?? this.gameName,
      selectedGameType: selectedGameType ?? this.selectedGameType,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      gameDate: gameDate ?? this.gameDate,
      status: status ?? this.status,
      errorMessage: errorMessage,
      snackbarMessage: snackbarMessage,
      createdGameId: createdGameId ?? this.createdGameId,
      availableGameTypes: availableGameTypes ?? this.availableGameTypes,
      availablePlayers: availablePlayers ?? this.availablePlayers,
    );
  }

  @override
  List<Object?> get props => [
    gameName,
    selectedGameType,
    selectedPlayers,
    gameDate,
    status,
    errorMessage,
    snackbarMessage,
    createdGameId,
    availableGameTypes,
    availablePlayers,
  ];
}
