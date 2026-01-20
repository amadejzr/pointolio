import 'package:drift/drift.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/tables/player_table.dart';

part 'player_dao.g.dart';

@DriftAccessor(tables: [Players])
class PlayerDao extends DatabaseAccessor<AppDatabase> with _$PlayerDaoMixin {
  PlayerDao(super.attachedDatabase);

  Future<List<Player>> getAll({bool includeArchived = false}) {
    final query = select(players);
    if (!includeArchived) {
      query.where((p) => p.isArchived.equals(false));
    }
    query.orderBy([(p) => OrderingTerm.asc(p.firstName)]);
    return query.get();
  }

  Future<Player?> getById(int id) {
    return (select(players)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<Player?> getByName(String firstName, String? lastName) {
    final query = select(players)
      ..where((p) => p.firstName.equals(firstName.trim()));

    if (lastName != null && lastName.trim().isNotEmpty) {
      query.where((p) => p.lastName.equals(lastName.trim()));
    } else {
      query.where((p) => p.lastName.isNull());
    }

    return query.getSingleOrNull();
  }

  Future<int> add({
    required String firstName,
    String? lastName,
  }) {
    final l = lastName?.trim();
    return into(players).insert(
      PlayersCompanion.insert(
        firstName: firstName.trim(),
        lastName: Value(l?.isEmpty ?? false ? null : l),
      ),
    );
  }
}
