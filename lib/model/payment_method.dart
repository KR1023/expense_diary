import 'package:drift/drift.dart';

class PaymentMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // cash | card | bank | mobilePay | other
  TextColumn get name => text()();
  TextColumn get memo => text().nullable()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
