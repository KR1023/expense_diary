import 'package:flutter/material.dart';
import 'package:expense_diary/component/calendar/expense_calendar.dart';
import 'package:expense_diary/component/expense_by_date.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarScreenState();

}

class _CalendarScreenState extends State<CalendarScreen> {

  DateTime selectedDate = DateTime.now();

  void onTapDate(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Container(
              child: ExpenseCalendar(selectedDate: selectedDate, onTapDate: onTapDate)
          )
        ),
        Expanded(
          child: ExpenseByDate(selectedDate: selectedDate)
        )
      ],
    );
  }
}