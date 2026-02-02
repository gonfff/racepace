part of 'calculator_screen.dart';

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? CupertinoColors.activeBlue.withValues(alpha: 0.15)
        : AppTheme.cardBackgroundColor(context);
    final borderColor = isSelected
        ? CupertinoColors.activeBlue
        : CupertinoColors.systemGrey4.resolveFrom(context);
    final textColor = isSelected
        ? CupertinoColors.activeBlue
        : CupertinoColors.label.resolveFrom(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
