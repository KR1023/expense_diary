import 'package:drift/drift.dart';
import 'package:expense_diary/model/category_expense.dart';
import 'package:expense_diary/model/category.dart';
import 'package:expense_diary/model/expense.dart';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Expenses,
    Category
  ]
)

class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(): super(_openConnection());

  // Expense
  Stream<List<Map<String, dynamic>>> watchExpense(DateTime selectedDate) {
    final query = select(expenses)
      .join([
        leftOuterJoin(category, category.id.equalsExp(expenses.categoryId))
      ])
      ..where(expenses.expenseDate.equals(selectedDate));

    return query.watch().map((rows) {
      return rows.map((row) {
        final expense = row.readTable(expenses);
        final cat = row.readTableOrNull(category);
        return {
          'expenses': expense,
          'category': cat
        };
      }).toList();
    });
  }

  Stream<int> selectMonthExpense(DateTime selectedDate){
    int selectedMonth = selectedDate.month;
    final totalExpense = expenses.expense.sum();
    final query = selectOnly(expenses)
      ..addColumns([totalExpense])
      ..where(expenses.expenseDate.month.equals(selectedMonth));

    return query.watchSingle().map((row) => row.read(totalExpense) ?? 0);
  }

  Stream<int> selectWeekExpense(DateTime startDate, DateTime endDate) {
    final totalExpense = expenses.expense.sum();
    final query = selectOnly(expenses)
      ..addColumns([totalExpense])
      ..where(expenses.expenseDate.isBetweenValues(startDate, endDate));

    return query.watchSingle().map((row) => row.read(totalExpense) ?? 0);
  }

  Stream<List<CategoryExpense>> watchMonthlyCategoryExpense(DateTime selectedDate) {
    final start = DateTime(selectedDate.year, selectedDate.month, 1);
    final end = DateTime(selectedDate.year, selectedDate.month + 1, 1);

    final query = selectOnly(expenses)
    .join([
      leftOuterJoin(category, category.id.equalsExp(expenses.categoryId))
    ])
      ..addColumns([category.categoryName, expenses.expense.sum()])
      ..where(expenses.expenseDate.isBetweenValues(start, end))
      ..groupBy([expenses.categoryId]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return CategoryExpense(
          category: row.read<String>(category.categoryName) ?? '미분류',
          total: row.read<int>(expenses.expense.sum()) ?? 0,
        );
      }).toList();
    });
  }

  Future<int> createExpense(ExpensesCompanion data) => into(expenses).insert(data);

  Future<int> updateExpense(Expense data) =>
      (update(expenses)..where(
        (t) => t.id.equals(data.id)
      )).write(
        ExpensesCompanion(
          expenseName: Value(data.expenseName),
          expenseDate: Value(data.expenseDate),
          expense: Value(data.expense),
          categoryId: Value(data.categoryId != null ? data.categoryId : null),
          expenseDetail: Value(data.expenseDetail)
        ));

  Future<int> removeExpense(int id) => (delete(expenses)..where((t) => t.id.equals(id))).go();

  // Category
  Future<int> addCategory(CategoryCompanion data) => into(category).insert(data);

  Stream<List<CategoryData>> watchCategory(String? keyword){
      if(keyword != null && keyword != '') {
        return
          (select(category)
            ..where((t) => t.categoryName.like('%$keyword%'))
          ).watch();
      } else {
        return (select(category).watch());
      }
  }

  Future<int> updateCategory(CategoryData data) =>
      (update(category)..where(
          (t) => t.id.equals(data.id)
      )).write(
        CategoryCompanion(
          categoryName: Value(data.categoryName)
      ));

  Future<int> deleteCategory(int id) => (delete(category)..where((t) => t.id.equals(id))).go();

  Future<int> countExpensesByCategory(int categoryId) async {
    final countExpense = expenses.id.count();
    final query = selectOnly(expenses)
      ..addColumns([countExpense])
      ..where(expenses.categoryId.equals(categoryId));

    final result = await query.getSingle();
    return result.read(countExpense) ?? 0;
  }

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}