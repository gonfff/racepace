import 'package:pacenote/application/calculator/calculator_repository.dart';
import 'package:pacenote/domain/calculator/calculation.dart';

class CalculatorService {
  CalculatorService(this._repository);

  final CalculatorRepository _repository;

  Future<List<Calculation>> loadCalculations() =>
      _repository.loadCalculations();

  Future<Calculation> addCalculation(CalculationDraft draft) =>
      _repository.addCalculation(draft);

  Future<void> deleteCalculation(int id) => _repository.deleteCalculation(id);
}
