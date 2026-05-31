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
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {categoryName},
      ];
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

class $PaymentMethodsTable extends PaymentMethods
    with TableInfo<$PaymentMethodsTable, PaymentMethod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, name, memo, sortOrder, isArchived, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_methods';
  @override
  VerificationContext validateIntegrity(Insertable<PaymentMethod> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentMethod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentMethod(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PaymentMethodsTable createAlias(String alias) {
    return $PaymentMethodsTable(attachedDatabase, alias);
  }
}

class PaymentMethod extends DataClass implements Insertable<PaymentMethod> {
  final int id;
  final String type;
  final String name;
  final String? memo;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PaymentMethod(
      {required this.id,
      required this.type,
      required this.name,
      this.memo,
      required this.sortOrder,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PaymentMethodsCompanion toCompanion(bool nullToAbsent) {
    return PaymentMethodsCompanion(
      id: Value(id),
      type: Value(type),
      name: Value(name),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentMethod(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      memo: serializer.fromJson<String?>(json['memo']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'memo': serializer.toJson<String?>(memo),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PaymentMethod copyWith(
          {int? id,
          String? type,
          String? name,
          Value<String?> memo = const Value.absent(),
          int? sortOrder,
          bool? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PaymentMethod(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        memo: memo.present ? memo.value : this.memo,
        sortOrder: sortOrder ?? this.sortOrder,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PaymentMethod copyWithCompanion(PaymentMethodsCompanion data) {
    return PaymentMethod(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      memo: data.memo.present ? data.memo.value : this.memo,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethod(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('memo: $memo, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, name, memo, sortOrder, isArchived, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentMethod &&
          other.id == this.id &&
          other.type == this.type &&
          other.name == this.name &&
          other.memo == this.memo &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentMethodsCompanion extends UpdateCompanion<PaymentMethod> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> name;
  final Value<String?> memo;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PaymentMethodsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.memo = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PaymentMethodsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String name,
    this.memo = const Value.absent(),
    required int sortOrder,
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : type = Value(type),
        name = Value(name),
        sortOrder = Value(sortOrder),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PaymentMethod> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? memo,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (memo != null) 'memo': memo,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PaymentMethodsCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<String>? name,
      Value<String?>? memo,
      Value<int>? sortOrder,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PaymentMethodsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      memo: memo ?? this.memo,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethodsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('memo: $memo, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringExpensesTable extends RecurringExpenses
    with TableInfo<$RecurringExpensesTable, RecurringExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES category (id)'));
  static const VerificationMeta _paymentMethodIdMeta =
      const VerificationMeta('paymentMethodId');
  @override
  late final GeneratedColumn<int> paymentMethodId = GeneratedColumn<int>(
      'payment_method_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES payment_methods (id)'));
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextRunDateMeta =
      const VerificationMeta('nextRunDate');
  @override
  late final GeneratedColumn<DateTime> nextRunDate = GeneratedColumn<DateTime>(
      'next_run_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        amount,
        categoryId,
        paymentMethodId,
        detail,
        frequency,
        interval,
        startDate,
        endDate,
        nextRunDate,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_expenses';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringExpense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('payment_method_id')) {
      context.handle(
          _paymentMethodIdMeta,
          paymentMethodId.isAcceptableOrUnknown(
              data['payment_method_id']!, _paymentMethodIdMeta));
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('next_run_date')) {
      context.handle(
          _nextRunDateMeta,
          nextRunDate.isAcceptableOrUnknown(
              data['next_run_date']!, _nextRunDateMeta));
    } else if (isInserting) {
      context.missing(_nextRunDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringExpense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      paymentMethodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payment_method_id']),
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      nextRunDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_run_date'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RecurringExpensesTable createAlias(String alias) {
    return $RecurringExpensesTable(attachedDatabase, alias);
  }
}

class RecurringExpense extends DataClass
    implements Insertable<RecurringExpense> {
  final int id;
  final String name;
  final int amount;
  final int? categoryId;
  final int? paymentMethodId;
  final String? detail;
  final String frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextRunDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RecurringExpense(
      {required this.id,
      required this.name,
      required this.amount,
      this.categoryId,
      this.paymentMethodId,
      this.detail,
      required this.frequency,
      required this.interval,
      required this.startDate,
      this.endDate,
      required this.nextRunDate,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || paymentMethodId != null) {
      map['payment_method_id'] = Variable<int>(paymentMethodId);
    }
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    map['frequency'] = Variable<String>(frequency);
    map['interval'] = Variable<int>(interval);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['next_run_date'] = Variable<DateTime>(nextRunDate);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecurringExpensesCompanion toCompanion(bool nullToAbsent) {
    return RecurringExpensesCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      paymentMethodId: paymentMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodId),
      detail:
          detail == null && nullToAbsent ? const Value.absent() : Value(detail),
      frequency: Value(frequency),
      interval: Value(interval),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      nextRunDate: Value(nextRunDate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecurringExpense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringExpense(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<int>(json['amount']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      paymentMethodId: serializer.fromJson<int?>(json['paymentMethodId']),
      detail: serializer.fromJson<String?>(json['detail']),
      frequency: serializer.fromJson<String>(json['frequency']),
      interval: serializer.fromJson<int>(json['interval']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      nextRunDate: serializer.fromJson<DateTime>(json['nextRunDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<int>(amount),
      'categoryId': serializer.toJson<int?>(categoryId),
      'paymentMethodId': serializer.toJson<int?>(paymentMethodId),
      'detail': serializer.toJson<String?>(detail),
      'frequency': serializer.toJson<String>(frequency),
      'interval': serializer.toJson<int>(interval),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'nextRunDate': serializer.toJson<DateTime>(nextRunDate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecurringExpense copyWith(
          {int? id,
          String? name,
          int? amount,
          Value<int?> categoryId = const Value.absent(),
          Value<int?> paymentMethodId = const Value.absent(),
          Value<String?> detail = const Value.absent(),
          String? frequency,
          int? interval,
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          DateTime? nextRunDate,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringExpense(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        paymentMethodId: paymentMethodId.present
            ? paymentMethodId.value
            : this.paymentMethodId,
        detail: detail.present ? detail.value : this.detail,
        frequency: frequency ?? this.frequency,
        interval: interval ?? this.interval,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        nextRunDate: nextRunDate ?? this.nextRunDate,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RecurringExpense copyWithCompanion(RecurringExpensesCompanion data) {
    return RecurringExpense(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      detail: data.detail.present ? data.detail.value : this.detail,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      nextRunDate:
          data.nextRunDate.present ? data.nextRunDate.value : this.nextRunDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpense(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('detail: $detail, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextRunDate: $nextRunDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      amount,
      categoryId,
      paymentMethodId,
      detail,
      frequency,
      interval,
      startDate,
      endDate,
      nextRunDate,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringExpense &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.paymentMethodId == this.paymentMethodId &&
          other.detail == this.detail &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.nextRunDate == this.nextRunDate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringExpensesCompanion extends UpdateCompanion<RecurringExpense> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> amount;
  final Value<int?> categoryId;
  final Value<int?> paymentMethodId;
  final Value<String?> detail;
  final Value<String> frequency;
  final Value<int> interval;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> nextRunDate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RecurringExpensesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.detail = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.nextRunDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RecurringExpensesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int amount,
    this.categoryId = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.detail = const Value.absent(),
    required String frequency,
    this.interval = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required DateTime nextRunDate,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        amount = Value(amount),
        frequency = Value(frequency),
        startDate = Value(startDate),
        nextRunDate = Value(nextRunDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RecurringExpense> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? amount,
    Expression<int>? categoryId,
    Expression<int>? paymentMethodId,
    Expression<String>? detail,
    Expression<String>? frequency,
    Expression<int>? interval,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? nextRunDate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (detail != null) 'detail': detail,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (nextRunDate != null) 'next_run_date': nextRunDate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RecurringExpensesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? amount,
      Value<int?>? categoryId,
      Value<int?>? paymentMethodId,
      Value<String?>? detail,
      Value<String>? frequency,
      Value<int>? interval,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<DateTime>? nextRunDate,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return RecurringExpensesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      detail: detail ?? this.detail,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<int>(paymentMethodId.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (nextRunDate.present) {
      map['next_run_date'] = Variable<DateTime>(nextRunDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpensesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('detail: $detail, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextRunDate: $nextRunDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  static const VerificationMeta _paymentMethodIdMeta =
      const VerificationMeta('paymentMethodId');
  @override
  late final GeneratedColumn<int> paymentMethodId = GeneratedColumn<int>(
      'payment_method_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES payment_methods (id)'));
  static const VerificationMeta _recurringExpenseIdMeta =
      const VerificationMeta('recurringExpenseId');
  @override
  late final GeneratedColumn<int> recurringExpenseId = GeneratedColumn<int>(
      'recurring_expense_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_expenses (id)'));
  static const VerificationMeta _recurringOccurrenceDateMeta =
      const VerificationMeta('recurringOccurrenceDate');
  @override
  late final GeneratedColumn<DateTime> recurringOccurrenceDate =
      GeneratedColumn<DateTime>('recurring_occurrence_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        expenseName,
        expense,
        expenseDate,
        expenseDetail,
        paymentMethodId,
        recurringExpenseId,
        recurringOccurrenceDate
      ];
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
    if (data.containsKey('payment_method_id')) {
      context.handle(
          _paymentMethodIdMeta,
          paymentMethodId.isAcceptableOrUnknown(
              data['payment_method_id']!, _paymentMethodIdMeta));
    }
    if (data.containsKey('recurring_expense_id')) {
      context.handle(
          _recurringExpenseIdMeta,
          recurringExpenseId.isAcceptableOrUnknown(
              data['recurring_expense_id']!, _recurringExpenseIdMeta));
    }
    if (data.containsKey('recurring_occurrence_date')) {
      context.handle(
          _recurringOccurrenceDateMeta,
          recurringOccurrenceDate.isAcceptableOrUnknown(
              data['recurring_occurrence_date']!,
              _recurringOccurrenceDateMeta));
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
      paymentMethodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payment_method_id']),
      recurringExpenseId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}recurring_expense_id']),
      recurringOccurrenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}recurring_occurrence_date']),
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
  final int? paymentMethodId;
  final int? recurringExpenseId;
  final DateTime? recurringOccurrenceDate;
  const Expense(
      {required this.id,
      this.categoryId,
      required this.expenseName,
      required this.expense,
      required this.expenseDate,
      this.expenseDetail,
      this.paymentMethodId,
      this.recurringExpenseId,
      this.recurringOccurrenceDate});
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
    if (!nullToAbsent || paymentMethodId != null) {
      map['payment_method_id'] = Variable<int>(paymentMethodId);
    }
    if (!nullToAbsent || recurringExpenseId != null) {
      map['recurring_expense_id'] = Variable<int>(recurringExpenseId);
    }
    if (!nullToAbsent || recurringOccurrenceDate != null) {
      map['recurring_occurrence_date'] =
          Variable<DateTime>(recurringOccurrenceDate);
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
      paymentMethodId: paymentMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodId),
      recurringExpenseId: recurringExpenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringExpenseId),
      recurringOccurrenceDate: recurringOccurrenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringOccurrenceDate),
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
      paymentMethodId: serializer.fromJson<int?>(json['paymentMethodId']),
      recurringExpenseId: serializer.fromJson<int?>(json['recurringExpenseId']),
      recurringOccurrenceDate:
          serializer.fromJson<DateTime?>(json['recurringOccurrenceDate']),
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
      'paymentMethodId': serializer.toJson<int?>(paymentMethodId),
      'recurringExpenseId': serializer.toJson<int?>(recurringExpenseId),
      'recurringOccurrenceDate':
          serializer.toJson<DateTime?>(recurringOccurrenceDate),
    };
  }

  Expense copyWith(
          {int? id,
          Value<int?> categoryId = const Value.absent(),
          String? expenseName,
          int? expense,
          DateTime? expenseDate,
          Value<String?> expenseDetail = const Value.absent(),
          Value<int?> paymentMethodId = const Value.absent(),
          Value<int?> recurringExpenseId = const Value.absent(),
          Value<DateTime?> recurringOccurrenceDate = const Value.absent()}) =>
      Expense(
        id: id ?? this.id,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        expenseName: expenseName ?? this.expenseName,
        expense: expense ?? this.expense,
        expenseDate: expenseDate ?? this.expenseDate,
        expenseDetail:
            expenseDetail.present ? expenseDetail.value : this.expenseDetail,
        paymentMethodId: paymentMethodId.present
            ? paymentMethodId.value
            : this.paymentMethodId,
        recurringExpenseId: recurringExpenseId.present
            ? recurringExpenseId.value
            : this.recurringExpenseId,
        recurringOccurrenceDate: recurringOccurrenceDate.present
            ? recurringOccurrenceDate.value
            : this.recurringOccurrenceDate,
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
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      recurringExpenseId: data.recurringExpenseId.present
          ? data.recurringExpenseId.value
          : this.recurringExpenseId,
      recurringOccurrenceDate: data.recurringOccurrenceDate.present
          ? data.recurringOccurrenceDate.value
          : this.recurringOccurrenceDate,
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
          ..write('expenseDetail: $expenseDetail, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('recurringExpenseId: $recurringExpenseId, ')
          ..write('recurringOccurrenceDate: $recurringOccurrenceDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      categoryId,
      expenseName,
      expense,
      expenseDate,
      expenseDetail,
      paymentMethodId,
      recurringExpenseId,
      recurringOccurrenceDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.expenseName == this.expenseName &&
          other.expense == this.expense &&
          other.expenseDate == this.expenseDate &&
          other.expenseDetail == this.expenseDetail &&
          other.paymentMethodId == this.paymentMethodId &&
          other.recurringExpenseId == this.recurringExpenseId &&
          other.recurringOccurrenceDate == this.recurringOccurrenceDate);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<int?> categoryId;
  final Value<String> expenseName;
  final Value<int> expense;
  final Value<DateTime> expenseDate;
  final Value<String?> expenseDetail;
  final Value<int?> paymentMethodId;
  final Value<int?> recurringExpenseId;
  final Value<DateTime?> recurringOccurrenceDate;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.expenseName = const Value.absent(),
    this.expense = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.expenseDetail = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.recurringExpenseId = const Value.absent(),
    this.recurringOccurrenceDate = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String expenseName,
    required int expense,
    required DateTime expenseDate,
    this.expenseDetail = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.recurringExpenseId = const Value.absent(),
    this.recurringOccurrenceDate = const Value.absent(),
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
    Expression<int>? paymentMethodId,
    Expression<int>? recurringExpenseId,
    Expression<DateTime>? recurringOccurrenceDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (expenseName != null) 'expense_name': expenseName,
      if (expense != null) 'expense': expense,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (expenseDetail != null) 'expense_detail': expenseDetail,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (recurringExpenseId != null)
        'recurring_expense_id': recurringExpenseId,
      if (recurringOccurrenceDate != null)
        'recurring_occurrence_date': recurringOccurrenceDate,
    });
  }

  ExpensesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? categoryId,
      Value<String>? expenseName,
      Value<int>? expense,
      Value<DateTime>? expenseDate,
      Value<String?>? expenseDetail,
      Value<int?>? paymentMethodId,
      Value<int?>? recurringExpenseId,
      Value<DateTime?>? recurringOccurrenceDate}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      expenseName: expenseName ?? this.expenseName,
      expense: expense ?? this.expense,
      expenseDate: expenseDate ?? this.expenseDate,
      expenseDetail: expenseDetail ?? this.expenseDetail,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
      recurringOccurrenceDate:
          recurringOccurrenceDate ?? this.recurringOccurrenceDate,
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
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<int>(paymentMethodId.value);
    }
    if (recurringExpenseId.present) {
      map['recurring_expense_id'] = Variable<int>(recurringExpenseId.value);
    }
    if (recurringOccurrenceDate.present) {
      map['recurring_occurrence_date'] =
          Variable<DateTime>(recurringOccurrenceDate.value);
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
          ..write('expenseDetail: $expenseDetail, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('recurringExpenseId: $recurringExpenseId, ')
          ..write('recurringOccurrenceDate: $recurringOccurrenceDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $CategoryTable category = $CategoryTable(this);
  late final $PaymentMethodsTable paymentMethods = $PaymentMethodsTable(this);
  late final $RecurringExpensesTable recurringExpenses =
      $RecurringExpensesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [category, paymentMethods, recurringExpenses, expenses];
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

  static MultiTypedResultKey<$RecurringExpensesTable, List<RecurringExpense>>
      _recurringExpensesRefsTable(_$LocalDatabase db) =>
          MultiTypedResultKey.fromTable(db.recurringExpenses,
              aliasName: $_aliasNameGenerator(
                  db.category.id, db.recurringExpenses.categoryId));

  $$RecurringExpensesTableProcessedTableManager get recurringExpensesRefs {
    final manager =
        $$RecurringExpensesTableTableManager($_db, $_db.recurringExpenses)
            .filter((f) => f.categoryId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_recurringExpensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

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

  Expression<bool> recurringExpensesRefs(
      Expression<bool> Function($$RecurringExpensesTableFilterComposer f) f) {
    final $$RecurringExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringExpenses,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringExpensesTableFilterComposer(
              $db: $db,
              $table: $db.recurringExpenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

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

  Expression<T> recurringExpensesRefs<T extends Object>(
      Expression<T> Function($$RecurringExpensesTableAnnotationComposer a) f) {
    final $$RecurringExpensesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringExpenses,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringExpensesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringExpenses,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

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
    PrefetchHooks Function({bool recurringExpensesRefs, bool expensesRefs})> {
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
          prefetchHooksCallback: (
              {recurringExpensesRefs = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringExpensesRefs) db.recurringExpenses,
                if (expensesRefs) db.expenses
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringExpensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoryTableReferences
                            ._recurringExpensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoryTableReferences(db, table, p0)
                                .recurringExpensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
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
    PrefetchHooks Function({bool recurringExpensesRefs, bool expensesRefs})>;
typedef $$PaymentMethodsTableCreateCompanionBuilder = PaymentMethodsCompanion
    Function({
  Value<int> id,
  required String type,
  required String name,
  Value<String?> memo,
  required int sortOrder,
  Value<bool> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$PaymentMethodsTableUpdateCompanionBuilder = PaymentMethodsCompanion
    Function({
  Value<int> id,
  Value<String> type,
  Value<String> name,
  Value<String?> memo,
  Value<int> sortOrder,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$PaymentMethodsTableReferences extends BaseReferences<
    _$LocalDatabase, $PaymentMethodsTable, PaymentMethod> {
  $$PaymentMethodsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecurringExpensesTable, List<RecurringExpense>>
      _recurringExpensesRefsTable(_$LocalDatabase db) =>
          MultiTypedResultKey.fromTable(db.recurringExpenses,
              aliasName: $_aliasNameGenerator(
                  db.paymentMethods.id, db.recurringExpenses.paymentMethodId));

  $$RecurringExpensesTableProcessedTableManager get recurringExpensesRefs {
    final manager =
        $$RecurringExpensesTableTableManager($_db, $_db.recurringExpenses)
            .filter((f) => f.paymentMethodId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_recurringExpensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName: $_aliasNameGenerator(
              db.paymentMethods.id, db.expenses.paymentMethodId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.paymentMethodId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PaymentMethodsTableFilterComposer
    extends Composer<_$LocalDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> recurringExpensesRefs(
      Expression<bool> Function($$RecurringExpensesTableFilterComposer f) f) {
    final $$RecurringExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringExpenses,
        getReferencedColumn: (t) => t.paymentMethodId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringExpensesTableFilterComposer(
              $db: $db,
              $table: $db.recurringExpenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.paymentMethodId,
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

class $$PaymentMethodsTableOrderingComposer
    extends Composer<_$LocalDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PaymentMethodsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> recurringExpensesRefs<T extends Object>(
      Expression<T> Function($$RecurringExpensesTableAnnotationComposer a) f) {
    final $$RecurringExpensesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringExpenses,
            getReferencedColumn: (t) => t.paymentMethodId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringExpensesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringExpenses,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.paymentMethodId,
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

class $$PaymentMethodsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $PaymentMethodsTable,
    PaymentMethod,
    $$PaymentMethodsTableFilterComposer,
    $$PaymentMethodsTableOrderingComposer,
    $$PaymentMethodsTableAnnotationComposer,
    $$PaymentMethodsTableCreateCompanionBuilder,
    $$PaymentMethodsTableUpdateCompanionBuilder,
    (PaymentMethod, $$PaymentMethodsTableReferences),
    PaymentMethod,
    PrefetchHooks Function({bool recurringExpensesRefs, bool expensesRefs})> {
  $$PaymentMethodsTableTableManager(
      _$LocalDatabase db, $PaymentMethodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PaymentMethodsCompanion(
            id: id,
            type: type,
            name: name,
            memo: memo,
            sortOrder: sortOrder,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required String name,
            Value<String?> memo = const Value.absent(),
            required int sortOrder,
            Value<bool> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              PaymentMethodsCompanion.insert(
            id: id,
            type: type,
            name: name,
            memo: memo,
            sortOrder: sortOrder,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PaymentMethodsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {recurringExpensesRefs = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringExpensesRefs) db.recurringExpenses,
                if (expensesRefs) db.expenses
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringExpensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$PaymentMethodsTableReferences
                            ._recurringExpensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PaymentMethodsTableReferences(db, table, p0)
                                .recurringExpensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.paymentMethodId == item.id),
                        typedResults: items),
                  if (expensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$PaymentMethodsTableReferences
                            ._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PaymentMethodsTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.paymentMethodId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PaymentMethodsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $PaymentMethodsTable,
    PaymentMethod,
    $$PaymentMethodsTableFilterComposer,
    $$PaymentMethodsTableOrderingComposer,
    $$PaymentMethodsTableAnnotationComposer,
    $$PaymentMethodsTableCreateCompanionBuilder,
    $$PaymentMethodsTableUpdateCompanionBuilder,
    (PaymentMethod, $$PaymentMethodsTableReferences),
    PaymentMethod,
    PrefetchHooks Function({bool recurringExpensesRefs, bool expensesRefs})>;
typedef $$RecurringExpensesTableCreateCompanionBuilder
    = RecurringExpensesCompanion Function({
  Value<int> id,
  required String name,
  required int amount,
  Value<int?> categoryId,
  Value<int?> paymentMethodId,
  Value<String?> detail,
  required String frequency,
  Value<int> interval,
  required DateTime startDate,
  Value<DateTime?> endDate,
  required DateTime nextRunDate,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$RecurringExpensesTableUpdateCompanionBuilder
    = RecurringExpensesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> amount,
  Value<int?> categoryId,
  Value<int?> paymentMethodId,
  Value<String?> detail,
  Value<String> frequency,
  Value<int> interval,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<DateTime> nextRunDate,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$RecurringExpensesTableReferences extends BaseReferences<
    _$LocalDatabase, $RecurringExpensesTable, RecurringExpense> {
  $$RecurringExpensesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoryTable _categoryIdTable(_$LocalDatabase db) =>
      db.category.createAlias($_aliasNameGenerator(
          db.recurringExpenses.categoryId, db.category.id));

  $$CategoryTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoryTableTableManager($_db, $_db.category)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PaymentMethodsTable _paymentMethodIdTable(_$LocalDatabase db) =>
      db.paymentMethods.createAlias($_aliasNameGenerator(
          db.recurringExpenses.paymentMethodId, db.paymentMethods.id));

  $$PaymentMethodsTableProcessedTableManager? get paymentMethodId {
    if ($_item.paymentMethodId == null) return null;
    final manager = $$PaymentMethodsTableTableManager($_db, $_db.paymentMethods)
        .filter((f) => f.id($_item.paymentMethodId!));
    final item = $_typedResult.readTableOrNull(_paymentMethodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName: $_aliasNameGenerator(
              db.recurringExpenses.id, db.expenses.recurringExpenseId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.recurringExpenseId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecurringExpensesTableFilterComposer
    extends Composer<_$LocalDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRunDate => $composableBuilder(
      column: $table.nextRunDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

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

  $$PaymentMethodsTableFilterComposer get paymentMethodId {
    final $$PaymentMethodsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentMethodId,
        referencedTable: $db.paymentMethods,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentMethodsTableFilterComposer(
              $db: $db,
              $table: $db.paymentMethods,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.recurringExpenseId,
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

class $$RecurringExpensesTableOrderingComposer
    extends Composer<_$LocalDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRunDate => $composableBuilder(
      column: $table.nextRunDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

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

  $$PaymentMethodsTableOrderingComposer get paymentMethodId {
    final $$PaymentMethodsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentMethodId,
        referencedTable: $db.paymentMethods,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentMethodsTableOrderingComposer(
              $db: $db,
              $table: $db.paymentMethods,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringExpensesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableAnnotationComposer({
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

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRunDate => $composableBuilder(
      column: $table.nextRunDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

  $$PaymentMethodsTableAnnotationComposer get paymentMethodId {
    final $$PaymentMethodsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentMethodId,
        referencedTable: $db.paymentMethods,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentMethodsTableAnnotationComposer(
              $db: $db,
              $table: $db.paymentMethods,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.recurringExpenseId,
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

class $$RecurringExpensesTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $RecurringExpensesTable,
    RecurringExpense,
    $$RecurringExpensesTableFilterComposer,
    $$RecurringExpensesTableOrderingComposer,
    $$RecurringExpensesTableAnnotationComposer,
    $$RecurringExpensesTableCreateCompanionBuilder,
    $$RecurringExpensesTableUpdateCompanionBuilder,
    (RecurringExpense, $$RecurringExpensesTableReferences),
    RecurringExpense,
    PrefetchHooks Function(
        {bool categoryId, bool paymentMethodId, bool expensesRefs})> {
  $$RecurringExpensesTableTableManager(
      _$LocalDatabase db, $RecurringExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringExpensesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<int?> paymentMethodId = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime> nextRunDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              RecurringExpensesCompanion(
            id: id,
            name: name,
            amount: amount,
            categoryId: categoryId,
            paymentMethodId: paymentMethodId,
            detail: detail,
            frequency: frequency,
            interval: interval,
            startDate: startDate,
            endDate: endDate,
            nextRunDate: nextRunDate,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int amount,
            Value<int?> categoryId = const Value.absent(),
            Value<int?> paymentMethodId = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            required String frequency,
            Value<int> interval = const Value.absent(),
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            required DateTime nextRunDate,
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              RecurringExpensesCompanion.insert(
            id: id,
            name: name,
            amount: amount,
            categoryId: categoryId,
            paymentMethodId: paymentMethodId,
            detail: detail,
            frequency: frequency,
            interval: interval,
            startDate: startDate,
            endDate: endDate,
            nextRunDate: nextRunDate,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringExpensesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              paymentMethodId = false,
              expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
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
                        $$RecurringExpensesTableReferences._categoryIdTable(db),
                    referencedColumn: $$RecurringExpensesTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (paymentMethodId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paymentMethodId,
                    referencedTable: $$RecurringExpensesTableReferences
                        ._paymentMethodIdTable(db),
                    referencedColumn: $$RecurringExpensesTableReferences
                        ._paymentMethodIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RecurringExpensesTableReferences
                            ._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringExpensesTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.recurringExpenseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RecurringExpensesTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $RecurringExpensesTable,
    RecurringExpense,
    $$RecurringExpensesTableFilterComposer,
    $$RecurringExpensesTableOrderingComposer,
    $$RecurringExpensesTableAnnotationComposer,
    $$RecurringExpensesTableCreateCompanionBuilder,
    $$RecurringExpensesTableUpdateCompanionBuilder,
    (RecurringExpense, $$RecurringExpensesTableReferences),
    RecurringExpense,
    PrefetchHooks Function(
        {bool categoryId, bool paymentMethodId, bool expensesRefs})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<int?> categoryId,
  required String expenseName,
  required int expense,
  required DateTime expenseDate,
  Value<String?> expenseDetail,
  Value<int?> paymentMethodId,
  Value<int?> recurringExpenseId,
  Value<DateTime?> recurringOccurrenceDate,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<int?> categoryId,
  Value<String> expenseName,
  Value<int> expense,
  Value<DateTime> expenseDate,
  Value<String?> expenseDetail,
  Value<int?> paymentMethodId,
  Value<int?> recurringExpenseId,
  Value<DateTime?> recurringOccurrenceDate,
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

  static $PaymentMethodsTable _paymentMethodIdTable(_$LocalDatabase db) =>
      db.paymentMethods.createAlias($_aliasNameGenerator(
          db.expenses.paymentMethodId, db.paymentMethods.id));

  $$PaymentMethodsTableProcessedTableManager? get paymentMethodId {
    if ($_item.paymentMethodId == null) return null;
    final manager = $$PaymentMethodsTableTableManager($_db, $_db.paymentMethods)
        .filter((f) => f.id($_item.paymentMethodId!));
    final item = $_typedResult.readTableOrNull(_paymentMethodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $RecurringExpensesTable _recurringExpenseIdTable(_$LocalDatabase db) =>
      db.recurringExpenses.createAlias($_aliasNameGenerator(
          db.expenses.recurringExpenseId, db.recurringExpenses.id));

  $$RecurringExpensesTableProcessedTableManager? get recurringExpenseId {
    if ($_item.recurringExpenseId == null) return null;
    final manager =
        $$RecurringExpensesTableTableManager($_db, $_db.recurringExpenses)
            .filter((f) => f.id($_item.recurringExpenseId!));
    final item = $_typedResult.readTableOrNull(_recurringExpenseIdTable($_db));
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

  ColumnFilters<DateTime> get recurringOccurrenceDate => $composableBuilder(
      column: $table.recurringOccurrenceDate,
      builder: (column) => ColumnFilters(column));

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

  $$PaymentMethodsTableFilterComposer get paymentMethodId {
    final $$PaymentMethodsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentMethodId,
        referencedTable: $db.paymentMethods,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentMethodsTableFilterComposer(
              $db: $db,
              $table: $db.paymentMethods,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringExpensesTableFilterComposer get recurringExpenseId {
    final $$RecurringExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurringExpenseId,
        referencedTable: $db.recurringExpenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringExpensesTableFilterComposer(
              $db: $db,
              $table: $db.recurringExpenses,
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

  ColumnOrderings<DateTime> get recurringOccurrenceDate => $composableBuilder(
      column: $table.recurringOccurrenceDate,
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

  $$PaymentMethodsTableOrderingComposer get paymentMethodId {
    final $$PaymentMethodsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentMethodId,
        referencedTable: $db.paymentMethods,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentMethodsTableOrderingComposer(
              $db: $db,
              $table: $db.paymentMethods,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringExpensesTableOrderingComposer get recurringExpenseId {
    final $$RecurringExpensesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurringExpenseId,
        referencedTable: $db.recurringExpenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringExpensesTableOrderingComposer(
              $db: $db,
              $table: $db.recurringExpenses,
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

  GeneratedColumn<DateTime> get recurringOccurrenceDate => $composableBuilder(
      column: $table.recurringOccurrenceDate, builder: (column) => column);

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

  $$PaymentMethodsTableAnnotationComposer get paymentMethodId {
    final $$PaymentMethodsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentMethodId,
        referencedTable: $db.paymentMethods,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentMethodsTableAnnotationComposer(
              $db: $db,
              $table: $db.paymentMethods,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringExpensesTableAnnotationComposer get recurringExpenseId {
    final $$RecurringExpensesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.recurringExpenseId,
            referencedTable: $db.recurringExpenses,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringExpensesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringExpenses,
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
    PrefetchHooks Function(
        {bool categoryId, bool paymentMethodId, bool recurringExpenseId})> {
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
            Value<int?> paymentMethodId = const Value.absent(),
            Value<int?> recurringExpenseId = const Value.absent(),
            Value<DateTime?> recurringOccurrenceDate = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            categoryId: categoryId,
            expenseName: expenseName,
            expense: expense,
            expenseDate: expenseDate,
            expenseDetail: expenseDetail,
            paymentMethodId: paymentMethodId,
            recurringExpenseId: recurringExpenseId,
            recurringOccurrenceDate: recurringOccurrenceDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required String expenseName,
            required int expense,
            required DateTime expenseDate,
            Value<String?> expenseDetail = const Value.absent(),
            Value<int?> paymentMethodId = const Value.absent(),
            Value<int?> recurringExpenseId = const Value.absent(),
            Value<DateTime?> recurringOccurrenceDate = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            categoryId: categoryId,
            expenseName: expenseName,
            expense: expense,
            expenseDate: expenseDate,
            expenseDetail: expenseDetail,
            paymentMethodId: paymentMethodId,
            recurringExpenseId: recurringExpenseId,
            recurringOccurrenceDate: recurringOccurrenceDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              paymentMethodId = false,
              recurringExpenseId = false}) {
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
                if (paymentMethodId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paymentMethodId,
                    referencedTable:
                        $$ExpensesTableReferences._paymentMethodIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._paymentMethodIdTable(db).id,
                  ) as T;
                }
                if (recurringExpenseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recurringExpenseId,
                    referencedTable:
                        $$ExpensesTableReferences._recurringExpenseIdTable(db),
                    referencedColumn: $$ExpensesTableReferences
                        ._recurringExpenseIdTable(db)
                        .id,
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
    PrefetchHooks Function(
        {bool categoryId, bool paymentMethodId, bool recurringExpenseId})>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CategoryTableTableManager get category =>
      $$CategoryTableTableManager(_db, _db.category);
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(_db, _db.paymentMethods);
  $$RecurringExpensesTableTableManager get recurringExpenses =>
      $$RecurringExpensesTableTableManager(_db, _db.recurringExpenses);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
}
