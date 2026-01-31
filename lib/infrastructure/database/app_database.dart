import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class Calculations extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get distance => real()();
  IntColumn get paceSeconds => integer()();
  IntColumn get timeSeconds => integer()();
  TextColumn get unit => text()();
  IntColumn get createdAt => integer()();
}

@DriftDatabase(tables: [Settings, Calculations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(calculations);
      }
    },
  );

  Future<String?> getSetting(String key) async {
    final row = await (select(
      settings,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(key: Value(key), value: Value(value)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, 'racepace.sqlite'));
    return NativeDatabase(file);
  });
}
