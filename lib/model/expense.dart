import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().nullable()();
  TextColumn get expenseName => text()();
  IntColumn get expense => integer()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get expenseDetail => text().nullable()();

}