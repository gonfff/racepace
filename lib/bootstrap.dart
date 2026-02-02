import 'package:flutter/widgets.dart';
import 'package:racepace/application/calculator/calculator_service.dart';
import 'package:racepace/application/settings/settings_service.dart';
import 'package:racepace/infrastructure/calculator/calculator_repository_local.dart';
import 'package:racepace/infrastructure/database/app_database.dart';
import 'package:racepace/infrastructure/settings/settings_repository_local.dart';
import 'package:racepace/presentation/app/racepace_app.dart';
import 'package:racepace/presentation/features/settings/settings_notifier.dart';

Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final repository = SettingsRepositoryLocal(database);
  final service = SettingsService(repository);
  final notifier = SettingsNotifier(service);
  final calculatorRepository = CalculatorRepositoryLocal(database);
  final calculatorService = CalculatorService(calculatorRepository);
  await notifier.load();

  return _AppBootstrap(
    database: database,
    settingsNotifier: notifier,
    calculatorService: calculatorService,
  );
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap({
    required this.database,
    required this.settingsNotifier,
    required this.calculatorService,
  });

  final AppDatabase database;
  final SettingsNotifier settingsNotifier;
  final CalculatorService calculatorService;

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  @override
  void dispose() {
    widget.settingsNotifier.dispose();
    widget.database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RacepaceApp(
      settingsNotifier: widget.settingsNotifier,
      calculatorService: widget.calculatorService,
    );
  }
}
