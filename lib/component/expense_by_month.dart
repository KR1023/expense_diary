import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/expense_by_week.dart';
import 'package:expense_diary/const/app_colors.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineOf(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.selectedDate.month}월 지출',
                  style: textTheme.titleMedium,
                ),
                StreamBuilder<int>(
                  stream: GetIt.I<LocalDatabase>().selectMonthExpense(widget.selectedDate),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) {
                      return Text(
                        "0원",
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedOf(context)),
                      );
                    }

                    return Text(
                      numberFormat.format(snapshot.data),
                      style: textTheme.titleMedium,
                    );
                  }
                )
              ],
            ),
          ),
          SizedBox(height: 12),
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
