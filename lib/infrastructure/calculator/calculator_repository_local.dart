import 'package:drift/drift.dart';
import 'package:racepace/application/calculator/calculator_repository.dart';
import 'package:racepace/domain/calculator/calculation.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/infrastructure/database/app_database.dart' as db;

class CalculatorRepositoryLocal implements CalculatorRepository {
  CalculatorRepositoryLocal(this._database);

  final db.AppDatabase _database;

  @override
  Future<List<Calculation>> loadCalculations() async {
    final rows =
        await (_database.select(_database.calculations)..orderBy([
              (table) => OrderingTerm.desc(table.createdAt),
              (table) => OrderingTerm.desc(table.id),
            ]))
            .get();
    return rows
        .map(
          (row) => Calculation(
            id: row.id,
            distance: row.distance,
            pace: Duration(seconds: row.paceSeconds),
            time: Duration(seconds: row.timeSeconds),
            unit: UnitStorage.fromCode(row.unit),
            createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
          ),
        )
        .toList();
  }

  @override
  Future<Calculation> addCalculation(CalculationDraft draft) async {
    final id = await _database
        .into(_database.calculations)
        .insert(
          db.CalculationsCompanion.insert(
            distance: draft.distance,
            paceSeconds: draft.pace.inSeconds,
            timeSeconds: draft.time.inSeconds,
            unit: draft.unit.code,
            createdAt: draft.createdAt.millisecondsSinceEpoch,
          ),
        );
    return Calculation(
      id: id,
      distance: draft.distance,
      pace: draft.pace,
      time: draft.time,
      unit: draft.unit,
      createdAt: draft.createdAt,
    );
  }

  @override
  Future<void> deleteCalculation(int id) async {
    await (_database.delete(
      _database.calculations,
    )..where((table) => table.id.equals(id))).go();
  }
}
