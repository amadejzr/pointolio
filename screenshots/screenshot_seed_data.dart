// This file seeds test data for screenshots - print statements are intentional.
// ignore_for_file: avoid_print

import 'package:pointolio/common/data/database/database.dart';

/// Carefully chosen colors from your existing palette
const _playerColorByName = <String, int>{
  'Emma': 0xFF42A5F5, // Blue
  'James': 0xFFEF5350, // Red
  'Sofia': 0xFFAB47BC, // Purple
  'Lucas': 0xFF66BB6A, // Green
};

const _gameTypeColorByName = <String, int>{
  'Rummy': 0xFF26A69A, // Teal
  'Poker': 0xFFEC407A, // Pink
  'Spades': 0xFF5C6BC0, // Indigo
  'Hearts': 0xFFFF7043, // Deep Orange
};

/// Entry point used by screenshot_test.dart
Future<void> seedScreenshotData(AppDatabase db) async {
  print('🎲 Seeding screenshot data (deterministic)...');

  print('Creating players...');
  final players = await _createPlayers(db);

  print('Creating game types...');
  final gameTypes = await _createGameTypes(db);

  print('Creating games with scores...');
  await _createGames(db, players, gameTypes);

  print('✅ Screenshot data seeded successfully!');
}

// -----------------------------------------------------------------------------
// PLAYERS
// -----------------------------------------------------------------------------

Future<Map<String, int>> _createPlayers(AppDatabase db) async {
  final result = <String, int>{};

  for (final entry in _playerColorByName.entries) {
    final name = entry.key;
    final color = entry.value;

    final existing = await db.playerDao.getByName(name, null);
    if (existing != null) {
      result[name] = existing.id;
      print('  Player exists: $name');
    } else {
      final id = await db.playerDao.add(firstName: name, color: color);
      result[name] = id;
      print('  Created player: $name (id: $id)');
    }
  }

  return result;
}

// -----------------------------------------------------------------------------
// GAME TYPES
// -----------------------------------------------------------------------------

Future<Map<String, int>> _createGameTypes(AppDatabase db) async {
  final result = <String, int>{};

  const gameTypes = [
    ('Rummy', true),
    ('Poker', false),
    ('Spades', false),
    ('Hearts', true),
  ];

  for (final (name, lowestScoreWins) in gameTypes) {
    final existing = await db.gameTypeDao.getByName(name);
    if (existing != null) {
      result[name] = existing.id;
      print('  Game type exists: $name');
    } else {
      final id = await db.gameTypeDao.add(
        name: name,
        lowestScoreWins: lowestScoreWins,
        color: _gameTypeColorByName[name],
      );
      result[name] = id;
      print('  Created game type: $name (id: $id)');
    }
  }

  return result;
}

// -----------------------------------------------------------------------------
// GAMES
// -----------------------------------------------------------------------------

Future<void> _createGames(
  AppDatabase db,
  Map<String, int> players,
  Map<String, int> gameTypes,
) async {
  await _createRummyGame(db, players, gameTypes['Rummy']!);
  await _createPokerGame(db, players.values.toList(), gameTypes['Poker']!);
  await _createSpadesGame(db, players.values.toList(), gameTypes['Spades']!);
  await _createHeartsGame(db, players.values.toList(), gameTypes['Hearts']!);
}

// -----------------------------------------------------------------------------
// RUMMY (main screenshot game)
// -----------------------------------------------------------------------------

Future<void> _createRummyGame(
  AppDatabase db,
  Map<String, int> players,
  int gameTypeId,
) async {
  print('  Creating Rummy game (in progress)...');

  final gameId = await db.gameDao.createGame(
    name: 'Friday Night Rummy',
    gameTypeId: gameTypeId,
    gameTypeName: 'Rummy',
    playerIds: players.values.toList(),
    gameDate: DateTime.now().subtract(const Duration(hours: 2)),
    note: 'Weekly game night',
  );

  final gamePlayers = await db.gameDao.getGamePlayers(gameId);
  final gpByName = {
    for (final (player, gp) in gamePlayers) player.firstName: gp.id,
  };

  final rummyScores = [
    {'Emma': 45, 'James': 0, 'Sofia': 25, 'Lucas': 60},
    {'Emma': 70, 'James': 0, 'Sofia': 90, 'Lucas': 15},
    {'Emma': 55, 'James': 40, 'Sofia': 0, 'Lucas': 75},
    {'Emma': 30, 'James': 0, 'Sofia': 110, 'Lucas': 45},
    {'Emma': 0, 'James': 50, 'Sofia': 30, 'Lucas': 85},
    {'Emma': 40, 'James': 0, 'Sofia': 65, 'Lucas': 100},
    {'Emma': 80, 'James': 0, 'Sofia': 55, 'Lucas': 35},
  ];
  for (var i = 0; i < rummyScores.length; i++) {
    await db.scoringDao.addRound(
      roundNumber: i + 1,
      scores: {
        for (final e in rummyScores[i].entries) gpByName[e.key]!: e.value,
      },
    );
  }

  print('    Rummy game ready (7 rounds)');
}

