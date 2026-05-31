import 'package:drift/drift.dart';
import 'package:expense_diary/model/category.dart';
import 'package:expense_diary/model/payment_method.dart';

class RecurringExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get amount => integer()();
  IntColumn get categoryId =>
      integer().references(Category, #id).nullable()();
  IntColumn get paymentMethodId =>
      integer().references(PaymentMethods, #id).nullable()();
  TextColumn get detail => text().nullable()();
  // daily | weekly | monthly | yearly
  TextColumn get frequency => text()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get nextRunDate => dateTime()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
