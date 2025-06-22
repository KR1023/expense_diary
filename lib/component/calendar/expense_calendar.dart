import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

class ExpenseCalendar extends StatefulWidget {
  DateTime selectedDate;
  final onTapDate;

  ExpenseCalendar({
    required this.selectedDate,
    required this.onTapDate
  });

  @override
  State<ExpenseCalendar> createState() => _ExpenseCalendarState();

}

class _ExpenseCalendarState extends State<ExpenseCalendar> {
  // widget.selectedDate = DateTime.utc(
  //   DateTime.now().year,
  //   DateTime.now().month,
  //   DateTime.now().day,
  // );

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: widget.selectedDate,
      firstDay: DateTime(1900, 1, 1),
      lastDay: DateTime(2999,12, 31),
      locale: 'ko_kr',
      onDaySelected: widget.onTapDate,
      selectedDayPredicate: (DateTime day) {
        return
          day.year == widget.selectedDate.year &&
          day.month == widget.selectedDate.month &&
          day.day == widget.selectedDate.day;
      },
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,

      ),
    );
  }
}