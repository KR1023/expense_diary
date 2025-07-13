import 'package:drift/drift.dart';
import 'package:expense_diary/model/category_expense.dart';
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
  ]
)

class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(): super(_openConnection());

  Stream<List<Expense>> watchExpense(DateTime selectedDate) => (
      select(expenses)
        ..where ((t) => t.expenseDate.equals(selectedDate))
  ).watch();

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
      ..addColumns([expenses.category, expenses.expense.sum()])
      ..where(expenses.expenseDate.isBetweenValues(start, end))
      ..groupBy([expenses.category]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return CategoryExpense(
          category: row.read<String>(expenses.category) ?? '미분류',
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
          category: Value(data.category),
          expenseDetail: Value(data.expenseDetail)
        ));

  Future<int> removeExpense(int id) => (delete(expenses)..where((t) => t.id.equals(id))).go();

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