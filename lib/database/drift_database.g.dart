// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $CategoryTable extends Category
    with TableInfo<$CategoryTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryNameMeta =
      const VerificationMeta('categoryName');
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
      'category_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, categoryName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_name')) {
      context.handle(
          _categoryNameMeta,
          categoryName.isAcceptableOrUnknown(
              data['category_name']!, _categoryNameMeta));
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_name'])!,
    );
  }

  @override
  $CategoryTable createAlias(String alias) {
    return $CategoryTable(attachedDatabase, alias);
  }
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final int id;
  final String categoryName;
  const CategoryData({required this.id, required this.categoryName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_name'] = Variable<String>(categoryName);
    return map;
  }

  CategoryCompanion toCompanion(bool nullToAbsent) {
    return CategoryCompanion(
      id: Value(id),
      categoryName: Value(categoryName),
    );
  }

  factory CategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<int>(json['id']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryName': serializer.toJson<String>(categoryName),
    };
  }

  CategoryData copyWith({int? id, String? categoryName}) => CategoryData(
        id: id ?? this.id,
        categoryName: categoryName ?? this.categoryName,
      );
  CategoryData copyWithCompanion(CategoryCompanion data) {
    return CategoryData(
      id: data.id.present ? data.id.value : this.id,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData &&
          other.id == this.id &&
          other.categoryName == this.categoryName);
}

class CategoryCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> categoryName;
  const CategoryCompanion({
    this.id = const Value.absent(),
    this.categoryName = const Value.absent(),
  });
  CategoryCompanion.insert({
    this.id = const Value.absent(),
    required String categoryName,
  }) : categoryName = Value(categoryName);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? categoryName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryName != null) 'category_name': categoryName,
    });
  }

  CategoryCompanion copyWith({Value<int>? id, Value<String>? categoryName}) {
    return CategoryCompanion(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryCompanion(')
          ..write('id: $id, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES category (id)'));
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
      [id, categoryId, expenseName, expense, expenseDate, expenseDetail];
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
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
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
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
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
  final int? categoryId;
  final String expenseName;
  final int expense;
  final DateTime expenseDate;
  final String? expenseDetail;
  const Expense(
      {required this.id,
      this.categoryId,
      required this.expenseName,
      required this.expense,
      required this.expenseDate,
      this.expenseDetail});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
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
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
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
      categoryId: serializer.fromJson<int?>(json['categoryId']),
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
      'categoryId': serializer.toJson<int?>(categoryId),
      'expenseName': serializer.toJson<String>(expenseName),
      'expense': serializer.toJson<int>(expense),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'expenseDetail': serializer.toJson<String?>(expenseDetail),
    };
  }

  Expense copyWith(
          {int? id,
          Value<int?> categoryId = const Value.absent(),
          String? expenseName,
          int? expense,
          DateTime? expenseDate,
          Value<String?> expenseDetail = const Value.absent()}) =>
      Expense(
        id: id ?? this.id,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        expenseName: expenseName ?? this.expenseName,
        expense: expense ?? this.expense,
        expenseDate: expenseDate ?? this.expenseDate,
        expenseDetail:
            expenseDetail.present ? expenseDetail.value : this.expenseDetail,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
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
          ..write('categoryId: $categoryId, ')
          ..write('expenseName: $expenseName, ')
          ..write('expense: $expense, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('expenseDetail: $expenseDetail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, categoryId, expenseName, expense, expenseDate, expenseDetail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.expenseName == this.expenseName &&
          other.expense == this.expense &&
          other.expenseDate == this.expenseDate &&
          other.expenseDetail == this.expenseDetail);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<int?> categoryId;
  final Value<String> expenseName;
  final Value<int> expense;
  final Value<DateTime> expenseDate;
  final Value<String?> expenseDetail;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.expenseName = const Value.absent(),
    this.expense = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.expenseDetail = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String expenseName,
    required int expense,
    required DateTime expenseDate,
    this.expenseDetail = const Value.absent(),
  })  : expenseName = Value(expenseName),
        expense = Value(expense),
        expenseDate = Value(expenseDate);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? expenseName,
    Expression<int>? expense,
    Expression<DateTime>? expenseDate,
    Expression<String>? expenseDetail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (expenseName != null) 'expense_name': expenseName,
      if (expense != null) 'expense': expense,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (expenseDetail != null) 'expense_detail': expenseDetail,
    });
  }

  ExpensesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? categoryId,
      Value<String>? expenseName,
      Value<int>? expense,
      Value<DateTime>? expenseDate,
      Value<String?>? expenseDetail}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
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
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
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
          ..write('categoryId: $categoryId, ')
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
  late final $CategoryTable category = $CategoryTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [category, expenses];
}

