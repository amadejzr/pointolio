part of 'game_types_management_cubit.dart';

enum GameTypesManagementStatus { initial, loading, loaded, error }

class GameTypesManagementState extends Equatable {
  const GameTypesManagementState({
    this.gameTypes = const [],
    this.status = GameTypesManagementStatus.initial,
    this.searchQuery,
    this.errorMessage,
    this.gameTypeToDeleteId,
    this.gameTypeToEdit,
  });

  factory GameTypesManagementState.initial() {
    return const GameTypesManagementState();
  }

  final List<GameType> gameTypes;
  final GameTypesManagementStatus status;
  final String? searchQuery;
  final String? errorMessage;
  final int? gameTypeToDeleteId;
  final GameType? gameTypeToEdit;

  List<GameType> get filteredGameTypes {
    if (searchQuery == null || searchQuery!.trim().isEmpty) {
      return gameTypes;
    }
    final query = searchQuery!.toLowerCase();
    return gameTypes.where((gameType) {
      return gameType.name.toLowerCase().contains(query);
    }).toList();
  }

  GameTypesManagementState copyWith({
    List<GameType>? gameTypes,
    GameTypesManagementStatus? status,
    String? searchQuery,
    String? errorMessage,
    int? gameTypeToDeleteId,
    GameType? gameTypeToEdit,
    bool clearSearchQuery = false,
    bool clearGameTypeToDelete = false,
    bool clearGameTypeToEdit = false,
  }) {
    return GameTypesManagementState(
      gameTypes: gameTypes ?? this.gameTypes,
      status: status ?? this.status,
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      gameTypeToDeleteId: clearGameTypeToDelete
          ? null
          : gameTypeToDeleteId ?? this.gameTypeToDeleteId,
      gameTypeToEdit:
          clearGameTypeToEdit ? null : gameTypeToEdit ?? this.gameTypeToEdit,
    );
  }

  @override
  List<Object?> get props => [
        gameTypes,
        status,
        searchQuery,
        errorMessage,
        gameTypeToDeleteId,
        gameTypeToEdit,
      ];
}
