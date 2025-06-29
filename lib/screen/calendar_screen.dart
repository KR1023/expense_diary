import 'package:flutter/material.dart';
import 'package:expense_diary/component/calendar/expense_calendar.dart';
import 'package:expense_diary/component/expense_by_date.dart';
import 'package:expense_diary/component/expense_by_month.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarScreenState();

}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  final PageController _pageController= PageController(initialPage: 0);

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
          child: PageView(
            controller: _pageController,
            children: PageViewChildren()
          )
          // child: ExpenseByDate(selectedDate: selectedDate)
        )
      ],
    );
  }

  List<Widget> PageViewChildren(){
    return [
      ExpenseByDate(selectedDate: selectedDate),
      ExpenseByMonth(selectedDate: selectedDate)
    ];
  }
}