import 'package:intl/intl.dart';

import 'date_time_relative.dart';

abstract class DateTimeRangePhrase {
  DateTime? get earliest;
  DateTime? get latest;

  String? phrase();

  static DateFormat get dateFormat => DateFormat('MMM d, y');
}

class DateTimeRangeFixed implements DateTimeRangePhrase {
  @override
  final DateTime? earliest;
  @override
  final DateTime? latest;
  const DateTimeRangeFixed({required this.earliest, required this.latest});

  @override
  String phrase() {
    final early = earliest == null ? 'now' : DateTimeRangePhrase.dateFormat.format(earliest!);
    final late = latest == null ? 'now' : DateTimeRangePhrase.dateFormat.format(latest!);
    return "$early - $late";
  }

  @override
  String toString() {
    return "DateTimeRangeFixed(earliest=$earliest, latest=$latest)";
  }
}

/// Use the earliest and latest modifiers to specify custom and
/// relative time ranges.
///
/// Examples:
/// * last year:        DateTimeRange(earliest: '-1y@-y', latest: '-1y@y')
/// * the last 5 years: DateTimeRange(earliest: '-5y@-d', latest: 'now')
/// * this year:        DateTimeRange(earliest: '@-y',    latest: 'now')
/// * the last 7 days:  DateTimeRange(earliest: '-7d@-d', latest: 'now')

class DateTimeRangeRelative implements DateTimeRangePhrase {
  final String _earliest; // time modifier
  final String _latest; // time modifier
  final DateTime? base; // the base date and time, normally used for testing

  String get earliestModifier => _earliest;
  String get latestModifier => _latest;
  @override
  DateTime? get earliest => (base ?? DateTime.now()).relative(_earliest);

  @override
  DateTime? get latest => (base ?? DateTime.now()).relative(_latest);

  const DateTimeRangeRelative({required String earliest, required String latest, this.base})
      : _earliest = earliest,
        _latest = latest;

  @override
  String? phrase() {
    final parser = DateTimeRelativeParser();
    final parsedEarliest = parser.relativeParse(_earliest);
    final parsedLatest = parser.relativeParse(_latest);

    if (parsedEarliest.error || parsedLatest.error) {
      return null;
    }

    String prefix;
    int? count;
    String suffix;

    if (parsedEarliest.now && parsedLatest.now) {
      return "now";
    } else if (parsedLatest.now &&
        parsedEarliest.neg! &&
        (parsedEarliest.snapTimeUnitMatch == null || parsedEarliest.snapTimeUnitMatch == 'd')) {
      prefix = "Last";
      count = parsedEarliest.timeInt;
      suffix = parser.timeUnitMessage(parsedEarliest.timeUnitMatch, count == 1);
    } else if (parsedEarliest.now &&
        !parsedLatest.neg! &&
        (parsedLatest.snapTimeUnitMatch == null || parsedLatest.snapTimeUnitMatch == 'd')) {
      prefix = "Next";
      count = parsedLatest.timeInt;
      suffix = parser.timeUnitMessage(parsedLatest.timeUnitMatch, count == 1);
    } else if (parsedEarliest.neg == parsedLatest.neg &&
        parsedEarliest.timeInt == parsedLatest.timeInt &&
        parsedEarliest.timeUnitMatch == parsedLatest.timeUnitMatch &&
        parsedEarliest.snapTimeUnitMatch == parsedLatest.snapTimeUnitMatch &&
        parsedEarliest.snapNeg &&
        !parsedLatest.snapNeg) {
      prefix = "Previous";
      count = 0;
      suffix = parser.timeUnitMessage(parsedEarliest.timeUnitMatch, true);
    } else if (parsedLatest.now &&
        parsedEarliest.neg! &&
        parsedEarliest.timeInt == 9999 &&
        parsedEarliest.timeUnitMatch == "y") {
      return "All time";
    } else {
      final earliest = this.earliest;
      final latest = this.latest;
      final early = earliest == null ? 'now' : DateTimeRangePhrase.dateFormat.format(earliest);
      final late = latest == null ? 'now' : DateTimeRangePhrase.dateFormat.format(latest);
      return "$early - $late";
    }

    final countMsg = count == 0 ? "" : "$count ";
    final message = "$prefix $countMsg$suffix";
    return message;
  }

  @override
  String toString() {
    return "DateTimeRangeFixed(earliest=$earliest, latest=$latest)";
  }
}

///
/// Provides preset values for [DateTimeRangeRelative].
///
/// Presets:
/// * [last7Days] - the last 7 days
/// * [last30Days] - the last 30 days
/// * [last3Months] - the last 3 months
/// * [last6Months] - the last 6 months
/// * [last9Months] - the last 9 months
/// * [last12Months] - the last 12 months
/// * [last5Years] - the last 5 years
/// * [last10Years] - the last 10 years
/// * [last15Years] - the last 15 years
/// * [last20Years] - the last 20 years
/// * [last25Years] - the last 25 years
/// * [last30Years] - the last 30 years
/// * [prevWeek] - the previous week
/// * [prevMonth] - the previous month
/// * [prevYear] - the previous year
/// * [allTime] - all time
///
class DateTimeRangePreset {
  static const last7Days = DateTimeRangeRelative(earliest: "-7d@-d", latest: "now");
  static const last30Days = DateTimeRangeRelative(earliest: "-30d@-d", latest: "now");
  static const last3Months = DateTimeRangeRelative(earliest: "-3m@-d", latest: "now");
  static const last6Months = DateTimeRangeRelative(earliest: "-6m@-d", latest: "now");
  static const last9Months = DateTimeRangeRelative(earliest: "-9m@-d", latest: "now");
  static const last12Months = DateTimeRangeRelative(earliest: "-12m@-d", latest: "now");
  static const last5Years = DateTimeRangeRelative(earliest: "-5y@-d", latest: "now");
  static const last10Years = DateTimeRangeRelative(earliest: "-10y@-d", latest: "now");
  static const last15Years = DateTimeRangeRelative(earliest: "-15y@-d", latest: "now");
  static const last20Years = DateTimeRangeRelative(earliest: "-20y@-d", latest: "now");
  static const last25Years = DateTimeRangeRelative(earliest: "-25y@-d", latest: "now");
  static const last30Years = DateTimeRangeRelative(earliest: "-30y@-d", latest: "now");
  static const prevWeek = DateTimeRangeRelative(earliest: "-1w@-w", latest: "-1w@w");
  static const prevMonth = DateTimeRangeRelative(earliest: "-1m@-m", latest: "-1m@m");
  static const prevYear = DateTimeRangeRelative(earliest: "-1y@-y", latest: "-1y@y");
  static const allTime = DateTimeRangeRelative(earliest: "-9999y@-y", latest: "now");
}
