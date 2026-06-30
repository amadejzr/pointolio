import 'package:pointolio/common/data/database/database.dart';

/// Builds a [Player] row object in memory (no database involved).
///
/// Handy for cubit tests that mock the repository and just need plausible
/// domain objects to pass around.
Player playerRow({
  required int id,
  String firstName = 'Player',
  String? lastName,
  int? color,
  bool isArchived = false,
  DateTime? createdAt,
}) {
  return Player(
    id: id,
    firstName: firstName,
    lastName: lastName,
    color: color,
    isArchived: isArchived,
    createdAt: createdAt ?? DateTime(2025),
  );
}

/// Builds a [Game] row object in memory (no database involved).
Game gameRow({
  required int id,
  String name = 'Game',
  int? gameTypeId,
  String? gameTypeNameSnapshot,
  String? note,
  DateTime? gameDate,
  DateTime? createdAt,
  DateTime? finishedAt,
}) {
  return Game(
    id: id,
    name: name,
    gameTypeId: gameTypeId,
    gameTypeNameSnapshot: gameTypeNameSnapshot,
    note: note,
    gameDate: gameDate ?? DateTime(2025),
    createdAt: createdAt ?? DateTime(2025),
    finishedAt: finishedAt,
  );
}

/// Builds a [GamePlayer] join-row object in memory (no database involved).
GamePlayer gamePlayerRow({
  required int id,
  int gameId = 1,
  int playerId = 1,
  int orderIndex = 0,
  DateTime? createdAt,
}) {
  return GamePlayer(
    id: id,
    gameId: gameId,
    playerId: playerId,
    orderIndex: orderIndex,
    createdAt: createdAt ?? DateTime(2025),
  );
}

/// Builds a [GameType] row object in memory (no database involved).
GameType gameTypeRow({
  required int id,
  String name = 'Poker',
  bool lowestScoreWins = false,
  int? color,
  DateTime? createdAt,
}) {
  return GameType(
    id: id,
    name: name,
    lowestScoreWins: lowestScoreWins,
    color: color,
    createdAt: createdAt ?? DateTime(2025),
  );
}

/// Test data builders for seeding an [AppDatabase] with minimal ceremony.
///
/// These keep the individual tests focused on the behaviour under test instead
/// of repeating the same "insert a game type, two players and a game" dance.
/// Prefer the high-level [seedGame] when a test needs a fully wired game; reach
/// for the small [TestSeed] helpers when it only needs a row or two.
extension TestSeed on AppDatabase {
  /// Inserts a game type and returns its id.
  Future<int> seedGameType({
    String name = 'Poker',
    bool lowestScoreWins = false,
    int? color,
  }) {
    return gameTypeDao.add(
      name: name,
      lowestScoreWins: lowestScoreWins,
      color: color,
    );
  }

  /// Inserts a player and returns its id.
  Future<int> seedPlayer({
    required String firstName,
    String? lastName,
    int? color,
  }) {
    return playerDao.add(
      firstName: firstName,
      lastName: lastName,
      color: color,
    );
  }
}

/// A fully wired game: the game row, its game type, the underlying `Players`
/// ids and the `GamePlayers` join-row ids (ordered by `orderIndex`).
///
/// Scoring works against `gamePlayerIds` (score entries reference the join
/// row), so those are exposed separately from the raw `playerIds`.
class SeededGame {
  const SeededGame({
    required this.gameId,
    required this.gameTypeId,
    required this.playerIds,
    required this.gamePlayerIds,
  });

  final int gameId;
  final int gameTypeId;
  final List<int> playerIds;
  final List<int> gamePlayerIds;
}

/// Seeds a complete game (game type + players + game + join rows) and returns
/// the ids needed to drive scoring assertions.
///
/// Player names default to distinct values so the `{firstName, lastName}`
/// unique key is never hit; pass [playerNames] to control the roster size.
Future<SeededGame> seedGame(
  AppDatabase db, {
  String name = 'Game',
  String gameTypeName = 'Poker',
  bool lowestScoreWins = false,
  List<String> playerNames = const ['Amy', 'Bob'],
  DateTime? gameDate,
}) async {
  final gameTypeId = await db.seedGameType(
    name: gameTypeName,
    lowestScoreWins: lowestScoreWins,
  );

  final playerIds = <int>[];
  for (final firstName in playerNames) {
    playerIds.add(await db.seedPlayer(firstName: firstName));
  }

  final gameId = await db.gameDao.createGame(
    name: name,
    gameTypeId: gameTypeId,
    gameTypeName: gameTypeName,
    playerIds: playerIds,
    gameDate: gameDate ?? DateTime(2025),
  );

  final gamePlayers = await db.gameDao.getGamePlayers(gameId);

  return SeededGame(
    gameId: gameId,
    gameTypeId: gameTypeId,
    playerIds: playerIds,
    gamePlayerIds: gamePlayers.map((t) => t.$2.id).toList(),
  );
}
