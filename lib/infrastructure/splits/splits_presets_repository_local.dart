import 'dart:convert';

import 'package:racepace/application/splits/splits_presets_repository.dart';
import 'package:racepace/domain/splits/splits_preset.dart';
import 'package:racepace/infrastructure/database/app_database.dart';

class _SplitsPresetStorageKeys {
  static const String presets = 'splits_presets';
}

class SplitsPresetsRepositoryLocal implements SplitsPresetsRepository {
  SplitsPresetsRepositoryLocal(this._database);

  final AppDatabase _database;

  @override
  Future<List<SplitsPreset>> loadPresets() async {
    final raw = await _database.getSetting(_SplitsPresetStorageKeys.presets);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((json) => SplitsPreset.fromJson(json.cast<String, Object?>()))
        .whereType<SplitsPreset>()
        .toList(growable: false);
  }

  @override
  Future<void> savePreset(SplitsPreset preset) async {
    final presets = await loadPresets();
    final existing = presets.firstWhere(
      (item) =>
          item.intervalCode == preset.intervalCode &&
          item.strategyPercent == preset.strategyPercent,
      orElse: () => preset,
    );
    final updated = [
      existing,
      ...presets.where((item) => item.id != existing.id),
    ];
    await _persist(updated);
  }

  @override
  Future<void> deletePreset(int id) async {
    final presets = await loadPresets();
    final updated = presets.where((item) => item.id != id).toList();
    await _persist(updated);
  }

  Future<void> _persist(List<SplitsPreset> presets) async {
    final encoded = jsonEncode(
      presets.map((preset) => preset.toJson()).toList(growable: false),
    );
    await _database.setSetting(_SplitsPresetStorageKeys.presets, encoded);
  }
}
