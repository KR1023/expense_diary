import 'package:drift/drift.dart';
import 'package:expense_diary/model/category.dart';
import 'package:expense_diary/model/payment_method.dart';
import 'package:expense_diary/model/recurring_expense.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Category, #id).nullable()();
  TextColumn get expenseName => text()();
  IntColumn get expense => integer()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get expenseDetail => text().nullable()();
  IntColumn get paymentMethodId =>
      integer().references(PaymentMethods, #id).nullable()();
  IntColumn get recurringExpenseId =>
      integer().references(RecurringExpenses, #id).nullable()();
  DateTimeColumn get recurringOccurrenceDate => dateTime().nullable()();
}
