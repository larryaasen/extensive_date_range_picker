library extensive_date_range_picker;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui show TextDirection;

import 'package:extensive_date_range_picker/src/date_time_relative.dart';
import 'package:flutter/material.dart';

import 'src/custom_dropdown.dart';
import 'src/date_time_range.dart';

export 'src/custom_dropdown.dart';
export 'src/date_time_range.dart';
export 'src/date_time_relative.dart';

/// Shows a dialog containing a Material Design date and time picker with
/// extensive features such as preset ranges, relative ranges, abd custom
/// ranges.
///
/// The returned [Future] resolves to [DateTimeRangePhrase] that is the range
/// selected by the user when the user confirms the dialog. If the user cancels
/// the dialog, null is returned.
///
/// When the date picker is first displayed, it will show the month of
/// [initialRange], with [initialRange] selected.
///
/// The [firstDate] is the earliest allowable date. The [lastDate] is the latest
/// allowable date. [initialRange] must either fall between these dates,
/// or be equal to one of them. For each of these [DateTime] parameters, only
/// their dates are considered. Their time fields are ignored. They must all
/// be non-null.
///
/// An optional [selectableDayPredicate] function can be passed in to only allow
/// certain days for selection. If provided, only the days that
/// [selectableDayPredicate] returns true for will be selectable. For example,
/// this can be used to only allow weekdays for selection. If provided, it must
/// return true for [initialRange].
///
/// An optional [locale] argument can be used to set the locale for the date
/// picker. It defaults to the ambient locale provided by [Localizations].
///
/// An optional [textDirection] argument can be used to set the text direction
/// ([TextDirection.ltr] or [TextDirection.rtl]) for the date picker. It
/// defaults to the ambient text direction provided by [Directionality]. If both
/// [locale] and [textDirection] are non-null, [textDirection] overrides the
/// direction chosen for the [locale].
///
/// The [context], [useRootNavigator] and [routeSettings] arguments are passed to
/// [showDialog], the documentation for which discusses how it is used. [context]
/// and [useRootNavigator] must be non-null.
///
/// The [builder] parameter can be used to wrap the dialog widget
/// to add inherited widgets like [Theme].
///
/// This function was modeled from the [showDatePicker] function.

