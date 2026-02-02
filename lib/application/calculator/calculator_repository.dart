import 'package:racepace/domain/calculator/calculation.dart';

abstract class CalculatorRepository {
  Future<List<Calculation>> loadCalculations();
  Future<Calculation> addCalculation(CalculationDraft draft);
  Future<void> deleteCalculation(int id);
}
