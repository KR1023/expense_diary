// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expenseNameMeta =
      const VerificationMeta('expenseName');
  @override
  late final GeneratedColumn<String> expenseName = GeneratedColumn<String>(
      'expense_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expenseMeta =
      const VerificationMeta('expense');
  @override
  late final GeneratedColumn<int> expense = GeneratedColumn<int>(
      'expense', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _expenseDateMeta =
      const VerificationMeta('expenseDate');
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
      'expense_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expenseDetailMeta =
      const VerificationMeta('expenseDetail');
  @override
  late final GeneratedColumn<String> expenseDetail = GeneratedColumn<String>(
      'expense_detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, category, expenseName, expense, expenseDate, expenseDetail];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('expense_name')) {
      context.handle(
          _expenseNameMeta,
          expenseName.isAcceptableOrUnknown(
              data['expense_name']!, _expenseNameMeta));
    } else if (isInserting) {
      context.missing(_expenseNameMeta);
    }
    if (data.containsKey('expense')) {
      context.handle(_expenseMeta,
          expense.isAcceptableOrUnknown(data['expense']!, _expenseMeta));
    } else if (isInserting) {
      context.missing(_expenseMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(
          _expenseDateMeta,
          expenseDate.isAcceptableOrUnknown(
              data['expense_date']!, _expenseDateMeta));
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('expense_detail')) {
      context.handle(
          _expenseDetailMeta,
          expenseDetail.isAcceptableOrUnknown(
              data['expense_detail']!, _expenseDetailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      expenseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expense_name'])!,
      expense: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expense'])!,
      expenseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expense_date'])!,
      expenseDetail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expense_detail']),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final String? category;
  final String expenseName;
  final int expense;
  final DateTime expenseDate;
  final String? expenseDetail;
  const Expense(
      {required this.id,
      this.category,
      required this.expenseName,
      required this.expense,
      required this.expenseDate,
      this.expenseDetail});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['expense_name'] = Variable<String>(expenseName);
    map['expense'] = Variable<int>(expense);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    if (!nullToAbsent || expenseDetail != null) {
      map['expense_detail'] = Variable<String>(expenseDetail);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      expenseName: Value(expenseName),
      expense: Value(expense),
      expenseDate: Value(expenseDate),
      expenseDetail: expenseDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseDetail),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String?>(json['category']),
      expenseName: serializer.fromJson<String>(json['expenseName']),
      expense: serializer.fromJson<int>(json['expense']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      expenseDetail: serializer.fromJson<String?>(json['expenseDetail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String?>(category),
      'expenseName': serializer.toJson<String>(expenseName),
      'expense': serializer.toJson<int>(expense),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'expenseDetail': serializer.toJson<String?>(expenseDetail),
    };
  }

  Expense copyWith(
          {int? id,
          Value<String?> category = const Value.absent(),
          String? expenseName,
          int? expense,
          DateTime? expenseDate,
          Value<String?> expenseDetail = const Value.absent()}) =>
      Expense(
        id: id ?? this.id,
        category: category.present ? category.value : this.category,
        expenseName: expenseName ?? this.expenseName,
        expense: expense ?? this.expense,
        expenseDate: expenseDate ?? this.expenseDate,
        expenseDetail:
            expenseDetail.present ? expenseDetail.value : this.expenseDetail,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      expenseName:
          data.expenseName.present ? data.expenseName.value : this.expenseName,
      expense: data.expense.present ? data.expense.value : this.expense,
      expenseDate:
          data.expenseDate.present ? data.expenseDate.value : this.expenseDate,
      expenseDetail: data.expenseDetail.present
          ? data.expenseDetail.value
          : this.expenseDetail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('expenseName: $expenseName, ')
          ..write('expense: $expense, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('expenseDetail: $expenseDetail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, category, expenseName, expense, expenseDate, expenseDetail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.category == this.category &&
          other.expenseName == this.expenseName &&
          other.expense == this.expense &&
          other.expenseDate == this.expenseDate &&
          other.expenseDetail == this.expenseDetail);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<String?> category;
  final Value<String> expenseName;
  final Value<int> expense;
  final Value<DateTime> expenseDate;
  final Value<String?> expenseDetail;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.expenseName = const Value.absent(),
    this.expense = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.expenseDetail = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    required String expenseName,
    required int expense,
    required DateTime expenseDate,
    this.expenseDetail = const Value.absent(),
  })  : expenseName = Value(expenseName),
        expense = Value(expense),
        expenseDate = Value(expenseDate);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? expenseName,
    Expression<int>? expense,
    Expression<DateTime>? expenseDate,
    Expression<String>? expenseDetail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (expenseName != null) 'expense_name': expenseName,
      if (expense != null) 'expense': expense,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (expenseDetail != null) 'expense_detail': expenseDetail,
    });
  }

  ExpensesCompanion copyWith(
      {Value<int>? id,
      Value<String?>? category,
      Value<String>? expenseName,
      Value<int>? expense,
      Value<DateTime>? expenseDate,
      Value<String?>? expenseDetail}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      expenseName: expenseName ?? this.expenseName,
      expense: expense ?? this.expense,
      expenseDate: expenseDate ?? this.expenseDate,
      expenseDetail: expenseDetail ?? this.expenseDetail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (expenseName.present) {
      map['expense_name'] = Variable<String>(expenseName.value);
    }
    if (expense.present) {
      map['expense'] = Variable<int>(expense.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (expenseDetail.present) {
      map['expense_detail'] = Variable<String>(expenseDetail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('expenseName: $expenseName, ')
          ..write('expense: $expense, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('expenseDetail: $expenseDetail')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [expenses];
}

typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String?> category,
  required String expenseName,
  required int expense,
  required DateTime expenseDate,
  Value<String?> expenseDetail,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String?> category,
  Value<String> expenseName,
  Value<int> expense,
  Value<DateTime> expenseDate,
  Value<String?> expenseDetail,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$LocalDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expenseName => $composableBuilder(
      column: $table.expenseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expense => $composableBuilder(
      column: $table.expense, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expenseDetail => $composableBuilder(
      column: $table.expenseDetail, builder: (column) => ColumnFilters(column));
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$LocalDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expenseName => $composableBuilder(
      column: $table.expenseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expense => $composableBuilder(
      column: $table.expense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expenseDetail => $composableBuilder(
      column: $table.expenseDetail,
      builder: (column) => ColumnOrderings(column));
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get expenseName => $composableBuilder(
      column: $table.expenseName, builder: (column) => column);

  GeneratedColumn<int> get expense =>
      $composableBuilder(column: $table.expense, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => column);

  GeneratedColumn<String> get expenseDetail => $composableBuilder(
      column: $table.expenseDetail, builder: (column) => column);
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$LocalDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()> {
  $$ExpensesTableTableManager(_$LocalDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String> expenseName = const Value.absent(),
            Value<int> expense = const Value.absent(),
            Value<DateTime> expenseDate = const Value.absent(),
            Value<String?> expenseDetail = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            category: category,
            expenseName: expenseName,
            expense: expense,
            expenseDate: expenseDate,
            expenseDetail: expenseDetail,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> category = const Value.absent(),
            required String expenseName,
            required int expense,
            required DateTime expenseDate,
            Value<String?> expenseDetail = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            category: category,
            expenseName: expenseName,
            expense: expense,
            expenseDate: expenseDate,
            expenseDetail: expenseDetail,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$LocalDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
}
