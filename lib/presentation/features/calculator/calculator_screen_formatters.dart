part of 'calculator_screen.dart';

class _TimeTextInputFormatter extends TextInputFormatter {
  _TimeTextInputFormatter({required this.allowHours});

  final bool allowHours;

  static String format(String digits, {required bool allowHours}) {
    final maxLength = allowHours ? 6 : 4;
    final trimmed = digits.length > maxLength
        ? digits.substring(0, maxLength)
        : digits;
    final slots = allowHours ? 6 : 4;
    final padded = List<String>.generate(
      slots,
      (index) => index < trimmed.length ? trimmed[index] : '_',
    );
    if (allowHours) {
      return '${padded[0]}${padded[1]}:${padded[2]}${padded[3]}:${padded[4]}${padded[5]}';
    }
    return '${padded[0]}${padded[1]}:${padded[2]}${padded[3]}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatted = format(digits, allowHours: allowHours);
    final digitsBeforeCursor = _countDigitsBefore(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final caret = _caretOffsetForDigitIndex(
      digitsBeforeCursor,
      allowHours: allowHours,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  static int _countDigitsBefore(String text, int offset) {
    if (offset <= 0) return 0;
    final limit = offset.clamp(0, text.length);
    return RegExp(r'\d').allMatches(text.substring(0, limit)).length;
  }

  static int _caretOffsetForDigitIndex(
    int digitIndex, {
    required bool allowHours,
  }) {
    final maxDigits = allowHours ? 6 : 4;
    final clamped = digitIndex.clamp(0, maxDigits);
    final base = clamped.toInt();
    if (allowHours) {
      if (base <= 2) return base;
      if (base <= 4) return base + 1;
      return base + 2;
    }
    if (base <= 2) return base;
    return base + 1;
  }
}

class _DistanceTextInputFormatter extends TextInputFormatter {
  static const int _maxIntegerDigits = 3;
  static const int _maxFractionDigits = 1;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(',', '.');
    text = text.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDot = text.indexOf('.');
    if (firstDot != -1) {
      final beforeDot = text.substring(0, firstDot);
      final afterDot = text.substring(firstDot + 1).replaceAll('.', '');
      text = '$beforeDot.$afterDot';
    }

    final dotIndex = text.indexOf('.');
    if (dotIndex != -1) {
      var intPart = text.substring(0, dotIndex);
      var fracPart = text.substring(dotIndex + 1);
      if (intPart.isEmpty) intPart = '0';
      if (intPart.length > _maxIntegerDigits) {
        intPart = intPart.substring(0, _maxIntegerDigits);
      }
      if (fracPart.length > _maxFractionDigits) {
        fracPart = fracPart.substring(0, _maxFractionDigits);
      }
      text = fracPart.isEmpty ? '$intPart.' : '$intPart.$fracPart';
    } else if (text.length > _maxIntegerDigits) {
      text = text.substring(0, _maxIntegerDigits);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
