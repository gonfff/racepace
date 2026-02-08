import 'package:racepace/domain/splits/splits_preset.dart';

abstract class SplitsPresetsRepository {
  Future<List<SplitsPreset>> loadPresets();
  Future<void> savePreset(SplitsPreset preset);
  Future<void> deletePreset(int id);
}
