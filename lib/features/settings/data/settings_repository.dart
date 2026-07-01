import 'package:drift/native.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/exception/exception_mapper.dart';

/// Data-layer operations for the Settings screen.
class SettingsRepository {
  const SettingsRepository(this._db);

  final AppDatabase _db;

  /// Wipes every user-created record - parties, games, players and scores -
  /// from the local database in a single transaction. Tables are cleared
  /// child-first so foreign-key constraints (cascade + restrict) hold.
  Future<void> clearAllData() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.scoreEntries).go();
        await _db.delete(_db.gamePlayers).go();
        await _db.delete(_db.games).go();
        await _db.delete(_db.players).go();
        await _db.delete(_db.gameTypes).go();
      });
    } on SqliteException catch (e) {
      throw e.toDomainException(operation: 'clearAllData');
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'clearAllData'},
        cause: e,
      );
    }
  }
}
