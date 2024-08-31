import 'package:jiffy/jiffy.dart';

/// A [DateTime] extension that uses a [relative] time modifer.
extension DateTimeRelative on DateTime? {
  /// Constructs a new [DateTime] instance based on [modifier].
  ///
  /// The [modifier] string must not be `null`. Returns `null` if the
  /// [modifier] string cannot be parsed.
  ///
  /// This function parses the [modifier] string using this format:
  ///
  /// `[+|-|blank]<integer><unit>@[+|-|blank]<unit>`
  ///
  /// When the `sign` character is missing, '+' is assumed.
  ///
  /// For the instance date and time, use `now`.
  ///
  /// Examples:
  /// *  '-1d' => subtract one day
  /// *  '+1w' => add one week
  /// *  '-6m' => subtract six months
  /// *  '2y'  => add two years
  /// *  'now' => current time in this instance
  ///
  /// Code examples:
  /// *  `DateTime.now().relative('-1d')` => yesterday
  /// *  `DateTime.now().relative('@w')` => Sunday
  /// *  `DateTime.now().relative('-1y@y')` => Last New Year's Eve
  /// *  `DateTime.now().relative('@-y')` => Last New Year's Day
  /// *  `DateTime(2020, 4, 2, 12).relative('-1d')` => noon on April fool's day
  /// *  `DateTime(2001, 9, 16).relative("-5d")` => 9/11
  ///
  /// The `@` character indicates that the instance should adjust (snap)
  /// to the start (-) or end (+) of the unit.
  ///
  /// Examples:
  /// *  '@-d' => start of the day
  /// *  '@+w' => end of the week
  /// *  '@m'  => end of the month
  /// *  '@-y  => start of the year
  ///
  /// Code examples:
  /// *  `DateTime.now().relative('@-y')`     => start of this year
  /// *  `DateTime.now().relative('+y')`      => end of this year
  /// *  `DateTime.now().relative('-1y@-y')`  => start of last year
  /// *  `DateTime.now().relative('-1y@+y')`  => end of last year
  ///
  /// BNF:
  /// * modifier       ::= time_modifier snap_to
  /// * time_modifier  ::= <empty> | sign_opt time_integer unit
  /// * unit           ::= 'd' | 'w' | 'm' | 'y'
  /// * time_integer   ::= digit{*}
  /// * sign           ::= <empty> | '+' | '-'
  /// * sign_opt       ::=  <empty> | sign
  /// * snap_to        ::= <empty> | snap
  /// * snap           ::= '@' unit snap_modifier
  /// * snap_modifier  ::= <empty> | time_modifier
  ///
  /// Snap moves to start or end of time unit after applying time modifier. You
  /// specify the start of a time unit with '-' character, and end of the time
  /// unit with the '+' character, and no character defaults to end.

  /// Snap examples:
  /// * Start of current month: @-m
  /// * End of current month: @+m or @m
  /// * Start of previous month: -1m@-m
  /// * End of previous month: -1m@+m or -1m@m
  ///
  /// * Start of current year: @-y
  /// * End of current year: @+y or @y
  /// * Start of previous year: -1y@-y
  /// * End of previous year: -1y@+y or -1y@y
  DateTime? relative(String? modifier) {
    final parser = DateTimeRelativeParser();
    final parsed = parser.relativeParse(modifier);
    if (parsed.error) {
      return null;
    }
    if (parsed.now) {
      return this;
    }

    var jif =
        Jiffy.parseFromMillisecondsSinceEpoch(this!.millisecondsSinceEpoch);
    if (parsed.timeUnitMatch == 'd') {
      jif = parsed.neg!
          ? jif.subtract(days: parsed.timeInt!)
          : jif.add(days: parsed.timeInt!);
    } else if (parsed.timeUnitMatch == 'w') {
      jif = parsed.neg!
          ? jif.subtract(weeks: parsed.timeInt!)
          : jif.add(weeks: parsed.timeInt!);
    } else if (parsed.timeUnitMatch == 'm') {
      jif = parsed.neg!
          ? jif.subtract(months: parsed.timeInt!)
          : jif.add(months: parsed.timeInt!);
    } else if (parsed.timeUnitMatch == 'y') {
      jif = parsed.neg!
          ? jif.subtract(years: parsed.timeInt!)
          : jif.add(years: parsed.timeInt!);
    }
    if (parsed.snapTimeUnitMatch != null) {
      if (parsed.snapTimeUnitMatch == 'd') {
        jif = parsed.snapNeg ? jif.startOf(Unit.day) : jif.endOf(Unit.day);
      } else if (parsed.snapTimeUnitMatch == 'w') {
        jif = parsed.snapNeg ? jif.startOf(Unit.week) : jif.endOf(Unit.week);
      } else if (parsed.snapTimeUnitMatch == 'm') {
        jif = parsed.snapNeg ? jif.startOf(Unit.month) : jif.endOf(Unit.month);
      } else if (parsed.snapTimeUnitMatch == 'y') {
        jif = parsed.snapNeg ? jif.startOf(Unit.year) : jif.endOf(Unit.year);
      }
    }
    return jif.dateTime;
  }
}

