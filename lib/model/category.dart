import 'package:drift/drift.dart';

class Category extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get categoryName => text()();
  BoolColumn get usePresetAmount =>
      boolean().withDefault(const Constant(false))();
  IntColumn get presetAmount => integer().nullable()();
  BoolColumn get autoFillExpenseName =>
      boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {categoryName},
  ];
}