// -----------------------------------------------------------------------------
// POKER (finished)
// -----------------------------------------------------------------------------

Future<void> _createPokerGame(
  AppDatabase db,
  List<int> playerIds,
  int gameTypeId,
) async {
  print('  Creating Poker game (completed)...');

  final gameId = await db.gameDao.createGame(
    name: 'Poker Tournament',
    gameTypeId: gameTypeId,
    gameTypeName: 'Poker',
    playerIds: playerIds,
    gameDate: DateTime.now().subtract(const Duration(days: 3)),
  );

  final gpIds = (await db.gameDao.getGamePlayers(
    gameId,
  )).map((e) => e.$2.id).toList();

  const pokerScores = [
    [150, 50, 100, 200],
    [75, 225, 50, 150],
    [200, 100, 175, 25],
    [50, 150, 250, 50],
    [125, 75, 125, 175],
  ];

  for (var r = 0; r < pokerScores.length; r++) {
    await db.scoringDao.addRound(
      roundNumber: r + 1,
      scores: {
        for (var i = 0; i < gpIds.length; i++) gpIds[i]: pokerScores[r][i],
      },
    );
  }

  await db.gameDao.setGameFinished(gameId, finished: true);
}

// -----------------------------------------------------------------------------
// SPADES (in progress)
// -----------------------------------------------------------------------------

Future<void> _createSpadesGame(
  AppDatabase db,
  List<int> playerIds,
  int gameTypeId,
) async {
  print('  Creating Spades game (in progress)...');

  final gameId = await db.gameDao.createGame(
    name: 'Spades Night',
    gameTypeId: gameTypeId,
    gameTypeName: 'Spades',
    playerIds: playerIds,
    gameDate: DateTime.now().subtract(const Duration(hours: 1)),
  );

  final gpIds = (await db.gameDao.getGamePlayers(
    gameId,
  )).map((e) => e.$2.id).toList();

  const scores = [
    [120, 80, 150, 90],
    [85, 130, 70, 115],
    [140, 95, 110, 55],
    [75, 160, 90, 125],
  ];

  for (var r = 0; r < scores.length; r++) {
    await db.scoringDao.addRound(
      roundNumber: r + 1,
      scores: {
        for (var i = 0; i < gpIds.length; i++) gpIds[i]: scores[r][i],
      },
    );
  }
}

// -----------------------------------------------------------------------------
// HEARTS (finished)
// -----------------------------------------------------------------------------

Future<void> _createHeartsGame(
  AppDatabase db,
  List<int> playerIds,
  int gameTypeId,
) async {
  print('  Creating Hearts game (completed)...');

  final gameId = await db.gameDao.createGame(
    name: 'Hearts Championship',
    gameTypeId: gameTypeId,
    gameTypeName: 'Hearts',
    playerIds: playerIds,
    gameDate: DateTime.now().subtract(const Duration(days: 5)),
  );

  final gpIds = (await db.gameDao.getGamePlayers(
    gameId,
  )).map((e) => e.$2.id).toList();

  const scores = [
    [13, 5, 8, 0],
    [0, 10, 3, 13],
    [7, 0, 15, 4],
    [4, 18, 0, 4],
    [10, 3, 7, 6],
    [2, 9, 11, 4],
  ];

  for (var r = 0; r < scores.length; r++) {
    await db.scoringDao.addRound(
      roundNumber: r + 1,
      scores: {
        for (var i = 0; i < gpIds.length; i++) gpIds[i]: scores[r][i],
      },
    );
  }

  await db.gameDao.setGameFinished(gameId, finished: true);
}
