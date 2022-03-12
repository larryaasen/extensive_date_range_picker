// ignore_for_file: avoid_print

import 'package:extensive_date_range_picker/src/date_time_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();
  final tzName = now.timeZoneName;
  final tzOffset = now.timeZoneOffset;
  final isUTC = tzOffset.inHours == 0 && tzOffset.inMinutes == 0;
  print('Time zone name: $tzName, isUTC=$isUTC, utc=${now.isUtc}, offset=$tzOffset');

  test('test previous year', () {
    final range =
        DateTimeRangeRelative(earliest: "-1y@-y", latest: "-1y@y", base: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, DateTime(2016, 1, 1));
    expect(range.latest, DateTime(2016, 12, 31, 23, 59, 59, 999));
    expect(range.phrase(), 'Previous year');
  });

  test('test the last 5 years', () {
    final range =
        DateTimeRangeRelative(earliest: "-5y@-d", latest: "now", base: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, DateTime(2012, 9, 7));
    expect(range.latest, DateTime(2017, 9, 7, 17, 30));
    expect(range.phrase(), 'Last 5 years');
  });

  test('test 3 months from now', () {
    final range = DateTimeRangeRelative(earliest: "3m@m", latest: "4m@m", base: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, DateTime(2017, 12, 31, 23, 59, 59, 999));
    expect(range.latest, DateTime(2018, 1, 31, 23, 59, 59, 999));
    expect(range.phrase(), 'Dec 31, 2017 - Jan 31, 2018');
  });

  test('test the last 50 years', () {
    final range =
        DateTimeRangeRelative(earliest: "-50y@-y", latest: "now", base: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, DateTime(1967, 1, 1));
    expect(range.latest, DateTime(2017, 9, 7, 17, 30));
    expect(range.phrase(), 'Jan 1, 1967 - Sep 7, 2017');
  });

  test('test the last 1,000 years', () {
    final range =
        DateTimeRangeRelative(earliest: "-1000y@-y", latest: "now", base: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, DateTime(1017, 1, 1));
    expect(range.latest, DateTime(2017, 9, 7, 17, 30));
    expect(range.phrase(), 'Jan 1, 1017 - Sep 7, 2017');
  });

  test('test the last 5000 years', () {
    final range =
        DateTimeRangeRelative(earliest: "-5000y@-y", latest: "now", base: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, DateTime(-2983, 1, 1));
    expect(range.latest, DateTime(2017, 9, 7, 17, 30));
    expect(range.phrase(), 'Jan 1, 2983 - Sep 7, 2017');
  });

  test('test the last 9,999 years', () {
    final range =
        DateTimeRangeRelative(earliest: "-9999y@-y", latest: "now", base: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, DateTime(-7982, 1, 1));
    expect(range.latest, DateTime(2017, 9, 7, 17, 30));
    expect(range.phrase(), 'All time');
  });

  void e(dynamic actual, dynamic matcher) => expect(actual, matcher);

  test('test relative phrase', () {
    e(const DateTimeRangeRelative(earliest: "now", latest: "now").phrase(), "now");
    e(const DateTimeRangeRelative(earliest: "-1d", latest: "now").phrase(), "Last 1 day");
    e(const DateTimeRangeRelative(earliest: "-2d", latest: "now").phrase(), "Last 2 days");
    e(const DateTimeRangeRelative(earliest: "-12d", latest: "now").phrase(), "Last 12 days");
    e(const DateTimeRangeRelative(earliest: "-99d", latest: "now").phrase(), "Last 99 days");
    e(const DateTimeRangeRelative(earliest: "now", latest: "1d").phrase(), "Next 1 day");
    e(const DateTimeRangeRelative(earliest: "now", latest: "2d").phrase(), "Next 2 days");
    e(const DateTimeRangeRelative(earliest: "now", latest: "12d").phrase(), "Next 12 days");
    e(const DateTimeRangeRelative(earliest: "now", latest: "112d").phrase(), "Next 112 days");

    if (!isUTC) {
      // Daylight Saving Time 2021 - 3/14/2021
      expect(
          DateTimeRangeRelative(
            earliest: "-4d",
            latest: "4d",
            base: DateTime(2021, 3, 18),
          ).phrase(),
          "Mar 13, 2021 - Mar 22, 2021");

      expect(
          DateTimeRangeRelative(
            earliest: "-1d",
            latest: "1d",
            base: DateTime(2021, 3, 18),
          ).phrase(),
          "Mar 17, 2021 - Mar 19, 2021");
      expect(
          DateTimeRangeRelative(
            earliest: "-2d",
            latest: "2d",
            base: DateTime(2021, 3, 18),
          ).phrase(),
          "Mar 16, 2021 - Mar 20, 2021");
      expect(
          DateTimeRangeRelative(
            earliest: "-3d",
            latest: "3d",
            base: DateTime(2021, 3, 18),
          ).phrase(),
          "Mar 15, 2021 - Mar 21, 2021");
      expect(DateTimeRangeRelative(earliest: "-44d", latest: "44d", base: DateTime(2021, 4, 18)).phrase(),
          "Mar 4, 2021 - Jun 1, 2021");
    }

    expect(
        DateTimeRangeRelative(
          earliest: "-8d",
          latest: "8d",
          base: DateTime(2021, 4, 18),
        ).phrase(),
        "Apr 10, 2021 - Apr 26, 2021");
    expect(
        DateTimeRangeRelative(
          earliest: "-10d",
          latest: "10d",
          base: DateTime(2021, 4, 18),
        ).phrase(),
        "Apr 8, 2021 - Apr 28, 2021");
  });

  test('test relative phrase errors', () {
    e(const DateTimeRangeRelative(earliest: "", latest: "").phrase(), isNull);
    e(const DateTimeRangeRelative(earliest: "now", latest: "").phrase(), isNull);
    e(const DateTimeRangeRelative(earliest: "", latest: "now").phrase(), isNull);
  });

  test('test relative phrase presets', () {
    expect(DateTimeRangePreset.last7Days.phrase(), "Last 7 days");
    expect(DateTimeRangePreset.last30Days.phrase(), "Last 30 days");
    expect(DateTimeRangePreset.last3Months.phrase(), "Last 3 months");
    expect(DateTimeRangePreset.last6Months.phrase(), "Last 6 months");
    expect(DateTimeRangePreset.last9Months.phrase(), "Last 9 months");
    expect(DateTimeRangePreset.last12Months.phrase(), "Last 12 months");
    expect(DateTimeRangePreset.last5Years.phrase(), "Last 5 years");
    expect(DateTimeRangePreset.last10Years.phrase(), "Last 10 years");
    expect(DateTimeRangePreset.last15Years.phrase(), "Last 15 years");
    expect(DateTimeRangePreset.last20Years.phrase(), "Last 20 years");
    expect(DateTimeRangePreset.last25Years.phrase(), "Last 25 years");
    expect(DateTimeRangePreset.last30Years.phrase(), "Last 30 years");
    expect(DateTimeRangePreset.prevWeek.phrase(), "Previous week");
    expect(DateTimeRangePreset.prevMonth.phrase(), "Previous month");
    expect(DateTimeRangePreset.prevYear.phrase(), "Previous year");
    expect(DateTimeRangePreset.allTime.phrase(), "All time");
  });

  test('test fixed range same', () {
    final range =
        DateTimeRangeFixed(earliest: DateTime(2017, 9, 7, 17, 30), latest: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, DateTime(2017, 9, 7, 17, 30));
    expect(range.latest, DateTime(2017, 9, 7, 17, 30));
    expect(range.phrase(), 'Sep 7, 2017 - Sep 7, 2017');
  });

  test('test fixed range future', () {
    final range = DateTimeRangeFixed(earliest: null, latest: DateTime(2017, 9, 7, 17, 30));
    expect(range.earliest, null);
    expect(range.latest, DateTime(2017, 9, 7, 17, 30));
    expect(range.phrase(), 'now - Sep 7, 2017');
  });

  test('test fixed range past', () {
    final range = DateTimeRangeFixed(earliest: DateTime(2017, 9, 7, 17, 30), latest: null);
    expect(range.earliest, DateTime(2017, 9, 7, 17, 30));
    expect(range.latest, null);
    expect(range.phrase(), 'Sep 7, 2017 - now');
  });
}
