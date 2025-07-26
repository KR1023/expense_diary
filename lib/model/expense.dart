import 'package:drift/drift.dart';
import 'package:expense_diary/model/category.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  // TextColumn get category => text().nullable()();
  IntColumn get categoryId => integer().references(Category, #id).nullable()();
  TextColumn get expenseName => text()();
  IntColumn get expense => integer()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get expenseDetail => text().nullable()();

}