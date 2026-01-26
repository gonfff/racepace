import 'package:flutter/widgets.dart';
import 'package:pacenote/application/settings/settings_service.dart';
import 'package:pacenote/infrastructure/database/app_database.dart';
import 'package:pacenote/infrastructure/settings/settings_repository_local.dart';
import 'package:pacenote/presentation/app/pacenote_app.dart';
import 'package:pacenote/presentation/features/settings/settings_notifier.dart';

Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final repository = SettingsRepositoryLocal(database);
  final service = SettingsService(repository);
  final notifier = SettingsNotifier(service);
  await notifier.load();

  return _AppBootstrap(database: database, settingsNotifier: notifier);
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap({required this.database, required this.settingsNotifier});

  final AppDatabase database;
  final SettingsNotifier settingsNotifier;

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
    return PacenoteApp(settingsNotifier: widget.settingsNotifier);
  }
}
