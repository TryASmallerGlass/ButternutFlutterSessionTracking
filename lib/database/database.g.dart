// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionDateTimeMeta = const VerificationMeta(
    'sessionDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> sessionDateTime =
      GeneratedColumn<DateTime>(
        'session_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _cvDurationMinutesMeta = const VerificationMeta(
    'cvDurationMinutes',
  );
  @override
  late final GeneratedColumn<int> cvDurationMinutes = GeneratedColumn<int>(
    'cv_duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvLevelMeta = const VerificationMeta(
    'cvLevel',
  );
  @override
  late final GeneratedColumn<int> cvLevel = GeneratedColumn<int>(
    'cv_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionDateTime,
    cvDurationMinutes,
    cvLevel,
    comment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_date_time')) {
      context.handle(
        _sessionDateTimeMeta,
        sessionDateTime.isAcceptableOrUnknown(
          data['session_date_time']!,
          _sessionDateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionDateTimeMeta);
    }
    if (data.containsKey('cv_duration_minutes')) {
      context.handle(
        _cvDurationMinutesMeta,
        cvDurationMinutes.isAcceptableOrUnknown(
          data['cv_duration_minutes']!,
          _cvDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('cv_level')) {
      context.handle(
        _cvLevelMeta,
        cvLevel.isAcceptableOrUnknown(data['cv_level']!, _cvLevelMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    } else if (isInserting) {
      context.missing(_commentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_date_time'],
      )!,
      cvDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_duration_minutes'],
      ),
      cvLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_level'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final DateTime sessionDateTime;
  final int? cvDurationMinutes;
  final int? cvLevel;
  final String comment;
  const Session({
    required this.id,
    required this.sessionDateTime,
    this.cvDurationMinutes,
    this.cvLevel,
    required this.comment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_date_time'] = Variable<DateTime>(sessionDateTime);
    if (!nullToAbsent || cvDurationMinutes != null) {
      map['cv_duration_minutes'] = Variable<int>(cvDurationMinutes);
    }
    if (!nullToAbsent || cvLevel != null) {
      map['cv_level'] = Variable<int>(cvLevel);
    }
    map['comment'] = Variable<String>(comment);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      sessionDateTime: Value(sessionDateTime),
      cvDurationMinutes: cvDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(cvDurationMinutes),
      cvLevel: cvLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(cvLevel),
      comment: Value(comment),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      sessionDateTime: serializer.fromJson<DateTime>(json['sessionDateTime']),
      cvDurationMinutes: serializer.fromJson<int?>(json['cvDurationMinutes']),
      cvLevel: serializer.fromJson<int?>(json['cvLevel']),
      comment: serializer.fromJson<String>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionDateTime': serializer.toJson<DateTime>(sessionDateTime),
      'cvDurationMinutes': serializer.toJson<int?>(cvDurationMinutes),
      'cvLevel': serializer.toJson<int?>(cvLevel),
      'comment': serializer.toJson<String>(comment),
    };
  }

  Session copyWith({
    int? id,
    DateTime? sessionDateTime,
    Value<int?> cvDurationMinutes = const Value.absent(),
    Value<int?> cvLevel = const Value.absent(),
    String? comment,
  }) => Session(
    id: id ?? this.id,
    sessionDateTime: sessionDateTime ?? this.sessionDateTime,
    cvDurationMinutes: cvDurationMinutes.present
        ? cvDurationMinutes.value
        : this.cvDurationMinutes,
    cvLevel: cvLevel.present ? cvLevel.value : this.cvLevel,
    comment: comment ?? this.comment,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      sessionDateTime: data.sessionDateTime.present
          ? data.sessionDateTime.value
          : this.sessionDateTime,
      cvDurationMinutes: data.cvDurationMinutes.present
          ? data.cvDurationMinutes.value
          : this.cvDurationMinutes,
      cvLevel: data.cvLevel.present ? data.cvLevel.value : this.cvLevel,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('sessionDateTime: $sessionDateTime, ')
          ..write('cvDurationMinutes: $cvDurationMinutes, ')
          ..write('cvLevel: $cvLevel, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionDateTime, cvDurationMinutes, cvLevel, comment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.sessionDateTime == this.sessionDateTime &&
          other.cvDurationMinutes == this.cvDurationMinutes &&
          other.cvLevel == this.cvLevel &&
          other.comment == this.comment);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<DateTime> sessionDateTime;
  final Value<int?> cvDurationMinutes;
  final Value<int?> cvLevel;
  final Value<String> comment;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.sessionDateTime = const Value.absent(),
    this.cvDurationMinutes = const Value.absent(),
    this.cvLevel = const Value.absent(),
    this.comment = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime sessionDateTime,
    this.cvDurationMinutes = const Value.absent(),
    this.cvLevel = const Value.absent(),
    required String comment,
  }) : sessionDateTime = Value(sessionDateTime),
       comment = Value(comment);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<DateTime>? sessionDateTime,
    Expression<int>? cvDurationMinutes,
    Expression<int>? cvLevel,
    Expression<String>? comment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionDateTime != null) 'session_date_time': sessionDateTime,
      if (cvDurationMinutes != null) 'cv_duration_minutes': cvDurationMinutes,
      if (cvLevel != null) 'cv_level': cvLevel,
      if (comment != null) 'comment': comment,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? sessionDateTime,
    Value<int?>? cvDurationMinutes,
    Value<int?>? cvLevel,
    Value<String>? comment,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      sessionDateTime: sessionDateTime ?? this.sessionDateTime,
      cvDurationMinutes: cvDurationMinutes ?? this.cvDurationMinutes,
      cvLevel: cvLevel ?? this.cvLevel,
      comment: comment ?? this.comment,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionDateTime.present) {
      map['session_date_time'] = Variable<DateTime>(sessionDateTime.value);
    }
    if (cvDurationMinutes.present) {
      map['cv_duration_minutes'] = Variable<int>(cvDurationMinutes.value);
    }
    if (cvLevel.present) {
      map['cv_level'] = Variable<int>(cvLevel.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionDateTime: $sessionDateTime, ')
          ..write('cvDurationMinutes: $cvDurationMinutes, ')
          ..write('cvLevel: $cvLevel, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }
}

class $SessionMuscleGroupsTable extends SessionMuscleGroups
    with TableInfo<$SessionMuscleGroupsTable, SessionMuscleGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionMuscleGroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<String> muscleGroup = GeneratedColumn<String>(
    'muscle_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, muscleGroup];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_muscle_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionMuscleGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionMuscleGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionMuscleGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group'],
      )!,
    );
  }

  @override
  $SessionMuscleGroupsTable createAlias(String alias) {
    return $SessionMuscleGroupsTable(attachedDatabase, alias);
  }
}

