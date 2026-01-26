import 'package:flutter/cupertino.dart';
import 'package:pacenote/domain/settings/app_settings.dart';
import 'package:pacenote/presentation/app/settings_scope.dart';
import 'package:pacenote/presentation/core/design/app_theme.dart';
import 'package:pacenote/presentation/features/settings/about_screen.dart';
import 'package:pacenote/presentation/features/settings/support_screen.dart';
import 'package:pacenote/presentation/l10n/app_localizations.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsSheetContent();
  }
}

class _SettingsSheetContent extends StatefulWidget {
  const _SettingsSheetContent();

  @override
  State<_SettingsSheetContent> createState() => _SettingsSheetContentState();
}

class _SettingsSheetContentState extends State<_SettingsSheetContent> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScope.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final settings = controller.settings;
        final localizations = AppLocalizations.of(context);
        final unitLabel = switch (settings.unit) {
          Unit.kilometers => localizations.unitKilometers,
          Unit.miles => localizations.unitMiles,
        };
        final languageLabel = switch (settings.language) {
          AppLanguage.english => localizations.languageEnglish,
          AppLanguage.russian => localizations.languageRussian,
          AppLanguage.system => localizations.languageSystem,
        };
        final themeLabel = switch (settings.theme) {
          AppThemeMode.light => localizations.themeLight,
          AppThemeMode.dark => localizations.themeDark,
          AppThemeMode.system => localizations.themeSystem,
        };

        final mediaPadding = MediaQuery.paddingOf(context);

        final home = _SettingsHome(
          localizations: localizations,
          unitLabel: unitLabel,
          languageLabel: languageLabel,
          themeLabel: themeLabel,
          mediaPadding: mediaPadding,
          onClose: _closeSheet,
          onSelectUnit: _selectUnit,
          onSelectLanguage: _selectLanguage,
          onSelectTheme: _selectTheme,
          onOpenAbout: _openAbout,
          onOpenSupport: _openSupport,
        );

        return SafeArea(
          top: true,
          bottom: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBackgroundColor(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4.resolveFrom(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Navigator(
                        key: _navigatorKey,
                        onGenerateRoute: (settings) {
                          switch (settings.name) {
                            case '/about':
                              return CupertinoPageRoute<void>(
                                builder: (context) =>
                                    AboutScreen(onClose: _closeSheet),
                                settings: settings,
                              );
                            case '/support':
                              return CupertinoPageRoute<void>(
                                builder: (context) =>
                                    SupportScreen(onClose: _closeSheet),
                                settings: settings,
                              );
                            default:
                              return CupertinoPageRoute<void>(
                                builder: (context) => home,
                                settings: settings,
                              );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectUnit() async {
    final controller = SettingsScope.of(context);
    final localizations = AppLocalizations.of(context);
    final result = await showCupertinoModalPopup<Unit>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(localizations.settingsBaseUnit),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(Unit.kilometers),
            child: Text(localizations.unitKilometers),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(Unit.miles),
            child: Text(localizations.unitMiles),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.settingsClose),
        ),
      ),
    );
    if (result == null) return;
    await controller.updateUnit(result);
  }

  Future<void> _selectLanguage() async {
    final controller = SettingsScope.of(context);
    final localizations = AppLocalizations.of(context);
    final result = await showCupertinoModalPopup<AppLanguage>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(localizations.settingsLanguage),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(AppLanguage.system),
            child: Text(localizations.languageSystem),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(AppLanguage.english),
            child: Text(localizations.languageEnglish),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(AppLanguage.russian),
            child: Text(localizations.languageRussian),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.settingsClose),
        ),
      ),
    );
    if (result == null) return;
    await controller.updateLanguage(result);
  }

  Future<void> _selectTheme() async {
    final controller = SettingsScope.of(context);
    final localizations = AppLocalizations.of(context);
    final result = await showCupertinoModalPopup<AppThemeMode>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(localizations.settingsTheme),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(AppThemeMode.system),
            child: Text(localizations.themeSystem),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(AppThemeMode.light),
            child: Text(localizations.themeLight),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(AppThemeMode.dark),
            child: Text(localizations.themeDark),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.settingsClose),
        ),
      ),
    );
    if (result == null) return;
    await controller.updateTheme(result);
  }

  void _closeSheet() {
    Navigator.of(context).pop();
  }

  void _openAbout() {
    _navigatorKey.currentState?.pushNamed('/about');
  }

  void _openSupport() {
    _navigatorKey.currentState?.pushNamed('/support');
  }
}

class _SettingsHome extends StatelessWidget {
  const _SettingsHome({
    required this.localizations,
    required this.unitLabel,
    required this.languageLabel,
    required this.themeLabel,
    required this.mediaPadding,
    required this.onClose,
    required this.onSelectUnit,
    required this.onSelectLanguage,
    required this.onSelectTheme,
    required this.onOpenAbout,
    required this.onOpenSupport,
  });

  final AppLocalizations localizations;
  final String unitLabel;
  final String languageLabel;
  final String themeLabel;
  final EdgeInsets mediaPadding;
  final VoidCallback onClose;
  final VoidCallback onSelectUnit;
  final VoidCallback onSelectLanguage;
  final VoidCallback onSelectTheme;
  final VoidCallback onOpenAbout;
  final VoidCallback onOpenSupport;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.scaffoldBackgroundColor(context),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onClose,
          child: Text(localizations.settingsClose),
        ),
        middle: Text(localizations.settingsTitle),
      ),
      child: ListView(
        padding: EdgeInsets.only(bottom: 16 + mediaPadding.bottom),
        children: [
          CupertinoFormSection.insetGrouped(
            header: Text(localizations.settingsSectionGeneral),
            children: [
              _SettingsTile(
                label: localizations.settingsBaseUnit,
                value: unitLabel,
                onTap: onSelectUnit,
                showChevron: true,
              ),
              _SettingsTile(
                label: localizations.settingsLanguage,
                value: languageLabel,
                onTap: onSelectLanguage,
                showChevron: true,
              ),
              _SettingsTile(
                label: localizations.settingsTheme,
                value: themeLabel,
                onTap: onSelectTheme,
                showChevron: true,
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text(localizations.settingsSectionAbout),
            children: [
              _SettingsTile(
                label: localizations.settingsAbout,
                value: '',
                onTap: onOpenAbout,
                showChevron: true,
              ),
              _SettingsTile(
                label: localizations.settingsSupport,
                value: '',
                onTap: onOpenSupport,
                showChevron: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    required this.value,
    this.onTap,
    required this.showChevron,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final valueStyle = textStyle.copyWith(
      color: CupertinoColors.systemGrey.resolveFrom(context),
    );
    final row = Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: textStyle)),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (showChevron)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(CupertinoIcons.forward, size: 16),
          ),
      ],
    );
    final child = onTap == null
        ? row
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: row,
          );
    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}
