import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';

class ExpenseByWeek extends StatelessWidget {
  final DateTime selectedDate;

  ExpenseByWeek({
    required this.selectedDate
  });

  @override
  Widget build(BuildContext context) {
    int year = selectedDate.year;
    int month = selectedDate.month;

    DateTime lastDay = DateTime(year, month + 1, 0);

    DateTime? currentDate = null;

    List<DateTime> firstWeek = [];
    List<DateTime> secondWeek = [];
    List<DateTime> thirdWeek = [];
    List<DateTime> fourthWeek = [];
    List<DateTime> fifthWeek = [];
    List<DateTime> sixthWeek = [];
    int weekFlag = 1;

    for(int i = 1; i <= lastDay.day; i++) {
      currentDate = DateTime(selectedDate.year, selectedDate.month, i);
      switch(weekFlag) {
        case 1:
          firstWeek.add(currentDate);
          break;
        case 2:
          secondWeek.add(currentDate);
          break;
        case 3:
          thirdWeek.add(currentDate);
          break;
        case 4:
          fourthWeek.add(currentDate);
          break;
        case 5:
          fifthWeek.add(currentDate);
          break;
        default:
          sixthWeek.add(currentDate);
          break;
      }

      if(currentDate.weekday == 6) weekFlag ++;
    }

    return
      SingleChildScrollView(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '1주차'
                  ),
                  getWeeklyExpenses(firstWeek.first, firstWeek.last)
                ]
            ),
            SizedBox(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '2주차'
                  ),
                  getWeeklyExpenses(secondWeek.first, secondWeek.last)
                ]
            ),
            SizedBox(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '3주차'
                  ),
                  getWeeklyExpenses(thirdWeek.first, thirdWeek.last)
                ]
            ),
            SizedBox(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '4주차'
                  ),
                  getWeeklyExpenses(fourthWeek.first, fourthWeek.last)
                ]
            ),
            SizedBox(height: 5),
            fifthWeek.length > 0 ?
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '5주차'
                    ),
                    getWeeklyExpenses(fifthWeek.first, fifthWeek.last)
                  ]
              ) : Container(),
            SizedBox(height: 5),
            sixthWeek.length > 0 ?
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '6주차'
                    ),
                    getWeeklyExpenses(sixthWeek.first, sixthWeek.last)
                  ]
              ) : Container()
          ]
        )
      );
  }

  StreamBuilder<int> getWeeklyExpenses(DateTime startDate, DateTime endDate) {
    NumberFormat numberFormat = NumberFormat('#,###원');

    return StreamBuilder<int> (
      stream: GetIt.I<LocalDatabase>().selectWeekExpense(startDate, endDate),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return Text(
              '0원'
          );
        }

        return Text(
          numberFormat.format(snapshot.data)
        );
      }
    );
  }
}