typedef $$CategoryTableCreateCompanionBuilder = CategoryCompanion Function({
  Value<int> id,
  required String categoryName,
});
typedef $$CategoryTableUpdateCompanionBuilder = CategoryCompanion Function({
  Value<int> id,
  Value<String> categoryName,
});

final class $$CategoryTableReferences
    extends BaseReferences<_$LocalDatabase, $CategoryTable, CategoryData> {
  $$CategoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName:
              $_aliasNameGenerator(db.category.id, db.expenses.categoryId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoryTableFilterComposer
    extends Composer<_$LocalDatabase, $CategoryTable> {
  $$CategoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => ColumnFilters(column));

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoryTableOrderingComposer
    extends Composer<_$LocalDatabase, $CategoryTable> {
  $$CategoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryName => $composableBuilder(
      column: $table.categoryName,
      builder: (column) => ColumnOrderings(column));
}

class $$CategoryTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CategoryTable> {
  $$CategoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoryTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CategoryTable,
    CategoryData,
    $$CategoryTableFilterComposer,
    $$CategoryTableOrderingComposer,
    $$CategoryTableAnnotationComposer,
    $$CategoryTableCreateCompanionBuilder,
    $$CategoryTableUpdateCompanionBuilder,
    (CategoryData, $$CategoryTableReferences),
    CategoryData,
    PrefetchHooks Function({bool expensesRefs})> {
  $$CategoryTableTableManager(_$LocalDatabase db, $CategoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> categoryName = const Value.absent(),
          }) =>
              CategoryCompanion(
            id: id,
            categoryName: categoryName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String categoryName,
          }) =>
              CategoryCompanion.insert(
            id: id,
            categoryName: categoryName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CategoryTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoryTableReferences._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoryTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoryTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $CategoryTable,
    CategoryData,
    $$CategoryTableFilterComposer,
    $$CategoryTableOrderingComposer,
    $$CategoryTableAnnotationComposer,
    $$CategoryTableCreateCompanionBuilder,
    $$CategoryTableUpdateCompanionBuilder,
    (CategoryData, $$CategoryTableReferences),
    CategoryData,
    PrefetchHooks Function({bool expensesRefs})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<int?> categoryId,
  required String expenseName,
  required int expense,
  required DateTime expenseDate,
  Value<String?> expenseDetail,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<int?> categoryId,
  Value<String> expenseName,
  Value<int> expense,
  Value<DateTime> expenseDate,
  Value<String?> expenseDetail,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$LocalDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoryTable _categoryIdTable(_$LocalDatabase db) =>
      db.category.createAlias(
          $_aliasNameGenerator(db.expenses.categoryId, db.category.id));

  $$CategoryTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoryTableTableManager($_db, $_db.category)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

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

  ColumnFilters<String> get expenseName => $composableBuilder(
      column: $table.expenseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expense => $composableBuilder(
      column: $table.expense, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expenseDetail => $composableBuilder(
      column: $table.expenseDetail, builder: (column) => ColumnFilters(column));

  $$CategoryTableFilterComposer get categoryId {
    final $$CategoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.category,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableFilterComposer(
              $db: $db,
              $table: $db.category,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  ColumnOrderings<String> get expenseName => $composableBuilder(
      column: $table.expenseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expense => $composableBuilder(
      column: $table.expense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expenseDetail => $composableBuilder(
      column: $table.expenseDetail,
      builder: (column) => ColumnOrderings(column));

  $$CategoryTableOrderingComposer get categoryId {
    final $$CategoryTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.category,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableOrderingComposer(
              $db: $db,
              $table: $db.category,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<String> get expenseName => $composableBuilder(
      column: $table.expenseName, builder: (column) => column);

  GeneratedColumn<int> get expense =>
      $composableBuilder(column: $table.expense, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => column);

  GeneratedColumn<String> get expenseDetail => $composableBuilder(
      column: $table.expenseDetail, builder: (column) => column);

  $$CategoryTableAnnotationComposer get categoryId {
    final $$CategoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.category,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableAnnotationComposer(
              $db: $db,
              $table: $db.category,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function({bool categoryId})> {
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
            Value<int?> categoryId = const Value.absent(),
            Value<String> expenseName = const Value.absent(),
            Value<int> expense = const Value.absent(),
            Value<DateTime> expenseDate = const Value.absent(),
            Value<String?> expenseDetail = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            categoryId: categoryId,
            expenseName: expenseName,
            expense: expense,
            expenseDate: expenseDate,
            expenseDetail: expenseDetail,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required String expenseName,
            required int expense,
            required DateTime expenseDate,
            Value<String?> expenseDetail = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            categoryId: categoryId,
            expenseName: expenseName,
            expense: expense,
            expenseDate: expenseDate,
            expenseDetail: expenseDetail,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ExpensesTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function({bool categoryId})>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CategoryTableTableManager get category =>
      $$CategoryTableTableManager(_db, _db.category);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
}
