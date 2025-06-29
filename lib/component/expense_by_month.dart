import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/expense_by_week.dart';

class ExpenseByMonth extends StatefulWidget {
  final DateTime selectedDate;

  const ExpenseByMonth({
    required this.selectedDate
  });

  @override
  State<StatefulWidget> createState() => _ExpenseByMonthState();
}

class _ExpenseByMonthState extends State<ExpenseByMonth> {
  final numberFormat = NumberFormat('#,###원');


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   '${widget.selectedDate.month}월 지출',
                   style:  TextStyle(
                       fontSize: 25,
                       fontWeight: FontWeight.w600
                   ),
                 ),
                 StreamBuilder<int>(
                   stream: GetIt.I<LocalDatabase>().selectMonthExpense(widget.selectedDate),
                   builder: (context, snapshot) {
                     if(!snapshot.hasData) {
                       return Text(
                         "0원",
                         style: textTheme.bodyMedium
                       );
                     }

                     return Text(
                       numberFormat.format(snapshot.data),
                       style: textTheme.bodyMedium
                     );
                   }
                 )
               ]
            )
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: ExpenseByWeek(selectedDate: widget.selectedDate)
            )
          )
        ],
      )
    );
  }
}