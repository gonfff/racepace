part of 'splits_screen.dart';

extension _SplitsScreenDialogs on _SplitsScreenState {
  Future<void> _openIntervalPicker(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    var selected = _selectedInterval;
    final intervals = _SplitInterval.values;
    final initialIndex = intervals
        .indexOf(_selectedInterval)
        .clamp(0, intervals.length - 1);
    final result = await showCupertinoDialog<_SplitInterval>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(localizations.splitsIntervalTitle),
          content: SizedBox(
            height: 160,
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex,
              ),
              onSelectedItemChanged: (index) {
                selected = intervals[index];
              },
              children: intervals
                  .map(
                    (interval) =>
                        Center(child: Text(interval.label(localizations))),
                  )
                  .toList(),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(localizations.calculatorCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(selected),
              child: Text(localizations.calculatorOk),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    _updateSplitsState(() {
      _selectedInterval = result;
    });
  }

  Future<void> _openStrategyPicker(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    var selected = _strategyPercent;
    const minPercent = -10;
    const maxPercent = 10;
    final itemCount = maxPercent - minPercent + 1;
    final result = await showCupertinoDialog<int>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(localizations.splitsPaceStrategyTitle),
          content: SizedBox(
            height: 160,
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(
                initialItem: selected - minPercent,
              ),
              onSelectedItemChanged: (index) {
                selected = minPercent + index;
              },
              children: List.generate(itemCount, (index) {
                final value = minPercent + index;
                return Center(child: Text(_strategyPickerLabel(value)));
              }),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(localizations.calculatorCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(selected),
              child: Text(localizations.calculatorOk),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    _updateSplitsState(() {
      _strategyPercent = result;
    });
  }

  Future<void> _openStartTimePicker(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final current =
        _parseClock(_startTimeController.text) ??
        _parseClock(_SplitsScreenState._defaultStartTime)!;
    var selectedHours = current.inHours.remainder(24);
    var selectedMinutes = current.inMinutes.remainder(60);
    final now = DateTime.now();
    final result = await showCupertinoDialog<Duration?>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(localizations.splitsStartTimeTitle),
          content: SizedBox(
            height: 160,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              initialDateTime: DateTime(
                now.year,
                now.month,
                now.day,
                selectedHours,
                selectedMinutes,
              ),
              onDateTimeChanged: (value) {
                selectedHours = value.hour;
                selectedMinutes = value.minute;
              },
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(localizations.calculatorCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(
                context,
              ).pop(Duration(hours: selectedHours, minutes: selectedMinutes)),
              child: Text(localizations.calculatorOk),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (result == null) return;
    _updateSplitsState(() {
      _startTimeController.text = _formatClock(result);
    });
  }

  Future<void> _openValueInputDialog(
    BuildContext context,
    SplitValueField field,
  ) async {
    final localizations = AppLocalizations.of(context);
    final unitShortLabel = _unitShortLabel(localizations, widget.unit);
    final paceUnitLabel = '${localizations.unitMinutesShort}/$unitShortLabel';
    final initialText = switch (field) {
      SplitValueField.distance => _formatNumber(_distance),
      SplitValueField.pace => _formatDuration(_pace),
      SplitValueField.time => _formatDuration(_time),
    };
    final controller = TextEditingController(
      text: field == SplitValueField.distance
          ? initialText
          : _TimeTextInputFormatter.format(
              _digitsOnly(initialText),
              allowHours: field == SplitValueField.time,
            ),
    );
    final isTimeField = field == SplitValueField.time;
    final isPaceField = field == SplitValueField.pace;
    final isDistanceField = field == SplitValueField.distance;
    final inputFormatters = <TextInputFormatter>[
      if (isTimeField || isPaceField)
        _TimeTextInputFormatter(allowHours: isTimeField)
      else
        _DistanceTextInputFormatter(),
    ];
    final placeholder = switch (field) {
      SplitValueField.distance => '0.0',
      SplitValueField.pace => '__:__',
      SplitValueField.time => '__:__:__',
    };
    final title = switch (field) {
      SplitValueField.distance => localizations.calculatorDistance,
      SplitValueField.pace => localizations.calculatorPace,
      SplitValueField.time => localizations.calculatorTime,
    };
    const inputFieldHeight = 44.0;
    var distanceValue = _clampDistance(_distance);
    var distanceWhole = distanceValue.floor();
    var distanceTenths = ((distanceValue - distanceWhole) * 10).round();
    final maxDistanceWhole = _SplitsScreenState._maxDistance.floor();
    if (distanceWhole > maxDistanceWhole) {
      distanceWhole = maxDistanceWhole;
      distanceTenths = 0;
    }
    if (distanceTenths < 0) distanceTenths = 0;
    if (distanceTenths > 9) distanceTenths = 9;
    final paceValue = _clampPace(_pace);
    var paceMinutes = paceValue.inMinutes;
    var paceSeconds = paceValue.inSeconds.remainder(60);
    final timeValue = _clampTime(_time);
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
                  itemCount: _SplitsScreenState._maxPace.inMinutes + 1,
                  onSelected: (value) => setState(() {
                    paceMinutes = value;
                    if (paceMinutes >= _SplitsScreenState._maxPace.inMinutes &&
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
                    if (paceMinutes >= _SplitsScreenState._maxPace.inMinutes &&
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
                  itemCount: _SplitsScreenState._maxTime.inHours + 1,
                  onSelected: (value) => setState(() {
                    timeHours = value;
                    if (timeHours >= _SplitsScreenState._maxTime.inHours &&
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
                    if (timeHours >= _SplitsScreenState._maxTime.inHours &&
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
                    if (timeHours >= _SplitsScreenState._maxTime.inHours &&
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
              SplitValueField.distance => buildDistancePicker(
                setState,
                syncTextFromWheel,
              ),
              SplitValueField.pace => buildPacePicker(
                setState,
                syncTextFromWheel,
              ),
              SplitValueField.time => buildTimePicker(
                setState,
                syncTextFromWheel,
              ),
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

    void disposeControllers() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        distanceWholeController.dispose();
        distanceTenthsController.dispose();
        paceMinutesController.dispose();
        paceSecondsController.dispose();
        timeHoursController.dispose();
        timeMinutesController.dispose();
        timeSecondsController.dispose();
      });
    }

    if (result == null) {
      disposeControllers();
      return;
    }
    final trimmed = result.trim();
    if (trimmed.isEmpty) {
      disposeControllers();
      return;
    }

    _updateSplitsState(() {
      switch (field) {
        case SplitValueField.distance:
          final value = double.tryParse(trimmed);
          if (value == null || value <= 0) return;
          _distance = _clampDistance(value);
          if (_pace.inSeconds > 0) {
            _time = _clampTime(
              Duration(seconds: (_distance * _pace.inSeconds).round()),
            );
          }
          break;
        case SplitValueField.pace:
          final paceDigits = _digitsOnly(trimmed);
          if (paceDigits.isEmpty) return;
          final pace = _durationFromDigits(paceDigits, allowHours: false);
          if (pace == null) return;
          _pace = _clampPace(pace);
          if (_distance > 0) {
            _time = _clampTime(
              Duration(seconds: (_distance * _pace.inSeconds).round()),
            );
          }
          break;
        case SplitValueField.time:
          final timeDigits = _digitsOnly(trimmed);
          if (timeDigits.isEmpty) return;
          final time = _durationFromDigits(timeDigits, allowHours: true);
          if (time == null) return;
          _time = _clampTime(time);
          if (_distance > 0) {
            _pace = _clampPace(
              Duration(seconds: (_time.inSeconds / _distance).round()),
            );
          }
          break;
      }
    });

    disposeControllers();
    _emitValuesChanged(field);
  }
}
