class RecurringSchedule {
  const RecurringSchedule._();

  static DateTime calculateNextRunDate({
    required DateTime current,
    required String frequency,
    required int interval,
  }) {
    switch (frequency) {
      case 'daily':
        return current.add(Duration(days: interval));
      case 'weekly':
        return current.add(Duration(days: 7 * interval));
      case 'monthly':
        return _addMonthsClamped(current, interval);
      case 'yearly':
        return _addYearsClamped(current, interval);
      default:
        return current.add(Duration(days: interval));
    }
  }

  static DateTime _addMonthsClamped(DateTime date, int months) {
    final rawMonth = date.month + months;
    final year = date.year + (rawMonth - 1) ~/ 12;
    final month = ((rawMonth - 1) % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day);
  }

  static DateTime _addYearsClamped(DateTime date, int years) {
    final year = date.year + years;
    final lastDay = DateTime(year, date.month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, date.month, day);
  }
}