class SessionMuscleGroup extends DataClass
    implements Insertable<SessionMuscleGroup> {
  final int id;
  final int sessionId;
  final String muscleGroup;
  const SessionMuscleGroup({
    required this.id,
    required this.sessionId,
    required this.muscleGroup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['muscle_group'] = Variable<String>(muscleGroup);
    return map;
  }

  SessionMuscleGroupsCompanion toCompanion(bool nullToAbsent) {
    return SessionMuscleGroupsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      muscleGroup: Value(muscleGroup),
    );
  }

  factory SessionMuscleGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionMuscleGroup(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      muscleGroup: serializer.fromJson<String>(json['muscleGroup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'muscleGroup': serializer.toJson<String>(muscleGroup),
    };
  }

  SessionMuscleGroup copyWith({int? id, int? sessionId, String? muscleGroup}) =>
      SessionMuscleGroup(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        muscleGroup: muscleGroup ?? this.muscleGroup,
      );
  SessionMuscleGroup copyWithCompanion(SessionMuscleGroupsCompanion data) {
    return SessionMuscleGroup(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionMuscleGroup(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('muscleGroup: $muscleGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, muscleGroup);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionMuscleGroup &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.muscleGroup == this.muscleGroup);
}

class SessionMuscleGroupsCompanion extends UpdateCompanion<SessionMuscleGroup> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> muscleGroup;
  const SessionMuscleGroupsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.muscleGroup = const Value.absent(),
  });
  SessionMuscleGroupsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String muscleGroup,
  }) : sessionId = Value(sessionId),
       muscleGroup = Value(muscleGroup);
  static Insertable<SessionMuscleGroup> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? muscleGroup,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
    });
  }

  SessionMuscleGroupsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? muscleGroup,
  }) {
    return SessionMuscleGroupsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(muscleGroup.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionMuscleGroupsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('muscleGroup: $muscleGroup')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionMuscleGroupsTable sessionMuscleGroups =
      $SessionMuscleGroupsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    sessionMuscleGroups,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required DateTime sessionDateTime,
      Value<int?> cvDurationMinutes,
      Value<int?> cvLevel,
      required String comment,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<DateTime> sessionDateTime,
      Value<int?> cvDurationMinutes,
      Value<int?> cvLevel,
      Value<String> comment,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get sessionDateTime => $composableBuilder(
    column: $table.sessionDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvDurationMinutes => $composableBuilder(
    column: $table.cvDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvLevel => $composableBuilder(
    column: $table.cvLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get sessionDateTime => $composableBuilder(
    column: $table.sessionDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvDurationMinutes => $composableBuilder(
    column: $table.cvDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvLevel => $composableBuilder(
    column: $table.cvLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get sessionDateTime => $composableBuilder(
    column: $table.sessionDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cvDurationMinutes => $composableBuilder(
    column: $table.cvDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cvLevel =>
      $composableBuilder(column: $table.cvLevel, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> sessionDateTime = const Value.absent(),
                Value<int?> cvDurationMinutes = const Value.absent(),
                Value<int?> cvLevel = const Value.absent(),
                Value<String> comment = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                sessionDateTime: sessionDateTime,
                cvDurationMinutes: cvDurationMinutes,
                cvLevel: cvLevel,
                comment: comment,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime sessionDateTime,
                Value<int?> cvDurationMinutes = const Value.absent(),
                Value<int?> cvLevel = const Value.absent(),
                required String comment,
              }) => SessionsCompanion.insert(
                id: id,
                sessionDateTime: sessionDateTime,
                cvDurationMinutes: cvDurationMinutes,
                cvLevel: cvLevel,
                comment: comment,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$SessionMuscleGroupsTableCreateCompanionBuilder =
    SessionMuscleGroupsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String muscleGroup,
    });
typedef $$SessionMuscleGroupsTableUpdateCompanionBuilder =
    SessionMuscleGroupsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> muscleGroup,
    });

class $$SessionMuscleGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionMuscleGroupsTable> {
  $$SessionMuscleGroupsTableFilterComposer({
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

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionMuscleGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionMuscleGroupsTable> {
  $$SessionMuscleGroupsTableOrderingComposer({
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

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionMuscleGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionMuscleGroupsTable> {
  $$SessionMuscleGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );
}

class $$SessionMuscleGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionMuscleGroupsTable,
          SessionMuscleGroup,
          $$SessionMuscleGroupsTableFilterComposer,
          $$SessionMuscleGroupsTableOrderingComposer,
          $$SessionMuscleGroupsTableAnnotationComposer,
          $$SessionMuscleGroupsTableCreateCompanionBuilder,
          $$SessionMuscleGroupsTableUpdateCompanionBuilder,
          (
            SessionMuscleGroup,
            BaseReferences<
              _$AppDatabase,
              $SessionMuscleGroupsTable,
              SessionMuscleGroup
            >,
          ),
          SessionMuscleGroup,
          PrefetchHooks Function()
        > {
  $$SessionMuscleGroupsTableTableManager(
    _$AppDatabase db,
    $SessionMuscleGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionMuscleGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionMuscleGroupsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SessionMuscleGroupsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> muscleGroup = const Value.absent(),
              }) => SessionMuscleGroupsCompanion(
                id: id,
                sessionId: sessionId,
                muscleGroup: muscleGroup,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String muscleGroup,
              }) => SessionMuscleGroupsCompanion.insert(
                id: id,
                sessionId: sessionId,
                muscleGroup: muscleGroup,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionMuscleGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionMuscleGroupsTable,
      SessionMuscleGroup,
      $$SessionMuscleGroupsTableFilterComposer,
      $$SessionMuscleGroupsTableOrderingComposer,
      $$SessionMuscleGroupsTableAnnotationComposer,
      $$SessionMuscleGroupsTableCreateCompanionBuilder,
      $$SessionMuscleGroupsTableUpdateCompanionBuilder,
      (
        SessionMuscleGroup,
        BaseReferences<
          _$AppDatabase,
          $SessionMuscleGroupsTable,
          SessionMuscleGroup
        >,
      ),
      SessionMuscleGroup,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionMuscleGroupsTableTableManager get sessionMuscleGroups =>
      $$SessionMuscleGroupsTableTableManager(_db, _db.sessionMuscleGroups);
}
