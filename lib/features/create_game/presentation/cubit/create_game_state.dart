import 'package:equatable/equatable.dart';
import 'package:scoreio/common/data/database/database.dart';

enum CreateGameStatus { initial, loading, success, error }

class CreateGameState extends Equatable {
  final String gameName;
  final GameType? selectedGameType;
  final List<Player> selectedPlayers;
  final DateTime gameDate;
  final CreateGameStatus status;
  final String? errorMessage;
  final int? createdGameId;

  // Available options from DB
  final List<GameType> availableGameTypes;
  final List<Player> availablePlayers;

  const CreateGameState({
    this.gameName = '',
    this.selectedGameType,
    this.selectedPlayers = const [],
    required this.gameDate,
    this.status = CreateGameStatus.initial,
    this.errorMessage,
    this.createdGameId,
    this.availableGameTypes = const [],
    this.availablePlayers = const [],
  });

  factory CreateGameState.initial() {
    return CreateGameState(
      gameDate: DateTime.now(),
    );
  }

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
      errorMessage: errorMessage ?? this.errorMessage,
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
        createdGameId,
        availableGameTypes,
        availablePlayers,
      ];
}
