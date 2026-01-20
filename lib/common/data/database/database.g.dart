// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GameTypesTable extends GameTypes
    with TableInfo<$GameTypesTable, GameType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lowestScoreWinsMeta = const VerificationMeta(
    'lowestScoreWins',
  );
  @override
  late final GeneratedColumn<bool> lowestScoreWins = GeneratedColumn<bool>(
    'lowest_score_wins',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lowest_score_wins" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    lowestScoreWins,
    color,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('lowest_score_wins')) {
      context.handle(
        _lowestScoreWinsMeta,
        lowestScoreWins.isAcceptableOrUnknown(
          data['lowest_score_wins']!,
          _lowestScoreWinsMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  GameType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lowestScoreWins: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lowest_score_wins'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GameTypesTable createAlias(String alias) {
    return $GameTypesTable(attachedDatabase, alias);
  }
}

class GameType extends DataClass implements Insertable<GameType> {
  final int id;
  final String name;
  final bool lowestScoreWins;
  final int? color;
  final DateTime createdAt;
  const GameType({
    required this.id,
    required this.name,
    required this.lowestScoreWins,
    this.color,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['lowest_score_wins'] = Variable<bool>(lowestScoreWins);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GameTypesCompanion toCompanion(bool nullToAbsent) {
    return GameTypesCompanion(
      id: Value(id),
      name: Value(name),
      lowestScoreWins: Value(lowestScoreWins),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory GameType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lowestScoreWins: serializer.fromJson<bool>(json['lowestScoreWins']),
      color: serializer.fromJson<int?>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lowestScoreWins': serializer.toJson<bool>(lowestScoreWins),
      'color': serializer.toJson<int?>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GameType copyWith({
    int? id,
    String? name,
    bool? lowestScoreWins,
    Value<int?> color = const Value.absent(),
    DateTime? createdAt,
  }) => GameType(
    id: id ?? this.id,
    name: name ?? this.name,
    lowestScoreWins: lowestScoreWins ?? this.lowestScoreWins,
    color: color.present ? color.value : this.color,
    createdAt: createdAt ?? this.createdAt,
  );
  GameType copyWithCompanion(GameTypesCompanion data) {
    return GameType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lowestScoreWins: data.lowestScoreWins.present
          ? data.lowestScoreWins.value
          : this.lowestScoreWins,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lowestScoreWins: $lowestScoreWins, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lowestScoreWins, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameType &&
          other.id == this.id &&
          other.name == this.name &&
          other.lowestScoreWins == this.lowestScoreWins &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class GameTypesCompanion extends UpdateCompanion<GameType> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> lowestScoreWins;
  final Value<int?> color;
  final Value<DateTime> createdAt;
  const GameTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lowestScoreWins = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GameTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.lowestScoreWins = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<GameType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? lowestScoreWins,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lowestScoreWins != null) 'lowest_score_wins': lowestScoreWins,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GameTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? lowestScoreWins,
    Value<int?>? color,
    Value<DateTime>? createdAt,
  }) {
    return GameTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lowestScoreWins: lowestScoreWins ?? this.lowestScoreWins,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lowestScoreWins.present) {
      map['lowest_score_wins'] = Variable<bool>(lowestScoreWins.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lowestScoreWins: $lowestScoreWins, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _gameDateMeta = const VerificationMeta(
    'gameDate',
  );
  @override
  late final GeneratedColumn<DateTime> gameDate = GeneratedColumn<DateTime>(
    'game_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _gameTypeIdMeta = const VerificationMeta(
    'gameTypeId',
  );
  @override
  late final GeneratedColumn<int> gameTypeId = GeneratedColumn<int>(
    'game_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_types (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _gameTypeNameSnapshotMeta =
      const VerificationMeta('gameTypeNameSnapshot');
  @override
  late final GeneratedColumn<String> gameTypeNameSnapshot =
      GeneratedColumn<String>(
        'game_type_name_snapshot',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 60,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    gameDate,
    gameTypeId,
    gameTypeNameSnapshot,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('game_date')) {
      context.handle(
        _gameDateMeta,
        gameDate.isAcceptableOrUnknown(data['game_date']!, _gameDateMeta),
      );
    }
    if (data.containsKey('game_type_id')) {
      context.handle(
        _gameTypeIdMeta,
        gameTypeId.isAcceptableOrUnknown(
          data['game_type_id']!,
          _gameTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('game_type_name_snapshot')) {
      context.handle(
        _gameTypeNameSnapshotMeta,
        gameTypeNameSnapshot.isAcceptableOrUnknown(
          data['game_type_name_snapshot']!,
          _gameTypeNameSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      gameDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}game_date'],
      )!,
      gameTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_type_id'],
      ),
      gameTypeNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_type_name_snapshot'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime gameDate;
  final int? gameTypeId;
  final String? gameTypeNameSnapshot;
  final String? note;
  const Game({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.gameDate,
    this.gameTypeId,
    this.gameTypeNameSnapshot,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['game_date'] = Variable<DateTime>(gameDate);
    if (!nullToAbsent || gameTypeId != null) {
      map['game_type_id'] = Variable<int>(gameTypeId);
    }
    if (!nullToAbsent || gameTypeNameSnapshot != null) {
      map['game_type_name_snapshot'] = Variable<String>(gameTypeNameSnapshot);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      gameDate: Value(gameDate),
      gameTypeId: gameTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(gameTypeId),
      gameTypeNameSnapshot: gameTypeNameSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(gameTypeNameSnapshot),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      gameDate: serializer.fromJson<DateTime>(json['gameDate']),
      gameTypeId: serializer.fromJson<int?>(json['gameTypeId']),
      gameTypeNameSnapshot: serializer.fromJson<String?>(
        json['gameTypeNameSnapshot'],
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'gameDate': serializer.toJson<DateTime>(gameDate),
      'gameTypeId': serializer.toJson<int?>(gameTypeId),
      'gameTypeNameSnapshot': serializer.toJson<String?>(gameTypeNameSnapshot),
      'note': serializer.toJson<String?>(note),
    };
  }

  Game copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? gameDate,
    Value<int?> gameTypeId = const Value.absent(),
    Value<String?> gameTypeNameSnapshot = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Game(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    gameDate: gameDate ?? this.gameDate,
    gameTypeId: gameTypeId.present ? gameTypeId.value : this.gameTypeId,
    gameTypeNameSnapshot: gameTypeNameSnapshot.present
        ? gameTypeNameSnapshot.value
        : this.gameTypeNameSnapshot,
    note: note.present ? note.value : this.note,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      gameDate: data.gameDate.present ? data.gameDate.value : this.gameDate,
      gameTypeId: data.gameTypeId.present
          ? data.gameTypeId.value
          : this.gameTypeId,
      gameTypeNameSnapshot: data.gameTypeNameSnapshot.present
          ? data.gameTypeNameSnapshot.value
          : this.gameTypeNameSnapshot,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('gameDate: $gameDate, ')
          ..write('gameTypeId: $gameTypeId, ')
          ..write('gameTypeNameSnapshot: $gameTypeNameSnapshot, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    gameDate,
    gameTypeId,
    gameTypeNameSnapshot,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.gameDate == this.gameDate &&
          other.gameTypeId == this.gameTypeId &&
          other.gameTypeNameSnapshot == this.gameTypeNameSnapshot &&
          other.note == this.note);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> gameDate;
  final Value<int?> gameTypeId;
  final Value<String?> gameTypeNameSnapshot;
  final Value<String?> note;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.gameDate = const Value.absent(),
    this.gameTypeId = const Value.absent(),
    this.gameTypeNameSnapshot = const Value.absent(),
    this.note = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
    this.gameDate = const Value.absent(),
    this.gameTypeId = const Value.absent(),
    this.gameTypeNameSnapshot = const Value.absent(),
    this.note = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Game> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? gameDate,
    Expression<int>? gameTypeId,
    Expression<String>? gameTypeNameSnapshot,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (gameDate != null) 'game_date': gameDate,
      if (gameTypeId != null) 'game_type_id': gameTypeId,
      if (gameTypeNameSnapshot != null)
        'game_type_name_snapshot': gameTypeNameSnapshot,
      if (note != null) 'note': note,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? gameDate,
    Value<int?>? gameTypeId,
    Value<String?>? gameTypeNameSnapshot,
    Value<String?>? note,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      gameDate: gameDate ?? this.gameDate,
      gameTypeId: gameTypeId ?? this.gameTypeId,
      gameTypeNameSnapshot: gameTypeNameSnapshot ?? this.gameTypeNameSnapshot,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (gameDate.present) {
      map['game_date'] = Variable<DateTime>(gameDate.value);
    }
    if (gameTypeId.present) {
      map['game_type_id'] = Variable<int>(gameTypeId.value);
    }
    if (gameTypeNameSnapshot.present) {
      map['game_type_name_snapshot'] = Variable<String>(
        gameTypeNameSnapshot.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('gameDate: $gameDate, ')
          ..write('gameTypeId: $gameTypeId, ')
          ..write('gameTypeNameSnapshot: $gameTypeNameSnapshot, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstName,
    lastName,
    createdAt,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {firstName, lastName},
  ];
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final int id;
  final String firstName;
  final String? lastName;
  final DateTime createdAt;
  final bool isArchived;
  const Player({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.createdAt,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      createdAt: Value(createdAt),
      isArchived: Value(isArchived),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<int>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Player copyWith({
    int? id,
    String? firstName,
    Value<String?> lastName = const Value.absent(),
    DateTime? createdAt,
    bool? isArchived,
  }) => Player(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    createdAt: createdAt ?? this.createdAt,
    isArchived: isArchived ?? this.isArchived,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, firstName, lastName, createdAt, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.createdAt == this.createdAt &&
          other.isArchived == this.isArchived);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<int> id;
  final Value<String> firstName;
  final Value<String?> lastName;
  final Value<DateTime> createdAt;
  final Value<bool> isArchived;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    this.lastName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : firstName = Value(firstName);
  static Insertable<Player> custom({
    Expression<int>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<DateTime>? createdAt,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (createdAt != null) 'created_at': createdAt,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  PlayersCompanion copyWith({
    Value<int>? id,
    Value<String>? firstName,
    Value<String?>? lastName,
    Value<DateTime>? createdAt,
    Value<bool>? isArchived,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $GamePlayersTable extends GamePlayers
    with TableInfo<$GamePlayersTable, GamePlayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamePlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    playerId,
    orderIndex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<GamePlayer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {gameId, playerId},
  ];
  @override
  GamePlayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GamePlayer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GamePlayersTable createAlias(String alias) {
    return $GamePlayersTable(attachedDatabase, alias);
  }
}

class GamePlayer extends DataClass implements Insertable<GamePlayer> {
  final int id;
  final int gameId;
  final int playerId;
  final int orderIndex;
  final DateTime createdAt;
  const GamePlayer({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.orderIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['player_id'] = Variable<int>(playerId);
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GamePlayersCompanion toCompanion(bool nullToAbsent) {
    return GamePlayersCompanion(
      id: Value(id),
      gameId: Value(gameId),
      playerId: Value(playerId),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
    );
  }

  factory GamePlayer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GamePlayer(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      playerId: serializer.fromJson<int>(json['playerId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'playerId': serializer.toJson<int>(playerId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GamePlayer copyWith({
    int? id,
    int? gameId,
    int? playerId,
    int? orderIndex,
    DateTime? createdAt,
  }) => GamePlayer(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    playerId: playerId ?? this.playerId,
    orderIndex: orderIndex ?? this.orderIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  GamePlayer copyWithCompanion(GamePlayersCompanion data) {
    return GamePlayer(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GamePlayer(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameId, playerId, orderIndex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GamePlayer &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.playerId == this.playerId &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt);
}

class GamePlayersCompanion extends UpdateCompanion<GamePlayer> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<int> playerId;
  final Value<int> orderIndex;
  final Value<DateTime> createdAt;
  const GamePlayersCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GamePlayersCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required int playerId,
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : gameId = Value(gameId),
       playerId = Value(playerId);
  static Insertable<GamePlayer> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<int>? playerId,
    Expression<int>? orderIndex,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (playerId != null) 'player_id': playerId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GamePlayersCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<int>? playerId,
    Value<int>? orderIndex,
    Value<DateTime>? createdAt,
  }) {
    return GamePlayersCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamePlayersCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ScoreEntriesTable extends ScoreEntries
    with TableInfo<$ScoreEntriesTable, ScoreEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoreEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gamePlayerIdMeta = const VerificationMeta(
    'gamePlayerId',
  );
  @override
  late final GeneratedColumn<int> gamePlayerId = GeneratedColumn<int>(
    'game_player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_players (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roundNumberMeta = const VerificationMeta(
    'roundNumber',
  );
  @override
  late final GeneratedColumn<int> roundNumber = GeneratedColumn<int>(
    'round_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gamePlayerId,
    roundNumber,
    points,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'score_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScoreEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_player_id')) {
      context.handle(
        _gamePlayerIdMeta,
        gamePlayerId.isAcceptableOrUnknown(
          data['game_player_id']!,
          _gamePlayerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gamePlayerIdMeta);
    }
    if (data.containsKey('round_number')) {
      context.handle(
        _roundNumberMeta,
        roundNumber.isAcceptableOrUnknown(
          data['round_number']!,
          _roundNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roundNumberMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {gamePlayerId, roundNumber},
  ];
  @override
  ScoreEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoreEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gamePlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_player_id'],
      )!,
      roundNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_number'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ScoreEntriesTable createAlias(String alias) {
    return $ScoreEntriesTable(attachedDatabase, alias);
  }
}

class ScoreEntry extends DataClass implements Insertable<ScoreEntry> {
  final int id;
  final int gamePlayerId;
  final int roundNumber;
  final int points;
  final DateTime createdAt;
  const ScoreEntry({
    required this.id,
    required this.gamePlayerId,
    required this.roundNumber,
    required this.points,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_player_id'] = Variable<int>(gamePlayerId);
    map['round_number'] = Variable<int>(roundNumber);
    map['points'] = Variable<int>(points);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScoreEntriesCompanion toCompanion(bool nullToAbsent) {
    return ScoreEntriesCompanion(
      id: Value(id),
      gamePlayerId: Value(gamePlayerId),
      roundNumber: Value(roundNumber),
      points: Value(points),
      createdAt: Value(createdAt),
    );
  }

  factory ScoreEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoreEntry(
      id: serializer.fromJson<int>(json['id']),
      gamePlayerId: serializer.fromJson<int>(json['gamePlayerId']),
      roundNumber: serializer.fromJson<int>(json['roundNumber']),
      points: serializer.fromJson<int>(json['points']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gamePlayerId': serializer.toJson<int>(gamePlayerId),
      'roundNumber': serializer.toJson<int>(roundNumber),
      'points': serializer.toJson<int>(points),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScoreEntry copyWith({
    int? id,
    int? gamePlayerId,
    int? roundNumber,
    int? points,
    DateTime? createdAt,
  }) => ScoreEntry(
    id: id ?? this.id,
    gamePlayerId: gamePlayerId ?? this.gamePlayerId,
    roundNumber: roundNumber ?? this.roundNumber,
    points: points ?? this.points,
    createdAt: createdAt ?? this.createdAt,
  );
  ScoreEntry copyWithCompanion(ScoreEntriesCompanion data) {
    return ScoreEntry(
      id: data.id.present ? data.id.value : this.id,
      gamePlayerId: data.gamePlayerId.present
          ? data.gamePlayerId.value
          : this.gamePlayerId,
      roundNumber: data.roundNumber.present
          ? data.roundNumber.value
          : this.roundNumber,
      points: data.points.present ? data.points.value : this.points,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoreEntry(')
          ..write('id: $id, ')
          ..write('gamePlayerId: $gamePlayerId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('points: $points, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gamePlayerId, roundNumber, points, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreEntry &&
          other.id == this.id &&
          other.gamePlayerId == this.gamePlayerId &&
          other.roundNumber == this.roundNumber &&
          other.points == this.points &&
          other.createdAt == this.createdAt);
}

class ScoreEntriesCompanion extends UpdateCompanion<ScoreEntry> {
  final Value<int> id;
  final Value<int> gamePlayerId;
  final Value<int> roundNumber;
  final Value<int> points;
  final Value<DateTime> createdAt;
  const ScoreEntriesCompanion({
    this.id = const Value.absent(),
    this.gamePlayerId = const Value.absent(),
    this.roundNumber = const Value.absent(),
    this.points = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScoreEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int gamePlayerId,
    required int roundNumber,
    required int points,
    this.createdAt = const Value.absent(),
  }) : gamePlayerId = Value(gamePlayerId),
       roundNumber = Value(roundNumber),
       points = Value(points);
  static Insertable<ScoreEntry> custom({
    Expression<int>? id,
    Expression<int>? gamePlayerId,
    Expression<int>? roundNumber,
    Expression<int>? points,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gamePlayerId != null) 'game_player_id': gamePlayerId,
      if (roundNumber != null) 'round_number': roundNumber,
      if (points != null) 'points': points,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScoreEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? gamePlayerId,
    Value<int>? roundNumber,
    Value<int>? points,
    Value<DateTime>? createdAt,
  }) {
    return ScoreEntriesCompanion(
      id: id ?? this.id,
      gamePlayerId: gamePlayerId ?? this.gamePlayerId,
      roundNumber: roundNumber ?? this.roundNumber,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gamePlayerId.present) {
      map['game_player_id'] = Variable<int>(gamePlayerId.value);
    }
    if (roundNumber.present) {
      map['round_number'] = Variable<int>(roundNumber.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoreEntriesCompanion(')
          ..write('id: $id, ')
          ..write('gamePlayerId: $gamePlayerId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('points: $points, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GameTypesTable gameTypes = $GameTypesTable(this);
  late final $GamesTable games = $GamesTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $GamePlayersTable gamePlayers = $GamePlayersTable(this);
  late final $ScoreEntriesTable scoreEntries = $ScoreEntriesTable(this);
  late final GameDao gameDao = GameDao(this as AppDatabase);
  late final GameTypeDao gameTypeDao = GameTypeDao(this as AppDatabase);
  late final PlayerDao playerDao = PlayerDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gameTypes,
    games,
    players,
    gamePlayers,
    scoreEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'game_types',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('games', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_players', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'game_players',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('score_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GameTypesTableCreateCompanionBuilder =
    GameTypesCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> lowestScoreWins,
      Value<int?> color,
      Value<DateTime> createdAt,
    });
typedef $$GameTypesTableUpdateCompanionBuilder =
    GameTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> lowestScoreWins,
      Value<int?> color,
      Value<DateTime> createdAt,
    });

final class $$GameTypesTableReferences
    extends BaseReferences<_$AppDatabase, $GameTypesTable, GameType> {
  $$GameTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GamesTable, List<Game>> _gamesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.games,
    aliasName: $_aliasNameGenerator(db.gameTypes.id, db.games.gameTypeId),
  );

  $$GamesTableProcessedTableManager get gamesRefs {
    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.gameTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GameTypesTableFilterComposer
    extends Composer<_$AppDatabase, $GameTypesTable> {
  $$GameTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lowestScoreWins => $composableBuilder(
    column: $table.lowestScoreWins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gamesRefs(
    Expression<bool> Function($$GamesTableFilterComposer f) f,
  ) {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.gameTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameTypesTable> {
  $$GameTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lowestScoreWins => $composableBuilder(
    column: $table.lowestScoreWins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameTypesTable> {
  $$GameTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get lowestScoreWins => $composableBuilder(
    column: $table.lowestScoreWins,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> gamesRefs<T extends Object>(
    Expression<T> Function($$GamesTableAnnotationComposer a) f,
  ) {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.gameTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameTypesTable,
          GameType,
          $$GameTypesTableFilterComposer,
          $$GameTypesTableOrderingComposer,
          $$GameTypesTableAnnotationComposer,
          $$GameTypesTableCreateCompanionBuilder,
          $$GameTypesTableUpdateCompanionBuilder,
          (GameType, $$GameTypesTableReferences),
          GameType,
          PrefetchHooks Function({bool gamesRefs})
        > {
  $$GameTypesTableTableManager(_$AppDatabase db, $GameTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> lowestScoreWins = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GameTypesCompanion(
                id: id,
                name: name,
                lowestScoreWins: lowestScoreWins,
                color: color,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> lowestScoreWins = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GameTypesCompanion.insert(
                id: id,
                name: name,
                lowestScoreWins: lowestScoreWins,
                color: color,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gamesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gamesRefs) db.games],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gamesRefs)
                    await $_getPrefetchedData<GameType, $GameTypesTable, Game>(
                      currentTable: table,
                      referencedTable: $$GameTypesTableReferences
                          ._gamesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GameTypesTableReferences(db, table, p0).gamesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.gameTypeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GameTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameTypesTable,
      GameType,
      $$GameTypesTableFilterComposer,
      $$GameTypesTableOrderingComposer,
      $$GameTypesTableAnnotationComposer,
      $$GameTypesTableCreateCompanionBuilder,
      $$GameTypesTableUpdateCompanionBuilder,
      (GameType, $$GameTypesTableReferences),
      GameType,
      PrefetchHooks Function({bool gamesRefs})
    >;
typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
      Value<DateTime> gameDate,
      Value<int?> gameTypeId,
      Value<String?> gameTypeNameSnapshot,
      Value<String?> note,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> gameDate,
      Value<int?> gameTypeId,
      Value<String?> gameTypeNameSnapshot,
      Value<String?> note,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GameTypesTable _gameTypeIdTable(_$AppDatabase db) => db.gameTypes
      .createAlias($_aliasNameGenerator(db.games.gameTypeId, db.gameTypes.id));

  $$GameTypesTableProcessedTableManager? get gameTypeId {
    final $_column = $_itemColumn<int>('game_type_id');
    if ($_column == null) return null;
    final manager = $$GameTypesTableTableManager(
      $_db,
      $_db.gameTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GamePlayersTable, List<GamePlayer>>
  _gamePlayersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gamePlayers,
    aliasName: $_aliasNameGenerator(db.games.id, db.gamePlayers.gameId),
  );

  $$GamePlayersTableProcessedTableManager get gamePlayersRefs {
    final manager = $$GamePlayersTableTableManager(
      $_db,
      $_db.gamePlayers,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamePlayersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get gameDate => $composableBuilder(
    column: $table.gameDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameTypeNameSnapshot => $composableBuilder(
    column: $table.gameTypeNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$GameTypesTableFilterComposer get gameTypeId {
    final $$GameTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameTypeId,
      referencedTable: $db.gameTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTypesTableFilterComposer(
            $db: $db,
            $table: $db.gameTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gamePlayersRefs(
    Expression<bool> Function($$GamePlayersTableFilterComposer f) f,
  ) {
    final $$GamePlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamePlayersTableFilterComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get gameDate => $composableBuilder(
    column: $table.gameDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameTypeNameSnapshot => $composableBuilder(
    column: $table.gameTypeNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameTypesTableOrderingComposer get gameTypeId {
    final $$GameTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameTypeId,
      referencedTable: $db.gameTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTypesTableOrderingComposer(
            $db: $db,
            $table: $db.gameTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get gameDate =>
      $composableBuilder(column: $table.gameDate, builder: (column) => column);

  GeneratedColumn<String> get gameTypeNameSnapshot => $composableBuilder(
    column: $table.gameTypeNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$GameTypesTableAnnotationComposer get gameTypeId {
    final $$GameTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameTypeId,
      referencedTable: $db.gameTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.gameTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gamePlayersRefs<T extends Object>(
    Expression<T> Function($$GamePlayersTableAnnotationComposer a) f,
  ) {
    final $$GamePlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamePlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({bool gameTypeId, bool gamePlayersRefs})
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> gameDate = const Value.absent(),
                Value<int?> gameTypeId = const Value.absent(),
                Value<String?> gameTypeNameSnapshot = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                gameDate: gameDate,
                gameTypeId: gameTypeId,
                gameTypeNameSnapshot: gameTypeNameSnapshot,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> gameDate = const Value.absent(),
                Value<int?> gameTypeId = const Value.absent(),
                Value<String?> gameTypeNameSnapshot = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                gameDate: gameDate,
                gameTypeId: gameTypeId,
                gameTypeNameSnapshot: gameTypeNameSnapshot,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({gameTypeId = false, gamePlayersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gamePlayersRefs) db.gamePlayers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gameTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameTypeId,
                                    referencedTable: $$GamesTableReferences
                                        ._gameTypeIdTable(db),
                                    referencedColumn: $$GamesTableReferences
                                        ._gameTypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gamePlayersRefs)
                        await $_getPrefetchedData<
                          Game,
                          $GamesTable,
                          GamePlayer
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._gamePlayersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).gamePlayersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({bool gameTypeId, bool gamePlayersRefs})
    >;
typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      required String firstName,
      Value<String?> lastName,
      Value<DateTime> createdAt,
      Value<bool> isArchived,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      Value<String> firstName,
      Value<String?> lastName,
      Value<DateTime> createdAt,
      Value<bool> isArchived,
    });

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, Player> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GamePlayersTable, List<GamePlayer>>
  _gamePlayersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gamePlayers,
    aliasName: $_aliasNameGenerator(db.players.id, db.gamePlayers.playerId),
  );

  $$GamePlayersTableProcessedTableManager get gamePlayersRefs {
    final manager = $$GamePlayersTableTableManager(
      $_db,
      $_db.gamePlayers,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamePlayersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gamePlayersRefs(
    Expression<bool> Function($$GamePlayersTableFilterComposer f) f,
  ) {
    final $$GamePlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamePlayersTableFilterComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> gamePlayersRefs<T extends Object>(
    Expression<T> Function($$GamePlayersTableAnnotationComposer a) f,
  ) {
    final $$GamePlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamePlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, $$PlayersTableReferences),
          Player,
          PrefetchHooks Function({bool gamePlayersRefs})
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                firstName: firstName,
                lastName: lastName,
                createdAt: createdAt,
                isArchived: isArchived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String firstName,
                Value<String?> lastName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                firstName: firstName,
                lastName: lastName,
                createdAt: createdAt,
                isArchived: isArchived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gamePlayersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gamePlayersRefs) db.gamePlayers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gamePlayersRefs)
                    await $_getPrefetchedData<
                      Player,
                      $PlayersTable,
                      GamePlayer
                    >(
                      currentTable: table,
                      referencedTable: $$PlayersTableReferences
                          ._gamePlayersRefsTable(db),
                      managerFromTypedResult: (p0) => $$PlayersTableReferences(
                        db,
                        table,
                        p0,
                      ).gamePlayersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, $$PlayersTableReferences),
      Player,
      PrefetchHooks Function({bool gamePlayersRefs})
    >;
typedef $$GamePlayersTableCreateCompanionBuilder =
    GamePlayersCompanion Function({
      Value<int> id,
      required int gameId,
      required int playerId,
      Value<int> orderIndex,
      Value<DateTime> createdAt,
    });
typedef $$GamePlayersTableUpdateCompanionBuilder =
    GamePlayersCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<int> playerId,
      Value<int> orderIndex,
      Value<DateTime> createdAt,
    });

final class $$GamePlayersTableReferences
    extends BaseReferences<_$AppDatabase, $GamePlayersTable, GamePlayer> {
  $$GamePlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.gamePlayers.gameId, db.games.id),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias(
        $_aliasNameGenerator(db.gamePlayers.playerId, db.players.id),
      );

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScoreEntriesTable, List<ScoreEntry>>
  _scoreEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scoreEntries,
    aliasName: $_aliasNameGenerator(
      db.gamePlayers.id,
      db.scoreEntries.gamePlayerId,
    ),
  );

  $$ScoreEntriesTableProcessedTableManager get scoreEntriesRefs {
    final manager = $$ScoreEntriesTableTableManager(
      $_db,
      $_db.scoreEntries,
    ).filter((f) => f.gamePlayerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scoreEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamePlayersTableFilterComposer
    extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scoreEntriesRefs(
    Expression<bool> Function($$ScoreEntriesTableFilterComposer f) f,
  ) {
    final $$ScoreEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreEntries,
      getReferencedColumn: (t) => t.gamePlayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreEntriesTableFilterComposer(
            $db: $db,
            $table: $db.scoreEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamePlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GamePlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scoreEntriesRefs<T extends Object>(
    Expression<T> Function($$ScoreEntriesTableAnnotationComposer a) f,
  ) {
    final $$ScoreEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreEntries,
      getReferencedColumn: (t) => t.gamePlayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.scoreEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamePlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamePlayersTable,
          GamePlayer,
          $$GamePlayersTableFilterComposer,
          $$GamePlayersTableOrderingComposer,
          $$GamePlayersTableAnnotationComposer,
          $$GamePlayersTableCreateCompanionBuilder,
          $$GamePlayersTableUpdateCompanionBuilder,
          (GamePlayer, $$GamePlayersTableReferences),
          GamePlayer,
          PrefetchHooks Function({
            bool gameId,
            bool playerId,
            bool scoreEntriesRefs,
          })
        > {
  $$GamePlayersTableTableManager(_$AppDatabase db, $GamePlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamePlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamePlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamePlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GamePlayersCompanion(
                id: id,
                gameId: gameId,
                playerId: playerId,
                orderIndex: orderIndex,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required int playerId,
                Value<int> orderIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GamePlayersCompanion.insert(
                id: id,
                gameId: gameId,
                playerId: playerId,
                orderIndex: orderIndex,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GamePlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({gameId = false, playerId = false, scoreEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scoreEntriesRefs) db.scoreEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gameId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameId,
                                    referencedTable:
                                        $$GamePlayersTableReferences
                                            ._gameIdTable(db),
                                    referencedColumn:
                                        $$GamePlayersTableReferences
                                            ._gameIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (playerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.playerId,
                                    referencedTable:
                                        $$GamePlayersTableReferences
                                            ._playerIdTable(db),
                                    referencedColumn:
                                        $$GamePlayersTableReferences
                                            ._playerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scoreEntriesRefs)
                        await $_getPrefetchedData<
                          GamePlayer,
                          $GamePlayersTable,
                          ScoreEntry
                        >(
                          currentTable: table,
                          referencedTable: $$GamePlayersTableReferences
                              ._scoreEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamePlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).scoreEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gamePlayerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GamePlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamePlayersTable,
      GamePlayer,
      $$GamePlayersTableFilterComposer,
      $$GamePlayersTableOrderingComposer,
      $$GamePlayersTableAnnotationComposer,
      $$GamePlayersTableCreateCompanionBuilder,
      $$GamePlayersTableUpdateCompanionBuilder,
      (GamePlayer, $$GamePlayersTableReferences),
      GamePlayer,
      PrefetchHooks Function({
        bool gameId,
        bool playerId,
        bool scoreEntriesRefs,
      })
    >;
typedef $$ScoreEntriesTableCreateCompanionBuilder =
    ScoreEntriesCompanion Function({
      Value<int> id,
      required int gamePlayerId,
      required int roundNumber,
      required int points,
      Value<DateTime> createdAt,
    });
typedef $$ScoreEntriesTableUpdateCompanionBuilder =
    ScoreEntriesCompanion Function({
      Value<int> id,
      Value<int> gamePlayerId,
      Value<int> roundNumber,
      Value<int> points,
      Value<DateTime> createdAt,
    });

final class $$ScoreEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $ScoreEntriesTable, ScoreEntry> {
  $$ScoreEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamePlayersTable _gamePlayerIdTable(_$AppDatabase db) =>
      db.gamePlayers.createAlias(
        $_aliasNameGenerator(db.scoreEntries.gamePlayerId, db.gamePlayers.id),
      );

  $$GamePlayersTableProcessedTableManager get gamePlayerId {
    final $_column = $_itemColumn<int>('game_player_id')!;

    final manager = $$GamePlayersTableTableManager(
      $_db,
      $_db.gamePlayers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gamePlayerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScoreEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ScoreEntriesTable> {
  $$ScoreEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamePlayersTableFilterComposer get gamePlayerId {
    final $$GamePlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gamePlayerId,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamePlayersTableFilterComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScoreEntriesTable> {
  $$ScoreEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamePlayersTableOrderingComposer get gamePlayerId {
    final $$GamePlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gamePlayerId,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamePlayersTableOrderingComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScoreEntriesTable> {
  $$ScoreEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GamePlayersTableAnnotationComposer get gamePlayerId {
    final $$GamePlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gamePlayerId,
      referencedTable: $db.gamePlayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamePlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.gamePlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScoreEntriesTable,
          ScoreEntry,
          $$ScoreEntriesTableFilterComposer,
          $$ScoreEntriesTableOrderingComposer,
          $$ScoreEntriesTableAnnotationComposer,
          $$ScoreEntriesTableCreateCompanionBuilder,
          $$ScoreEntriesTableUpdateCompanionBuilder,
          (ScoreEntry, $$ScoreEntriesTableReferences),
          ScoreEntry,
          PrefetchHooks Function({bool gamePlayerId})
        > {
  $$ScoreEntriesTableTableManager(_$AppDatabase db, $ScoreEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoreEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoreEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoreEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gamePlayerId = const Value.absent(),
                Value<int> roundNumber = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScoreEntriesCompanion(
                id: id,
                gamePlayerId: gamePlayerId,
                roundNumber: roundNumber,
                points: points,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gamePlayerId,
                required int roundNumber,
                required int points,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScoreEntriesCompanion.insert(
                id: id,
                gamePlayerId: gamePlayerId,
                roundNumber: roundNumber,
                points: points,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScoreEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gamePlayerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gamePlayerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gamePlayerId,
                                referencedTable: $$ScoreEntriesTableReferences
                                    ._gamePlayerIdTable(db),
                                referencedColumn: $$ScoreEntriesTableReferences
                                    ._gamePlayerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScoreEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScoreEntriesTable,
      ScoreEntry,
      $$ScoreEntriesTableFilterComposer,
      $$ScoreEntriesTableOrderingComposer,
      $$ScoreEntriesTableAnnotationComposer,
      $$ScoreEntriesTableCreateCompanionBuilder,
      $$ScoreEntriesTableUpdateCompanionBuilder,
      (ScoreEntry, $$ScoreEntriesTableReferences),
      ScoreEntry,
      PrefetchHooks Function({bool gamePlayerId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GameTypesTableTableManager get gameTypes =>
      $$GameTypesTableTableManager(_db, _db.gameTypes);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$GamePlayersTableTableManager get gamePlayers =>
      $$GamePlayersTableTableManager(_db, _db.gamePlayers);
  $$ScoreEntriesTableTableManager get scoreEntries =>
      $$ScoreEntriesTableTableManager(_db, _db.scoreEntries);
}
