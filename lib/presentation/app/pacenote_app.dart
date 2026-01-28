import 'package:flutter/cupertino.dart';
import 'package:pacenote/domain/settings/app_settings.dart';
import 'package:pacenote/application/calculator/calculator_service.dart';
import 'package:pacenote/presentation/app/app_root.dart';
import 'package:pacenote/presentation/app/calculator_scope.dart';
import 'package:pacenote/presentation/app/settings_scope.dart';
import 'package:pacenote/presentation/features/settings/settings_notifier.dart';
import 'package:pacenote/presentation/l10n/app_localizations.dart';

class PacenoteApp extends StatelessWidget {
  const PacenoteApp({
    required this.settingsNotifier,
    required this.calculatorService,
    super.key,
  });

  final SettingsNotifier settingsNotifier;
  final CalculatorService calculatorService;

  @override
  Widget build(BuildContext context) {
    return CalculatorScope(
      service: calculatorService,
      child: SettingsScope(
        controller: settingsNotifier,
        child: ListenableBuilder(
          listenable: settingsNotifier,
          builder: (context, _) {
            final settings = settingsNotifier.settings;
            final locale = switch (settings.language) {
              AppLanguage.system => null,
              _ => Locale(settings.language.code),
            };
            return CupertinoApp(
              debugShowCheckedModeBanner: false,
              title: 'Pacenote',
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              theme: CupertinoThemeData(
                brightness: _brightnessFor(settings.theme),
              ),
              home: const AppRoot(),
            );
          },
        ),
      ),
    );
  }
}

Brightness? _brightnessFor(AppThemeMode theme) {
  switch (theme) {
    case AppThemeMode.light:
      return Brightness.light;
    case AppThemeMode.dark:
      return Brightness.dark;
    case AppThemeMode.system:
      return null;
  }
}
