import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:expense_diary/model/category.dart';
import 'package:expense_diary/model/category_expense.dart';
import 'package:expense_diary/model/expense.dart';
import 'package:expense_diary/model/payment_method_expense.dart';
import 'package:expense_diary/model/payment_method.dart';
import 'package:expense_diary/model/recurring_expense.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';

@DriftDatabase(tables: [Expenses, Category, PaymentMethods, RecurringExpenses])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  // ── Expense ──────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> watchExpense(DateTime selectedDate) {
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final end = start.add(const Duration(days: 1));
    final query =
        select(expenses).join([
            leftOuterJoin(category, category.id.equalsExp(expenses.categoryId)),
            leftOuterJoin(
              paymentMethods,
              paymentMethods.id.equalsExp(expenses.paymentMethodId),
            ),
          ])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end),
          )
          ..orderBy([
            OrderingTerm.asc(expenses.expenseDate),
            OrderingTerm.asc(expenses.id),
          ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return {
          'expenses': row.readTable(expenses),
          'category': row.readTableOrNull(category),
          'paymentMethod': row.readTableOrNull(paymentMethods),
        };
      }).toList();
    });
  }

  Stream<int> selectDayExpense(DateTime selectedDate) {
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final end = start.add(const Duration(days: 1));
    final totalExpense = expenses.expense.sum();
    final query =
        selectOnly(expenses)
          ..addColumns([totalExpense])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end),
          );
    return query.watchSingle().map((row) => row.read(totalExpense) ?? 0);
  }

  Stream<int> selectMonthExpense(DateTime selectedDate) {
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final totalExpense = expenses.expense.sum();
    final query =
        selectOnly(expenses)
          ..addColumns([totalExpense])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end),
          );
    return query.watchSingle().map((row) => row.read(totalExpense) ?? 0);
  }

  Stream<Map<DateTime, int>> watchDailyExpenseTotals(DateTime selectedDate) {
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final query = select(expenses)..where(
      (t) =>
          t.expenseDate.isBiggerOrEqualValue(start) &
          t.expenseDate.isSmallerThanValue(end),
    );

    return query.watch().map((rows) {
      final result = <DateTime, int>{};
      for (final expense in rows) {
        final date = expense.expenseDate;
        final dayKey = DateTime(date.year, date.month, date.day);
        result[dayKey] = (result[dayKey] ?? 0) + expense.expense;
      }
      return result;
    });
  }

  Stream<int> selectWeekExpense(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));
    final totalExpense = expenses.expense.sum();
    final query =
        selectOnly(expenses)
          ..addColumns([totalExpense])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end),
          );
    return query.watchSingle().map((row) => row.read(totalExpense) ?? 0);
  }

  Stream<int> countMonthExpenses(DateTime selectedDate) {
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final count = expenses.id.count();
    final query =
        selectOnly(expenses)
          ..addColumns([count])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end),
          );
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Stream<List<PaymentMethodExpense>> watchMonthlyPaymentMethodExpense(
    DateTime selectedDate,
  ) {
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 1);

    final query =
        selectOnly(expenses).join([
            leftOuterJoin(
              paymentMethods,
              paymentMethods.id.equalsExp(expenses.paymentMethodId),
            ),
          ])
          ..addColumns([
            paymentMethods.name,
            expenses.expense.sum(),
            expenses.paymentMethodId,
          ])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end),
          )
          ..groupBy([expenses.paymentMethodId]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PaymentMethodExpense(
          name: row.read<String>(paymentMethods.name) ?? '',
          total: row.read<int>(expenses.expense.sum()) ?? 0,
          paymentMethodId: row.read<int>(expenses.paymentMethodId),
        );
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> watchMonthExpensesByPaymentMethod(
    DateTime selectedDate,
    int? paymentMethodId,
  ) {
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 1);

    final query =
        select(expenses).join([
            leftOuterJoin(category, category.id.equalsExp(expenses.categoryId)),
          ])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end) &
                (paymentMethodId != null
                    ? expenses.paymentMethodId.equals(paymentMethodId)
                    : expenses.paymentMethodId.isNull()),
          )
          ..orderBy([OrderingTerm.desc(expenses.expenseDate)]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => {
              'expense': row.readTable(expenses),
              'category': row.readTableOrNull(category),
            },
          )
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> watchMonthExpensesByCategory(
    DateTime selectedDate,
    int? categoryId,
  ) {
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 1);

    final query =
        select(expenses).join([
            leftOuterJoin(
              paymentMethods,
              paymentMethods.id.equalsExp(expenses.paymentMethodId),
            ),
          ])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end) &
                (categoryId != null
                    ? expenses.categoryId.equals(categoryId)
                    : expenses.categoryId.isNull()),
          )
          ..orderBy([OrderingTerm.desc(expenses.expenseDate)]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => {
              'expense': row.readTable(expenses),
              'paymentMethod': row.readTableOrNull(paymentMethods),
            },
          )
          .toList();
    });
  }

  Stream<List<CategoryExpense>> watchMonthlyCategoryExpense(
    DateTime selectedDate,
  ) {
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final query =
        selectOnly(expenses).join([
            leftOuterJoin(category, category.id.equalsExp(expenses.categoryId)),
          ])
          ..addColumns([
            category.categoryName,
            expenses.expense.sum(),
            expenses.categoryId,
          ])
          ..where(
            expenses.expenseDate.isBiggerOrEqualValue(start) &
                expenses.expenseDate.isSmallerThanValue(end),
          )
          ..groupBy([expenses.categoryId]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return CategoryExpense(
          categoryId: row.read<int>(expenses.categoryId),
          category: row.read<String>(category.categoryName) ?? '',
          total: row.read<int>(expenses.expense.sum()) ?? 0,
        );
      }).toList();
    });
  }

  Future<int> createExpense(ExpensesCompanion data) =>
      into(expenses).insert(data);

  Future<int> updateExpense(ExpensesCompanion data) =>
      (update(expenses)..where((t) => t.id.equals(data.id.value))).write(data);

  Future<int> removeExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();

  // ── Category ─────────────────────────────────────────────────────────────

  Future<int> addCategory(CategoryCompanion data) =>
      into(category).insert(data);

  Stream<List<CategoryData>> watchCategory(String? keyword) {
    if (keyword != null && keyword.isNotEmpty) {
      return (select(category)
        ..where((t) => t.categoryName.like('%$keyword%'))).watch();
    }
    return select(category).watch();
  }

  Future<int> updateCategory(CategoryCompanion data) =>
      (update(category)..where((t) => t.id.equals(data.id.value))).write(data);

  Future<int> deleteCategory(int id) =>
      (delete(category)..where((t) => t.id.equals(id))).go();

  Future<void> deleteCategoryAndUnassignExpenses(int categoryId) async {
    await transaction(() async {
      await (update(expenses)..where(
        (t) => t.categoryId.equals(categoryId),
      )).write(const ExpensesCompanion(categoryId: Value(null)));
      await deleteCategory(categoryId);
    });
  }

  Future<int> countExpensesByCategory(int categoryId) async {
    final countExpense = expenses.id.count();
    final query =
        selectOnly(expenses)
          ..addColumns([countExpense])
          ..where(expenses.categoryId.equals(categoryId));
    final result = await query.getSingle();
    return result.read(countExpense) ?? 0;
  }

  // ── PaymentMethod ─────────────────────────────────────────────────────────

  Stream<List<PaymentMethod>> watchPaymentMethods() {
    return (select(paymentMethods)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<PaymentMethod>> getPaymentMethods() {
    return (select(paymentMethods)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<int> createPaymentMethod(PaymentMethodsCompanion data) =>
      into(paymentMethods).insert(data);

  Future<PaymentMethod?> findPaymentMethodByTypeAndName({
    required String type,
    required String name,
    required bool isArchived,
    int? excludeId,
  }) async {
    final normalizedName = name.trim();
    final rows =
        await (select(paymentMethods)
              ..where(
                (t) =>
                    t.type.equals(type) &
                    t.name.equals(normalizedName) &
                    t.isArchived.equals(isArchived) &
                    (excludeId == null
                        ? const Constant(true)
                        : t.id.equals(excludeId).not()),
              )
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updatePaymentMethod(PaymentMethodsCompanion data) =>
      (update(paymentMethods)
        ..where((t) => t.id.equals(data.id.value))).write(data);

  Future<PaymentMethod> restorePaymentMethod(
    PaymentMethod method, {
    required String memo,
    required int sortOrder,
  }) async {
    final now = DateTime.now();
    await (update(paymentMethods)..where((t) => t.id.equals(method.id))).write(
      PaymentMethodsCompanion(
        memo: Value(memo.trim().isEmpty ? null : memo.trim()),
        sortOrder: Value(sortOrder),
        isArchived: const Value(false),
        updatedAt: Value(now),
      ),
    );
    return PaymentMethod(
      id: method.id,
      type: method.type,
      name: method.name,
      memo: memo.trim().isEmpty ? null : memo.trim(),
      sortOrder: sortOrder,
      isArchived: false,
      createdAt: method.createdAt,
      updatedAt: now,
    );
  }

  Future<void> archivePaymentMethod(int id) async {
    await (update(paymentMethods)..where((t) => t.id.equals(id))).write(
      PaymentMethodsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> reorderPaymentMethods(List<int> orderedIds) async {
    await transaction(() async {
      for (int i = 0; i < orderedIds.length; i++) {
        await (update(paymentMethods)
          ..where((t) => t.id.equals(orderedIds[i]))).write(
          PaymentMethodsCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  Future<int> countExpensesByPaymentMethod(int paymentMethodId) async {
    final countExpense = expenses.id.count();
    final query =
        selectOnly(expenses)
          ..addColumns([countExpense])
          ..where(expenses.paymentMethodId.equals(paymentMethodId));
    final result = await query.getSingle();
    return result.read(countExpense) ?? 0;
  }

  // ── RecurringExpense ──────────────────────────────────────────────────────

  Stream<List<RecurringExpense>> watchRecurringExpenses() {
    return (select(recurringExpenses)..orderBy([
      (t) => OrderingTerm(expression: t.isActive, mode: OrderingMode.desc),
      (t) => OrderingTerm.asc(t.createdAt),
    ])).watch();
  }

  Future<List<RecurringExpense>> getActiveRecurringExpenses() {
    return (select(recurringExpenses)
      ..where((t) => t.isActive.equals(true))).get();
  }

  Future<int> countActiveRecurringExpenses() async {
    final count = recurringExpenses.id.count();
    final query =
        selectOnly(recurringExpenses)
          ..addColumns([count])
          ..where(recurringExpenses.isActive.equals(true));
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<int> createRecurringExpense(RecurringExpensesCompanion data) =>
      into(recurringExpenses).insert(data);

  Future<int> updateRecurringExpense(RecurringExpensesCompanion data) =>
      (update(recurringExpenses)
        ..where((t) => t.id.equals(data.id.value))).write(data);

  Future<void> deactivateRecurringExpense(int id) async {
    await (update(recurringExpenses)..where((t) => t.id.equals(id))).write(
      RecurringExpensesCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteRecurringExpense(int id) =>
      (delete(recurringExpenses)..where((t) => t.id.equals(id))).go();

  Future<bool> recurringExpenseOccurrenceExists(
    int recurringExpenseId,
    DateTime occurrenceDate,
  ) async {
    final query = select(expenses)..where(
      (t) =>
          t.recurringExpenseId.equals(recurringExpenseId) &
          t.recurringOccurrenceDate.equals(occurrenceDate),
    );
    final result = await query.get();
    return result.isNotEmpty;
  }

  // ── Misc ─────────────────────────────────────────────────────────────────

  Future<void> deleteAllData() async {
    await transaction(() async {
      await delete(expenses).go();
      await delete(recurringExpenses).go();
      await delete(category).go();
      await delete(paymentMethods).go();
    });
  }

  // ── Schema ────────────────────────────────────────────────────────────────

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(expenses, expenses.paymentMethodId);
        await m.addColumn(expenses, expenses.recurringExpenseId);
        await m.addColumn(expenses, expenses.recurringOccurrenceDate);
        await m.createTable(paymentMethods);
        await m.createTable(recurringExpenses);
      }
      if (from < 3) {
        await m.addColumn(category, category.usePresetAmount);
        await m.addColumn(category, category.presetAmount);
        await m.addColumn(category, category.autoFillExpenseName);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
