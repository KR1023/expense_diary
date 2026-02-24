class KstWeekKey {
  const KstWeekKey._();

  static const Duration kstOffset = Duration(hours: 9);

  /// Returns ISO week key in `YYYY-WW` format using Asia/Seoul (KST) week boundary.
  ///
  /// Boundary rule: Monday 00:00 KST.
  static String fromDateTime(DateTime dateTime) {
    final kst = toKst(dateTime);
    final kstDate = DateTime.utc(kst.year, kst.month, kst.day);
    final iso = _isoWeekOfDate(kstDate);
    return '${iso.year}-${iso.week.toString().padLeft(2, '0')}';
  }

  static String now({DateTime? now}) => fromDateTime(now ?? DateTime.now());

  /// Converts an instant to KST wall time.
  ///
  /// If [dateTime] is local-time based, it is first converted to UTC, then shifted to KST.
  static DateTime toKst(DateTime dateTime) {
    final utc = dateTime.isUtc ? dateTime : dateTime.toUtc();
    return utc.add(kstOffset);
  }

  /// Returns the start of the current ISO week in KST (Monday 00:00 KST).
  static DateTime startOfWeekKst(DateTime dateTime) {
    final kst = toKst(dateTime);
    final weekday = kst.weekday; // Mon=1 ... Sun=7
    return DateTime(kst.year, kst.month, kst.day - (weekday - 1));
  }

  static ({int year, int week}) _isoWeekOfDate(DateTime dateUtcMidnight) {
    final weekday = dateUtcMidnight.weekday; // Mon=1 ... Sun=7
    final thursday = dateUtcMidnight.add(Duration(days: 4 - weekday));
    final isoYear = thursday.year;
    final firstThursday = _firstIsoThursdayOfYear(isoYear);
    final week = ((thursday.difference(firstThursday).inDays) ~/ 7) + 1;
    return (year: isoYear, week: week);
  }

  static DateTime _firstIsoThursdayOfYear(int year) {
    final jan4 = DateTime.utc(year, 1, 4);
    final weekday = jan4.weekday;
    return jan4.add(Duration(days: 4 - weekday));
  }
}
