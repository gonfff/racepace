part of 'splits_screen.dart';

class _SettingsBlock extends StatelessWidget {
  const _SettingsBlock({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _SplitsScreenState._settingsBlockHeight,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CupertinoColors.systemGrey4.resolveFrom(context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 36,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 18,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetsSheet extends StatefulWidget {
  const _PresetsSheet({required this.presets, required this.fallbackInterval});

  final List<SplitsPreset> presets;
  final _SplitInterval fallbackInterval;

  @override
  State<_PresetsSheet> createState() => _PresetsSheetState();
}

class _PresetsSheetState extends State<_PresetsSheet> {
  late final List<SplitsPreset> _items = List.of(widget.presets);
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final sheetHeight = MediaQuery.sizeOf(context).height * 0.5;
    final closeLabel = AppLocalizations.of(context).settingsClose;

    return SafeArea(
      top: true,
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: _isDragging
              ? Duration.zero
              : const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _dragOffset, 0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              height: sheetHeight,
              decoration: BoxDecoration(
                color: AppTheme.scaffoldBackgroundColor(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      final nextOffset = _dragOffset + details.delta.dy;
                      if (nextOffset < 0) return;
                      setState(() {
                        _isDragging = true;
                        _dragOffset = nextOffset;
                      });
                    },
                    onVerticalDragEnd: (_) {
                      if (_dragOffset > 90) {
                        Navigator.of(context).pop();
                        return;
                      }
                      setState(() {
                        _isDragging = false;
                        _dragOffset = 0;
                      });
                    },
                    onVerticalDragCancel: () {
                      setState(() {
                        _isDragging = false;
                        _dragOffset = 0;
                      });
                    },
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4.resolveFrom(
                              context,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(closeLabel),
                                ),
                              ),
                              Text(
                                localizations.splitsPresets,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                localizations.splitsPresetsEmpty,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            itemCount: _items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final preset = _items[index];
                              return Dismissible(
                                key: ValueKey('preset_${preset.id}'),
                                direction: DismissDirection.endToStart,
                                background: const SizedBox.shrink(),
                                secondaryBackground: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemRed,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.trash,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                                onDismissed: (_) async {
                                  final service = SplitsPresetsScope.of(
                                    context,
                                  );
                                  await service.deletePreset(preset.id);
                                  if (!mounted) return;
                                  setState(() {
                                    _items.removeWhere(
                                      (item) => item.id == preset.id,
                                    );
                                  });
                                },
                                child: _PresetCard(
                                  preset: preset,
                                  content: _presetRowWidget(
                                    localizations,
                                    preset,
                                    widget.fallbackInterval,
                                  ),
                                  onSelect: () =>
                                      Navigator.of(context).pop(preset),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.content,
    required this.onSelect,
  });

  final SplitsPreset preset;
  final Widget content;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CupertinoColors.systemGrey4.resolveFrom(context),
          ),
        ),
        child: Row(children: [Expanded(child: content)]),
      ),
    );
  }
}

Widget _presetRowWidget(
  AppLocalizations localizations,
  SplitsPreset preset,
  _SplitInterval fallbackInterval,
) {
  final interval =
      _splitIntervalFromCode(preset.intervalCode) ?? fallbackInterval;
  final intervalLabel = interval.label(localizations);
  final strategyLabel = _strategyTileLabel(
    localizations,
    preset.strategyPercent,
  );
  return Row(
    children: [
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            intervalLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            strategyLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  );
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    super.key,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _SplitsScreenState._valueBlockHeight,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CupertinoColors.systemGrey4.resolveFrom(context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 36,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 18,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitsTable extends StatelessWidget {
  const _SplitsTable({
    required this.splits,
    required this.unitShortLabel,
    required this.paceUnitLabel,
    required this.localizations,
  });

  final List<_SplitRow> splits;
  final String unitShortLabel;
  final String paceUnitLabel;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) {
      return const SizedBox.shrink();
    }
    final dividerColor = CupertinoColors.systemGrey4.resolveFrom(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                _HeaderCell(text: localizations.splitsColumnIndex, flex: 1),
                _HeaderCell(text: localizations.splitsColumnDistance, flex: 2),
                _HeaderCell(text: localizations.splitsColumnPace, flex: 2),
                _HeaderCell(text: localizations.splitsColumnFromStart, flex: 2),
                _HeaderCell(text: localizations.splitsColumnFromZero, flex: 2),
              ],
            ),
          ),
          Container(height: 1, color: dividerColor),
          ...splits.map((row) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      _BodyCell(text: row.index.toString(), flex: 1),
                      _BodyCell(
                        text: '${_formatNumber(row.distance)} $unitShortLabel',
                        flex: 2,
                      ),
                      _BodyCell(text: _formatDuration(row.pace), flex: 2),
                      _BodyCell(text: _formatDuration(row.elapsed), flex: 2),
                      _BodyCell(text: _formatClock(row.clock), flex: 2),
                    ],
                  ),
                ),
                if (row != splits.last)
                  Container(height: 1, color: dividerColor),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
