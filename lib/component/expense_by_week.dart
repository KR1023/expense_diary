import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/const/app_colors.dart';

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
            _WeekRow(
              label: '1주차',
              child: getWeeklyExpenses(firstWeek.first, firstWeek.last),
            ),
            SizedBox(height: 8),
            _WeekRow(
              label: '2주차',
              child: getWeeklyExpenses(secondWeek.first, secondWeek.last),
            ),
            SizedBox(height: 8),
            _WeekRow(
              label: '3주차',
              child: getWeeklyExpenses(thirdWeek.first, thirdWeek.last),
            ),
            SizedBox(height: 8),
            _WeekRow(
              label: '4주차',
              child: getWeeklyExpenses(fourthWeek.first, fourthWeek.last),
            ),
            SizedBox(height: 8),
            fifthWeek.length > 0
                ? _WeekRow(
                    label: '5주차',
                    child: getWeeklyExpenses(fifthWeek.first, fifthWeek.last),
                  )
                : Container(),
            SizedBox(height: 8),
            sixthWeek.length > 0
                ? _WeekRow(
                    label: '6주차',
                    child: getWeeklyExpenses(sixthWeek.first, sixthWeek.last),
                  )
                : Container()
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
              '0원',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.muted),
          );
        }

        return Text(
          numberFormat.format(snapshot.data),
          style: Theme.of(context).textTheme.bodyLarge,
        );
      }
    );
  }
}

class _WeekRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _WeekRow({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          child,
        ],
      ),
    );
  }
}