Future<DateTimeRangePhrase?> showDateRangeDialog({
  required BuildContext context,
  DateTimeRangePhrase? initialRange,
  Locale? locale,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  ui.TextDirection? textDirection,
  TransitionBuilder? builder,
}) async {
  assert(debugCheckHasMaterialLocalizations(context));

  Widget dialog = _DatePickerDialog(
    initialRange: initialRange,
  );

  if (textDirection != null) {
    dialog = Directionality(
      textDirection: textDirection,
      child: dialog,
    );
  }

  if (locale != null) {
    dialog = Localizations.override(
      context: context,
      locale: locale,
      child: dialog,
    );
  }

  return showDialog<DateTimeRangePhrase>(
    context: context,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

const Size _calendarPortraitDialogSize = Size(330.0, 475.0);
const Size _calendarLandscapeDialogSize = Size(496.0, 346.0);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);

enum _PanelIndex {
  presets,
  relative,
  dateRange,
}

class _DatePickerDialog extends StatefulWidget {
  const _DatePickerDialog({
    Key? key,
    this.initialRange,
  }) : super(key: key);

  /// The initially selected [DateTime] that the picker should display.
  final DateTimeRangePhrase? initialRange;

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  final _dateFormat = DateTimeRangePhrase.dateFormat;
  final _headStyle = const TextStyle(fontWeight: FontWeight.bold);
  TextStyle? _linkStyle;
  DateTimeRangePhrase? _selectedRange;
  bool _latestTextEnabled = false;
  String? _relativeEarliestValue = 'y';
  String? _relativeLatestValue = 'now';
  final _expandedPanelIndex = _PanelIndex.presets.index;
  final TextEditingController _earliestController = TextEditingController();
  final TextEditingController _latestController = TextEditingController();
  Timer? _earliestTimer, _latestTimer;
  DateTime? _earliestDate, _latestDate;

  final _listTitles = ["Presets", "Relative", "Date Range"];

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
  }

  void _handleOk() {
    Navigator.pop(context, _selectedRange);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  Size _dialogSize(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    switch (orientation) {
      case Orientation.portrait:
        return _calendarPortraitDialogSize;
      case Orientation.landscape:
        return _calendarLandscapeDialogSize;
    }
  }

  Widget _buildPanelBodyPresets(BuildContext context) {
    final selections = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text("RELATIVE", style: _headStyle),
                ),
                _linkButton("Last 7 days", DateTimeRangePreset.last7Days),
                _linkButton("Last 30 days", DateTimeRangePreset.last30Days),
                _linkButton("Last 3 months", DateTimeRangePreset.last3Months),
                _linkButton("Last 6 months", DateTimeRangePreset.last6Months),
                _linkButton("Last 9 months", DateTimeRangePreset.last9Months),
                _linkButton("Last 12 months", DateTimeRangePreset.last12Months),
                _linkButton("Last 5 years", DateTimeRangePreset.last5Years),
                _linkButton("Last 10 years", DateTimeRangePreset.last10Years),
              ],
            )),
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text("", style: _headStyle),
                ),
                _linkButton("Last 15 years", DateTimeRangePreset.last15Years),
                _linkButton("Last 20 years", DateTimeRangePreset.last20Years),
                _linkButton("Last 25 years", DateTimeRangePreset.last25Years),
                _linkButton("Last 30 years", DateTimeRangePreset.last30Years),
                _linkButton("Previous week", DateTimeRangePreset.prevWeek),
                _linkButton("Previous month", DateTimeRangePreset.prevMonth),
                _linkButton("Previous year", DateTimeRangePreset.prevYear),
              ],
            )),
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text("OTHER", style: _headStyle),
                ),
                _linkButton("All time", DateTimeRangePreset.allTime)
              ],
            )),
      ],
    );

    final body = Column(children: <Widget>[
      selections,
      Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              // textTheme: ButtonTextTheme.accent,
              child: const Text("CANCEL"),
              // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                _handleCancel();
              },
            ))
      ])
    ]);

    return body;
  }

  Widget _linkButton(String data, DateTimeRangePhrase range) {
    return InkWell(
      key: ObjectKey(range),
      child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(data, style: _linkStyle)),
      onTap: () {
        setState(() => _selectedRange = range);
        _handleOk();
      },
    );
  }

  String? _relValue(String timeInt, String? timeUnit) {
    if (timeUnit == 'now') {
      return timeUnit;
    }
    if (int.tryParse(timeInt) != null) {
      final value = int.parse(timeInt);
      final relative = "-$value$timeUnit";
      return relative;
    }
    return null;
  }

  Widget _buildPanelBodyRelative(BuildContext context) {
    final earliestValue =
        _relValue(_earliestController.text, _relativeEarliestValue);
    final latestValue = _relValue(_latestController.text, _relativeLatestValue);

    final selections = Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text("EARLIEST", style: _headStyle),
              ),
              Container(
                  width: 220,
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(3)),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              autocorrect: false,
                              // autofocus: true,
                              decoration: null,
                              //     InputDecoration.collapsed(hintText: ""),
                              controller: _earliestController,
                              onChanged: (value) {
                                // start 1.5 sec timer, after timer fires, update message, if timer already started - stop it and restart it
                                if (_earliestTimer != null) {
                                  _earliestTimer!.cancel();
                                }
                                _earliestTimer = Timer(
                                    const Duration(milliseconds: 1000), () {
                                  setState(() {
                                    _earliestTimer = null;
                                  });
                                });
                              },
                            )),
                        DropdownButton(
                          value: _relativeEarliestValue,
                          items: const [
                            DropdownMenuItem(
                                value: "d", child: Text("Days Ago")),
                            DropdownMenuItem(
                                value: "w", child: Text("Weeks Ago")),
                            DropdownMenuItem(
                                value: "m", child: Text("Months Ago")),
                            DropdownMenuItem(
                                value: "y", child: Text("Years Ago")),
                          ],
                          onChanged: (dynamic value) {
                            setState(() {
                              _relativeEarliestValue = value;
                            });
                          },
                        ),
                      ])),
              Padding(
                padding: const EdgeInsets.only(bottom: 7, top: 1),
                child: Text(
                  earliestValue != null
                      ? _dateFormat
                          .format(DateTime.now().relative(earliestValue)!)
                      : "",
                  style: const TextStyle(fontWeight: FontWeight.w200),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7, top: 0),
                child: Text("LATEST", style: _headStyle),
              ),
              Container(
                  width: 220,
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(3)),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 60,
                          child: TextField(
                            enabled: _latestTextEnabled,
                            keyboardType: TextInputType.number,
                            autocorrect: false,
                            // autofocus: true,
                            decoration:
                                const InputDecoration.collapsed(hintText: ""),
                            controller: _latestController,
                            onChanged: (value) {
                              // start 1.5 sec timer, after timer fires, update message, if timer already started - stop it and restart it
                              if (_latestTimer != null) {
                                _latestTimer!.cancel();
                              }
                              _latestTimer =
                                  Timer(const Duration(milliseconds: 1000), () {
                                setState(() {
                                  _latestTimer = null;
                                });
                              });
                            },
                          ),
                        ),
                        DropdownButton(
                          value: _relativeLatestValue,
                          items: const [
                            DropdownMenuItem(value: 'now', child: Text('Now')),
                            DropdownMenuItem(
                                value: "d", child: Text("Days Ago")),
                            DropdownMenuItem(
                                value: "w", child: Text("Weeks Ago")),
                            DropdownMenuItem(
                                value: "m", child: Text("Months Ago")),
                            DropdownMenuItem(
                                value: "y", child: Text("Years Ago")),
                          ],
                          onChanged: (dynamic value) {
                            setState(() {
                              _relativeLatestValue = value;
                              _latestTextEnabled = value != 'now';
                            });
                          },
                        )
                      ])),
              Padding(
                padding: const EdgeInsets.only(bottom: 7, top: 1),
                child: Text(
                  latestValue != null
                      ? _dateFormat
                          .format(DateTime.now().relative(latestValue)!)
                      : "",
                  style: const TextStyle(fontWeight: FontWeight.w200),
                ),
              ),
            ]));

    final body =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      selections,
      Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        TextButton(
          // textTheme: ButtonTextTheme.accent,
          child: const Text("CANCEL"),
          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            _handleCancel();
          },
        ),
        Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              // textTheme: ButtonTextTheme.accent,
              child: const Text("APPLY"),
              // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                final earliest =
                    _relValue(_earliestController.text, _relativeEarliestValue);
                final latest =
                    _relValue(_latestController.text, _relativeLatestValue);
                if (earliest != null && latest != null) {
                  final range =
                      DateTimeRangeRelative(earliest: earliest, latest: latest);
                  setState(() => _selectedRange = range);
                  _handleOk();
                }
              },
            ))
      ])
    ]);
    return body;
  }

  Future<DateTime?> _selectDate(
      BuildContext context, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2099));
    return picked;
  }

  Widget _buildPanelBodyDateRange(BuildContext context) {
    final earliest = _selectedRange != null && _selectedRange!.earliest != null
        ? _dateFormat.format(_selectedRange!.earliest!)
        : null;
    final latest = _selectedRange != null && _selectedRange!.latest != null
        ? _dateFormat.format(_selectedRange!.latest!)
        : null;
    _earliestDate = _selectedRange != null && _selectedRange!.earliest != null
        ? _selectedRange!.earliest
        : null;
    _latestDate = _selectedRange != null && _selectedRange!.latest != null
        ? _selectedRange!.latest
        : null;

    final col1 = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text("EARLIEST", style: _headStyle),
          ),
          CustomDropdownButton(
            hint: "Select date",
            value: earliest,
            iconSize: 24,
            isDense: false,
            underline: Container(
              height: 1,
              color: Colors.blueAccent,
            ),
            onTap: () async {
              final date = await _selectDate(context, _earliestDate);
              if (date != null) {
                setState(() {
                  _earliestDate = date;
                  _selectedRange = DateTimeRangeFixed(
                      earliest: _earliestDate, latest: _latestDate);
                });
              }
            },
          )
        ]);

    final col2 = Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text("LATEST", style: _headStyle),
              ),
              CustomDropdownButton(
                hint: "Select date",
                value: latest,
                iconSize: 24,
                isDense: false,
                underline: Container(
                  height: 1,
                  color: Colors.blueAccent,
                ),
                onTap: () async {
                  final date = await _selectDate(context, _latestDate);
                  if (date != null) {
                    setState(() {
                      _latestDate = date;
                      _selectedRange = DateTimeRangeFixed(
                          earliest: _earliestDate, latest: _latestDate);
                    });
                  }
                },
              )
            ]));

    final selections = Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(children: <Widget>[col1, col2]));

    final body =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      selections,
      Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        TextButton(
          // textTheme: ButtonTextTheme.accent,
          child: const Text("CANCEL"),
          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            _handleCancel();
          },
        ),
        Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              // textTheme: ButtonTextTheme.accent,
              child: const Text("APPLY"),
              // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                if (_earliestDate != null) {
                  final range = DateTimeRangeFixed(
                      earliest: _earliestDate, latest: _latestDate);
                  setState(() => _selectedRange = range);
                  _handleOk();
                }
              },
            ))
      ])
    ]);
    return body;
  }

  Widget _buildPanelBody(BuildContext context, _PanelIndex index) {
    switch (index) {
      case _PanelIndex.presets:
        return _buildPanelBodyPresets(context);
      case _PanelIndex.relative:
        return _buildPanelBodyRelative(context);
      case _PanelIndex.dateRange:
        return _buildPanelBodyDateRange(context);
      default:
        return const Text("_buildPanelBody: unknown index");
    }
  }

  Widget _buildPanelHeader(BuildContext context, int index) {
    return ListTile(
        selected: false,
        dense: false,
        title: Text(_listTitles[index], style: _headStyle));
  }

  ExpansionPanelRadio _buildExpansionPanel(
      BuildContext context, _PanelIndex index) {
    return ExpansionPanelRadio(
      value: index.index,
      headerBuilder: (BuildContext context, bool isExpanded) =>
          _buildPanelHeader(context, index.index),
      body: _buildPanelBody(context, index),
      canTapOnHeader: true,
    );
  }

  Widget _buildPanel(BuildContext context) {
    return ExpansionPanelList.radio(
      initialOpenPanelValue: _expandedPanelIndex,
      children: [
        _buildExpansionPanel(context, _PanelIndex.presets),
        _buildExpansionPanel(context, _PanelIndex.relative),
        _buildExpansionPanel(context, _PanelIndex.dateRange)
      ],
      expansionCallback: (panelIndex, isExpanded) {
        // print("expansion: $panelIndex, $isExpanded");
        setState(() {
          // _expandedPanelIndex = isExpanded ? panelIndex : null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Constrain the textScaleFactor to the largest supported value to prevent
    // layout issues.
    final double textScaleFactor =
        math.min(MediaQuery.of(context).textScaleFactor, 1.3);

    _linkStyle = TextStyle(
        color: Colors.blue.shade900,
        fontSize: Theme.of(context).textTheme.button!.fontSize,
        fontWeight: Theme.of(context).textTheme.button!.fontWeight);

    final Size dialogSize = _dialogSize(context) * textScaleFactor;
    final DialogTheme dialogTheme = Theme.of(context).dialogTheme;
    return Dialog(
      backgroundColor: Colors.grey[200],
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      // The default dialog shape is radius 2 rounded rect, but the spec has
      // been updated to 4, so we will use that here for the Date Picker, but
      // only if there isn't one provided in the theme.
      shape: dialogTheme.shape ??
          const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: textScaleFactor,
          ),
          child: Builder(builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Container(
                child: _buildPanel(context),
              ),
            );
          }),
        ),
      ),
    );
  }
}