class DateTimeRelativeParser {
  DateTimeRelativeParsed relativeParse(String? modifier) {
    if (modifier == null || modifier.isEmpty) {
      return const DateTimeRelativeParsed(
          error: true, errorMessage: "modifier null or empty");
    }

    if (modifier == 'now') {
      return const DateTimeRelativeParsed(now: true);
    }

    DateTimeRelativeParsed parsed;

    try {
      final regex = _parseFormat;
      final match = regex.firstMatch(modifier);
      if (match == null || match.start != 0 || match.end != modifier.length) {
        return const DateTimeRelativeParsed(
            error: true, errorMessage: "no match");
      }

      final signMatch = match.namedGroup("sign");
      final timeIntMatch = match.namedGroup("time_int");
      final timeUnitMatch = match.namedGroup("time_unit");

      final neg = signMatch == "-";
      int? timeInt;

      if (timeIntMatch != null && timeUnitMatch != null) {
        timeInt = int.parse(timeIntMatch);
        if (!isValidTimeUnit(timeUnitMatch)) {
          return DateTimeRelativeParsed(
              error: true, errorMessage: "not valid time unit: $timeUnitMatch");
        }
      }

      final snapSignMatch = match.namedGroup("snap_sign");
      final snapNeg = snapSignMatch == "-";
      final snapTimeUnitMatch = match.namedGroup("snap_time_unit");

      if (snapTimeUnitMatch != null) {
        if (!isValidTimeUnit(snapTimeUnitMatch)) {
          return DateTimeRelativeParsed(
              error: true,
              errorMessage: "not valid snap time unit: $snapTimeUnitMatch");
        }
      }

      parsed = DateTimeRelativeParsed(
          neg: neg,
          timeInt: timeInt,
          timeUnitMatch: timeUnitMatch,
          snapNeg: snapNeg,
          snapTimeUnitMatch: snapTimeUnitMatch);
    } catch (e) {
      parsed = DateTimeRelativeParsed(error: true, errorMessage: e.toString());
    }
    return parsed;
  }

  bool isValidTimeUnit(String timeUnit) {
    return timeUnit == 'd' ||
        timeUnit == 'w' ||
        timeUnit == 'm' ||
        timeUnit == 'y';
  }

  String timeUnitMessage(String? timeUnit, bool single) {
    if (single) {
      return timeUnit == 'd'
          ? 'day'
          : timeUnit == 'w'
              ? 'week'
              : timeUnit == 'm'
                  ? 'month'
                  : timeUnit == 'y'
                      ? 'year'
                      : '';
    } else {
      return timeUnit == 'd'
          ? 'days'
          : timeUnit == 'w'
              ? 'weeks'
              : timeUnit == 'm'
                  ? 'months'
                  : timeUnit == 'y'
                      ? 'years'
                      : '';
    }
  }

  static const _timeModifier =
      r'^((?<sign>[+-]?)(?<time_int>[\d]+)(?<time_unit>[dwmy]{1}))?';
  static const _snapTo =
      r'((?:[@]{1})(?<snap_sign>[+-]?)(?<snap_time_unit>[dwmy]{1}))?$';
  static const _modifier = _timeModifier + _snapTo;
  static final RegExp _parseFormat = RegExp(_modifier);
}

class DateTimeRelativeParsed {
  final bool error;
  final String? errorMessage;
  final bool now;
  final bool? neg;
  final int? timeInt;
  final String? timeUnitMatch;
  final bool snapNeg;
  final String? snapTimeUnitMatch;

  const DateTimeRelativeParsed(
      {this.error = false,
      this.errorMessage,
      this.now = false,
      this.neg,
      this.timeInt,
      this.timeUnitMatch,
      this.snapNeg = false,
      this.snapTimeUnitMatch});
}
