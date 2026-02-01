import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/application/calculator/calculator_repository.dart';
import 'package:racepace/application/calculator/calculator_service.dart';
import 'package:racepace/domain/calculator/calculation.dart';
import 'package:racepace/domain/settings/app_settings.dart';

void main() {
  test('CalculatorService delegates to repository', () async {
    final repository = _FakeCalculatorRepository();
    final service = CalculatorService(repository);

    final loaded = await service.loadCalculations();
    expect(loaded, repository.loadReturn);
    expect(repository.loadCalls, 1);

    final draft = CalculationDraft(
      distance: 5.0,
      pace: const Duration(minutes: 5),
      time: const Duration(minutes: 25),
      unit: Unit.kilometers,
      createdAt: DateTime(2024, 1, 1),
    );
    final added = await service.addCalculation(draft);
    expect(added, repository.addReturn);
    expect(repository.addCalls, 1);
    expect(repository.lastDraft, draft);

    await service.deleteCalculation(7);
    expect(repository.deleteCalls, 1);
    expect(repository.lastDeletedId, 7);
  });
}

class _FakeCalculatorRepository implements CalculatorRepository {
  int loadCalls = 0;
  int addCalls = 0;
  int deleteCalls = 0;
  int? lastDeletedId;
  CalculationDraft? lastDraft;

  final loadReturn = <Calculation>[
    Calculation(
      id: 1,
      distance: 10,
      pace: const Duration(minutes: 5),
      time: const Duration(minutes: 50),
      unit: Unit.kilometers,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  final addReturn = Calculation(
    id: 2,
    distance: 5,
    pace: const Duration(minutes: 4),
    time: const Duration(minutes: 20),
    unit: Unit.kilometers,
    createdAt: DateTime(2024, 1, 2),
  );

  @override
  Future<List<Calculation>> loadCalculations() async {
    loadCalls += 1;
    return loadReturn;
  }

  @override
  Future<Calculation> addCalculation(CalculationDraft draft) async {
    addCalls += 1;
    lastDraft = draft;
    return addReturn;
  }

  @override
  Future<void> deleteCalculation(int id) async {
    deleteCalls += 1;
    lastDeletedId = id;
  }
}
