part of 'players_management_cubit.dart';

enum PlayersManagementStatus { initial, loading, loaded, error }

class PlayersManagementState extends Equatable {
  const PlayersManagementState({
    this.players = const [],
    this.status = PlayersManagementStatus.initial,
    this.searchQuery,
    this.errorMessage,
    this.playerToDeleteId,
    this.playerToEdit,
  });

  factory PlayersManagementState.initial() => const PlayersManagementState();

  final List<Player> players;
  final PlayersManagementStatus status;
  final String? searchQuery;
  final String? errorMessage;
  final int? playerToDeleteId;
  final Player? playerToEdit;

  List<Player> get filteredPlayers {
    if (searchQuery == null || searchQuery!.trim().isEmpty) {
      return players;
    }
    final query = searchQuery!.toLowerCase();
    return players.where((player) {
      final firstName = player.firstName.toLowerCase();
      final lastName = player.lastName?.toLowerCase() ?? '';
      final fullName = '$firstName $lastName'.trim();
      return firstName.contains(query) ||
          lastName.contains(query) ||
          fullName.contains(query);
    }).toList();
  }

  PlayersManagementState copyWith({
    List<Player>? players,
    PlayersManagementStatus? status,
    String? searchQuery,
    String? errorMessage,
    int? playerToDeleteId,
    Player? playerToEdit,
    bool clearSearchQuery = false,
    bool clearPlayerToDelete = false,
    bool clearPlayerToEdit = false,
  }) {
    return PlayersManagementState(
      players: players ?? this.players,
      status: status ?? this.status,
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      playerToDeleteId: clearPlayerToDelete
          ? null
          : playerToDeleteId ?? this.playerToDeleteId,
      playerToEdit:
          clearPlayerToEdit ? null : playerToEdit ?? this.playerToEdit,
    );
  }

  @override
  List<Object?> get props => [
        players,
        status,
        searchQuery,
        errorMessage,
        playerToDeleteId,
        playerToEdit,
      ];
}
