part of 'calculator_screen.dart';

extension _CalculatorInputDialog on _CalculatorScreenState {
  Future<void> _openInputDialog(
    BuildContext context,
    _CalcField field,
    Unit unit,
  ) async {
    final localizations = AppLocalizations.of(context);
    final initialText = switch (field) {
      _CalcField.distance => _distanceController.text,
      _CalcField.pace => _paceController.text,
      _CalcField.time => _timeController.text,
    };
    final controller = TextEditingController(
      text: field == _CalcField.distance
          ? initialText
          : _TimeTextInputFormatter.format(
              _digitsOnly(initialText),
              allowHours: field == _CalcField.time,
            ),
    );
    final isTimeField = field == _CalcField.time;
    final isPaceField = field == _CalcField.pace;
    final isDistanceField = field == _CalcField.distance;
    final inputFormatters = <TextInputFormatter>[
      if (isTimeField || isPaceField)
        _TimeTextInputFormatter(allowHours: isTimeField)
      else
        _DistanceTextInputFormatter(),
    ];
    final placeholder = switch (field) {
      _CalcField.distance => '0.0',
      _CalcField.pace => '__:__',
      _CalcField.time => '__:__:__',
    };
    final unitShortLabel = _unitShortLabel(localizations, unit);
    final paceUnitLabel = '${localizations.unitMinutesShort}/$unitShortLabel';
    final title = switch (field) {
      _CalcField.distance => localizations.calculatorDistance,
      _CalcField.pace => localizations.calculatorPace,
      _CalcField.time => localizations.calculatorTime,
    };
    const inputFieldHeight = 44.0;
    var distanceValue = _parseDistance(_distanceController.text) ?? 0;
    var distanceWhole = distanceValue.floor();
    var distanceTenths = ((distanceValue - distanceWhole) * 10).round();
    final maxDistanceWhole = _CalculatorScreenState._maxDistance.floor();
    if (distanceWhole > maxDistanceWhole) {
      distanceWhole = maxDistanceWhole;
      distanceTenths = 0;
    }
    if (distanceTenths < 0) distanceTenths = 0;
    if (distanceTenths > 9) distanceTenths = 9;
    final paceValue = _clampPace(
      _parseDuration(_paceController.text) ?? Duration.zero,
    );
    var paceMinutes = paceValue.inMinutes;
    var paceSeconds = paceValue.inSeconds.remainder(60);
    final timeValue = _clampTime(
      _parseDuration(_timeController.text) ?? Duration.zero,
    );
    var timeHours = timeValue.inHours;
    var timeMinutes = timeValue.inMinutes.remainder(60);
    var timeSeconds = timeValue.inSeconds.remainder(60);
    final distanceWholeController = FixedExtentScrollController(
      initialItem: distanceWhole,
    );
    final distanceTenthsController = FixedExtentScrollController(
      initialItem: distanceTenths,
    );
    final paceMinutesController = FixedExtentScrollController(
      initialItem: paceMinutes,
    );
    final paceSecondsController = FixedExtentScrollController(
      initialItem: paceSeconds,
    );
    final timeHoursController = FixedExtentScrollController(
      initialItem: timeHours,
    );
    final timeMinutesController = FixedExtentScrollController(
      initialItem: timeMinutes,
    );
    final timeSecondsController = FixedExtentScrollController(
      initialItem: timeSeconds,
    );

    Duration? durationFromMaskedInput(String text, {required bool allowHours}) {
      final digits = _digitsOnly(text);
      if (digits.isEmpty) return null;
      return _durationFromDigits(digits, allowHours: allowHours);
    }

    void syncWheelFromText(StateSetter setState) {
      if (isDistanceField) {
        final parsed = _parseDistance(controller.text) ?? 0;
        var whole = parsed.floor();
        var tenths = ((parsed - whole) * 10).round();
        if (whole > maxDistanceWhole) {
          whole = maxDistanceWhole;
          tenths = 0;
        }
        if (tenths < 0) tenths = 0;
        if (tenths > 9) tenths = 9;
        setState(() {
          distanceWhole = whole;
          distanceTenths = tenths;
        });
        distanceWholeController.jumpToItem(whole);
        distanceTenthsController.jumpToItem(tenths);
      } else if (isPaceField) {
        final parsed = _clampPace(
          durationFromMaskedInput(controller.text, allowHours: false) ??
              Duration.zero,
        );
        final minutes = parsed.inMinutes;
        final seconds = parsed.inSeconds.remainder(60);
        setState(() {
          paceMinutes = minutes;
          paceSeconds = seconds;
        });
        paceMinutesController.jumpToItem(minutes);
        paceSecondsController.jumpToItem(seconds);
      } else {
        final parsed = _clampTime(
          durationFromMaskedInput(controller.text, allowHours: true) ??
              Duration.zero,
        );
        final hours = parsed.inHours;
        final minutes = parsed.inMinutes.remainder(60);
        final seconds = parsed.inSeconds.remainder(60);
        setState(() {
          timeHours = hours;
          timeMinutes = minutes;
          timeSeconds = seconds;
        });
        timeHoursController.jumpToItem(hours);
        timeMinutesController.jumpToItem(minutes);
        timeSecondsController.jumpToItem(seconds);
      }
    }

    String wheelValue() {
      if (isDistanceField) {
        final value = distanceWhole + (distanceTenths / 10);
        return _clampDistance(value).toStringAsFixed(1);
      }
      if (isPaceField) {
        final duration = Duration(minutes: paceMinutes, seconds: paceSeconds);
        return _formatDuration(_clampPace(duration));
      }
      final duration = Duration(
        hours: timeHours,
        minutes: timeMinutes,
        seconds: timeSeconds,
      );
      return _formatDuration(_clampTime(duration));
    }

    Widget buildPickerColumn({
      required FixedExtentScrollController scrollController,
      required int itemCount,
      required ValueChanged<int> onSelected,
    }) {
      return Expanded(
        child: CupertinoPicker(
          scrollController: scrollController,
          itemExtent: 32,
          onSelectedItemChanged: onSelected,
          useMagnifier: true,
          magnification: 1.1,
          children: List.generate(
            itemCount,
            (index) => Center(child: Text('$index')),
          ),
        ),
      );
    }

    Widget buildDistancePicker(StateSetter setState, VoidCallback syncText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPickerColumn(
                  scrollController: distanceWholeController,
                  itemCount: maxDistanceWhole + 1,
                  onSelected: (value) => setState(() {
                    distanceWhole = value;
                    if (distanceWhole >= maxDistanceWhole) {
                      distanceTenths = 0;
                      distanceTenthsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('.', style: TextStyle(fontSize: 18)),
                ),
                buildPickerColumn(
                  scrollController: distanceTenthsController,
                  itemCount: 10,
                  onSelected: (value) => setState(() {
                    distanceTenths = value;
                    if (distanceWhole >= maxDistanceWhole && value > 0) {
                      distanceTenths = 0;
                      distanceTenthsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unitShortLabel,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }

    Widget buildPacePicker(StateSetter setState, VoidCallback syncText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPickerColumn(
                  scrollController: paceMinutesController,
                  itemCount: _CalculatorScreenState._maxPace.inMinutes + 1,
                  onSelected: (value) => setState(() {
                    paceMinutes = value;
                    if (paceMinutes >=
                            _CalculatorScreenState._maxPace.inMinutes &&
                        paceSeconds > 0) {
                      paceSeconds = 0;
                      paceSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: TextStyle(fontSize: 18)),
                ),
                buildPickerColumn(
                  scrollController: paceSecondsController,
                  itemCount: 60,
                  onSelected: (value) => setState(() {
                    paceSeconds = value;
                    if (paceMinutes >=
                            _CalculatorScreenState._maxPace.inMinutes &&
                        value > 0) {
                      paceSeconds = 0;
                      paceSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            paceUnitLabel,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }

    Widget buildTimePicker(StateSetter setState, VoidCallback syncText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPickerColumn(
                  scrollController: timeHoursController,
                  itemCount: _CalculatorScreenState._maxTime.inHours + 1,
                  onSelected: (value) => setState(() {
                    timeHours = value;
                    if (timeHours >= _CalculatorScreenState._maxTime.inHours &&
                        (timeMinutes > 0 || timeSeconds > 0)) {
                      timeMinutes = 0;
                      timeSeconds = 0;
                      timeMinutesController.jumpToItem(0);
                      timeSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: TextStyle(fontSize: 18)),
                ),
                buildPickerColumn(
                  scrollController: timeMinutesController,
                  itemCount: 60,
                  onSelected: (value) => setState(() {
                    timeMinutes = value;
                    if (timeHours >= _CalculatorScreenState._maxTime.inHours &&
                        (value > 0 || timeSeconds > 0)) {
                      timeMinutes = 0;
                      timeSeconds = 0;
                      timeMinutesController.jumpToItem(0);
                      timeSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: TextStyle(fontSize: 18)),
                ),
                buildPickerColumn(
                  scrollController: timeSecondsController,
                  itemCount: 60,
                  onSelected: (value) => setState(() {
                    timeSeconds = value;
                    if (timeHours >= _CalculatorScreenState._maxTime.inHours &&
                        (timeMinutes > 0 || value > 0)) {
                      timeMinutes = 0;
                      timeSeconds = 0;
                      timeMinutesController.jumpToItem(0);
                      timeSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localizations.calculatorTimeFormat,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }

    String? result;
    var isSyncing = false;
    try {
      result = await showCupertinoDialog<String?>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              void syncTextFromWheel() {
                if (isSyncing) return;
                isSyncing = true;
                final text = wheelValue();
                controller.value = controller.value.copyWith(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
                isSyncing = false;
              }

              void syncWheelFromField() {
                if (isSyncing) return;
                isSyncing = true;
                syncWheelFromText(setState);
                isSyncing = false;
              }

              final inputField = CupertinoTextField(
                controller: controller,
                keyboardType: isDistanceField
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                inputFormatters: inputFormatters,
                placeholder: placeholder,
                textAlign: TextAlign.center,
                onChanged: (_) => syncWheelFromField(),
              );
              final picker = switch (field) {
                _CalcField.distance => buildDistancePicker(
                  setState,
                  syncTextFromWheel,
                ),
                _CalcField.pace => buildPacePicker(setState, syncTextFromWheel),
                _CalcField.time => buildTimePicker(setState, syncTextFromWheel),
              };

              return CupertinoAlertDialog(
                title: Text(title),
                content: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: inputFieldHeight, child: inputField),
                      const SizedBox(height: 12),
                      picker,
                    ],
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(localizations.calculatorCancel),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () => Navigator.of(context).pop(controller.text),
                    child: Text(localizations.calculatorOk),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      distanceWholeController.dispose();
      distanceTenthsController.dispose();
      paceMinutesController.dispose();
      paceSecondsController.dispose();
      timeHoursController.dispose();
      timeMinutesController.dispose();
      timeSecondsController.dispose();
    }

    if (result == null) return;
    final trimmed = result.trim();
    if (trimmed.isEmpty) return;

    switch (field) {
      case _CalcField.distance:
        final value = double.tryParse(trimmed);
        if (value == null || value <= 0) return;
        final clamped = _clampDistance(value);
        _distanceController.text = _formatNumber(clamped);
        break;
      case _CalcField.pace:
        final paceDigits = _digitsOnly(trimmed);
        if (paceDigits.isEmpty) return;
        final pace = _durationFromDigits(paceDigits, allowHours: false);
        if (pace == null) return;
        _paceController.text = _formatDuration(_clampPace(pace));
        break;
      case _CalcField.time:
        final timeDigits = _digitsOnly(trimmed);
        if (timeDigits.isEmpty) return;
        final time = _durationFromDigits(timeDigits, allowHours: true);
        if (time == null) return;
        _timeController.text = _formatDuration(_clampTime(time));
        break;
    }

    _handleChange(field);
  }
}
