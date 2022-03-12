// ignore_for_file: avoid_print

import 'package:extensive_date_range_picker/src/date_time_relative.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();
  final tzName = now.timeZoneName;
  final tzOffset = now.timeZoneOffset;
  final isUTC = tzOffset.inHours == 0 && tzOffset.inMinutes == 0;
  print('Time zone name: $tzName, isUTC=$isUTC, utc=${now.isUtc}, offset=$tzOffset');

  test('test days - daylight saving time', () {
    if (!isUTC) {
      // Daylight Saving Time 2021 - 3/14/2021
      // These tests only work when local time is ET. They do not work on UTC.

      expect(DateTime(2021, 3, 18).relative("-4d"), DateTime(2021, 3, 13, 23));
      expect(DateTime(2021, 3, 18).relative("-3d"), DateTime(2021, 3, 15));
      expect(DateTime(2021, 3, 18, 12).relative("-4d"), DateTime(2021, 3, 14, 12));

      final d1 = DateTime.utc(2021, 3, 18).relative("-4d");
      expect(d1, isNotNull);
      expect(d1!.day, 13);
      expect(d1.month, 3);
      expect(d1.year, 2021);
      expect(d1.hour, 19);
      expect(d1.minute, 0);
      expect(d1.second, 0);
      expect(d1.millisecond, 0);

      final d2 = DateTime.utc(2021, 3, 18).relative("-3d");
      expect(d2, isNotNull);
      expect(d2!.day, 14);
      expect(d2.month, 3);
      expect(d2.year, 2021);
      expect(d2.hour, 20);
      expect(d2.minute, 0);
      expect(d2.second, 0);
      expect(d2.millisecond, 0);

      final d3 = DateTime.utc(2021, 3, 18, 12).relative("-4d");
      expect(d3, isNotNull);
      expect(d3!.day, 14);
      expect(d3.month, 3);
      expect(d3.year, 2021);
      expect(d3.hour, 8);
      expect(d3.minute, 0);
      expect(d3.second, 0);
      expect(d3.millisecond, 0);
    }
  });

  test('test errors', () {
    final dt = DateTime(2017, 9, 7, 17, 30); // ==> 09/07/2017 17:30:00
    expect(dt.relative("-0d"), DateTime(2017, 9, 7, 17, 30));
    expect(dt.relative("-0a"), isNull);
    expect(dt.relative("@+d"), DateTime(2017, 9, 7, 23, 59, 59, 999));
    expect(dt.relative("@+a"), isNull);
  });

  test('test days', () {
    final dt = DateTime(2017, 9, 7, 17, 30); // ==> 09/07/2017 17:30:00
    expect(dt.relative("-0d"), DateTime(2017, 9, 7, 17, 30));
    expect(dt.relative("-1d"), DateTime(2017, 9, 6, 17, 30));
    expect(dt.relative("-10d"), DateTime(2017, 8, 28, 17, 30));
    expect(dt.relative("-100d"), DateTime(2017, 5, 30, 17, 30));
    expect(dt.relative("-400d"), DateTime(2016, 8, 3, 17, 30));
    if (!isUTC) expect(dt.relative("-1000d"), DateTime(2014, 12, 12, 16, 30));

    expect(dt.relative("+0d"), DateTime(2017, 9, 7, 17, 30));
    expect(dt.relative("+1d"), DateTime(2017, 9, 8, 17, 30));
    expect(dt.relative("1d"), DateTime(2017, 9, 8, 17, 30));
    expect(dt.relative("+10d"), DateTime(2017, 9, 17, 17, 30));
    if (!isUTC) expect(dt.relative("+100d"), DateTime(2017, 12, 16, 16, 30));
    expect(dt.relative("+400d"), DateTime(2018, 10, 12, 17, 30));
    expect(dt.relative("+1000d"), DateTime(2020, 6, 3, 17, 30));

    final date = DateTime(2017, 9, 7); // ==> 09/07/2017
    expect(date.relative("-0d"), DateTime(2017, 9, 7));
    expect(date.relative("-1d"), DateTime(2017, 9, 6));
    expect(date.relative("+1d"), DateTime(2017, 9, 8));
    expect(date.relative("-2d"), DateTime(2017, 9, 5));
    expect(date.relative("-3d"), DateTime(2017, 9, 4));
    expect(date.relative("-4d"), DateTime(2017, 9, 3));
    expect(date.relative("-5d"), DateTime(2017, 9, 2));
  });

  test('test weeks', () {
    final date = DateTime(2017, 9, 7, 17, 30); // ==> 09/07/2017 17:30:00
    expect(date.relative("-0w"), DateTime(2017, 9, 7, 17, 30));
    expect(date.relative("-1w"), DateTime(2017, 8, 31, 17, 30));
    expect(date.relative("-10w"), DateTime(2017, 6, 29, 17, 30));
    expect(date.relative("-100w"), DateTime(2015, 10, 8, 17, 30));
    expect(date.relative("+0w"), DateTime(2017, 9, 7, 17, 30));
    expect(date.relative("+1w"), DateTime(2017, 9, 14, 17, 30));
    expect(date.relative("1w"), DateTime(2017, 9, 14, 17, 30));
    if (!isUTC) expect(date.relative("+10w"), DateTime(2017, 11, 16, 16, 30));
    expect(date.relative("+100w"), DateTime(2019, 8, 8, 17, 30));
  });

  test('test months', () {
    final date = DateTime(2017, 9, 7, 17, 30); // ==> 09/07/2017 17:30:00
    expect(date.relative("-0m"), DateTime(2017, 9, 7, 17, 30));
    expect(date.relative("-1m"), DateTime(2017, 8, 7, 17, 30));
    expect(date.relative("-10m"), DateTime(2016, 11, 7, 17, 30));
    expect(date.relative("-100m"), DateTime(2009, 5, 7, 17, 30));
    expect(date.relative("+0m"), DateTime(2017, 9, 7, 17, 30));
    expect(date.relative("+1m"), DateTime(2017, 10, 7, 17, 30));
    expect(date.relative("1m"), DateTime(2017, 10, 7, 17, 30));
    expect(date.relative("+10m"), DateTime(2018, 7, 7, 17, 30));
    expect(date.relative("+100m"), DateTime(2026, 1, 7, 17, 30));
  });

  test('test years', () {
    final date = DateTime(2017, 9, 7, 17, 30); // ==> 09/07/2017 17:30:00
    expect(date.relative("-0y"), DateTime(2017, 9, 7, 17, 30));
    expect(date.relative("-1y"), DateTime(2016, 9, 7, 17, 30));
    expect(date.relative("-10y"), DateTime(2007, 9, 7, 17, 30));
    expect(date.relative("-100y"), DateTime(1917, 9, 7, 17, 30));
    expect(date.relative("+0y"), DateTime(2017, 9, 7, 17, 30));
    expect(date.relative("+1y"), DateTime(2018, 9, 7, 17, 30));
    expect(date.relative("1y"), DateTime(2018, 9, 7, 17, 30));
    expect(date.relative("+10y"), DateTime(2027, 9, 7, 17, 30));
    expect(date.relative("+100y"), DateTime(2117, 9, 7, 17, 30));

    expect(date.relative("now"), DateTime(2017, 9, 7, 17, 30));
  });

  test('test snap only', () {
    final date = DateTime(2020, 6, 5, 20, 30); // ==> 06/05/2020 20:30:00
    expect(date.relative("@d"), DateTime(2020, 6, 5, 23, 59, 59, 999));
    expect(date.relative("@+d"), DateTime(2020, 6, 5, 23, 59, 59, 999));
    expect(date.relative("@-d"), DateTime(2020, 6, 5));
    expect(date.relative("@w"), DateTime(2020, 6, 6, 23, 59, 59, 999));
    expect(date.relative("@+w"), DateTime(2020, 6, 6, 23, 59, 59, 999));
    expect(date.relative("@-w"), DateTime(2020, 5, 31));
    expect(date.relative("@m"), DateTime(2020, 6, 30, 23, 59, 59, 999));
    expect(date.relative("@+m"), DateTime(2020, 6, 30, 23, 59, 59, 999));
    expect(date.relative("@-m"), DateTime(2020, 6, 1));
    expect(date.relative("@y"), DateTime(2020, 12, 31, 23, 59, 59, 999));
    expect(date.relative("@+y"), DateTime(2020, 12, 31, 23, 59, 59, 999));
    expect(date.relative("@-y"), DateTime(2020, 1, 1));
  });

  test('test modifier and snap', () {
    final date = DateTime(2020, 6, 5, 20, 30); // ==> 06/05/2020 20:30:00
    expect(date.relative("-2d@d"), DateTime(2020, 6, 3, 23, 59, 59, 999));
    expect(date.relative("-2d@+d"), DateTime(2020, 6, 3, 23, 59, 59, 999));
    expect(date.relative("-2d@-d"), DateTime(2020, 6, 3));
    expect(date.relative("-2w@w"), DateTime(2020, 5, 23, 23, 59, 59, 999));
    expect(date.relative("-2w@+w"), DateTime(2020, 5, 23, 23, 59, 59, 999));
    expect(date.relative("-2w@-w"), DateTime(2020, 5, 17));
    expect(date.relative("-2m@m"), DateTime(2020, 4, 30, 23, 59, 59, 999));
    expect(date.relative("-2m@+m"), DateTime(2020, 4, 30, 23, 59, 59, 999));
    expect(date.relative("-2m@-m"), DateTime(2020, 4, 1));
    expect(date.relative("-2y@y"), DateTime(2018, 12, 31, 23, 59, 59, 999));
    expect(date.relative("-2y@+y"), DateTime(2018, 12, 31, 23, 59, 59, 999));
    expect(date.relative("-2y@-y"), DateTime(2018, 1, 1));
    expect(DateTime(2001, 9, 16).relative("-5d"), DateTime(2001, 9, 11)); // 9/11
  });

  test('test modifier and snap', () {
    final date = DateTime(2020, 6, 5, 20, 30); // ==> 06/05/2020 20:30:00
    expect(date.relative("-2d@d"), DateTime(2020, 6, 3, 23, 59, 59, 999));
  });

  test('test combinations', () {
    final date = DateTime(2017, 9, 7, 17, 30); // ==> 09/07/2017 17:30:00
    final newDate = date.relative("-1y").relative("-1m").relative("+1d").relative("+2m").relative("1m");
    expect(newDate, DateTime(2016, 11, 8, 17, 30));
  });

  test('test combinations with snap', () {
    final date = DateTime(2017, 9, 10, 17, 30); // ==> 09/10/2017 17:30:00
    final newDate = date.relative("-1y@-w").relative("-1m").relative("+1d").relative("-7d@m");
    expect(newDate, DateTime(2016, 7, 31, 23, 59, 59, 999));
  });

  test('test errors', () {
    final date = DateTime(2017, 9, 7, 17, 30); // ==> 09/07/2017 17:30:00
    expect(date.relative(null), isNull);
    expect(date.relative(""), isNull);
    expect(date.relative("asdf"), isNull);
    expect(date.relative("1"), isNull);
    expect(date.relative("d"), isNull);
    expect(date.relative("*1d"), isNull);
    expect(date.relative("+1dr"), isNull);
    expect(date.relative("++1d"), isNull);
    expect(date.relative("@"), isNull);
    expect(date.relative("-@w"), isNull);
    expect(date.relative("@@"), isNull);
    expect(date.relative("@-"), isNull);
    expect(date.relative("@1d"), isNull);
    expect(date.relative("@z"), isNull);
    expect(date.relative("@dz"), isNull);
  });
}
