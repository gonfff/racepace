import 'package:racepace/application/splits/splits_presets_repository.dart';
import 'package:racepace/domain/splits/splits_preset.dart';

class SplitsPresetsService {
  SplitsPresetsService(this._repository);

  final SplitsPresetsRepository _repository;

  Future<List<SplitsPreset>> loadPresets() => _repository.loadPresets();

  Future<void> savePreset(SplitsPreset preset) =>
      _repository.savePreset(preset);

  Future<void> deletePreset(int id) => _repository.deletePreset(id);
}
