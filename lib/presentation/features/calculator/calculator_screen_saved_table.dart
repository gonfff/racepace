part of 'calculator_screen.dart';

class _SavedCalculationsTable extends StatelessWidget {
  const _SavedCalculationsTable({
    required this.entries,
    required this.localizations,
    required this.onSelect,
    required this.onDelete,
  });

  final List<Calculation> entries;
  final AppLocalizations localizations;
  final ValueChanged<Calculation> onSelect;
  final ValueChanged<Calculation> onDelete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: entries
          .asMap()
          .entries
          .map(
            (entry) => _SavedCard(
              entry: entry.value,
              unitLabel: _unitShortLabel(localizations, entry.value.unit),
              onSelect: onSelect,
              onDelete: onDelete,
            ),
          )
          .toList(),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({
    required this.entry,
    required this.unitLabel,
    required this.onSelect,
    required this.onDelete,
  });

  final Calculation entry;
  final String unitLabel;
  final ValueChanged<Calculation> onSelect;
  final ValueChanged<Calculation> onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(CupertinoIcons.trash, color: CupertinoColors.white),
      ),
      onDismissed: (_) => onDelete(entry),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(entry),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CupertinoColors.systemGrey4.resolveFrom(context),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatNumber(entry.distance)} $unitLabel',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_formatDuration(entry.pace)} / ${_formatDuration(entry.time)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
