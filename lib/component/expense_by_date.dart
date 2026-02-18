import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/expense_card.dart';
import 'package:expense_diary/const/app_colors.dart';

class ExpenseByDate extends StatefulWidget{
  final DateTime selectedDate;

  const ExpenseByDate({
    required this.selectedDate
  });

  @override
  State<StatefulWidget> createState() => _ExpenseByDateState();
}

class _ExpenseByDateState extends State<ExpenseByDate> {
  final dateFormat = DateFormat('yyyy.MM.dd');
  final formatForSearch = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
                border: Border.all(color: AppColors.outlineOf(context), width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dateFormat.format(widget.selectedDate).toString()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: GetIt.I<LocalDatabase>()
                        .watchExpense(DateTime.parse(formatForSearch.format(widget.selectedDate))),
                    builder: (context, snapshot) {
                      final numberFormat = NumberFormat('#,###');
                      int totalExpense = 0;

                      final data = snapshot.data;
                      if (data == null || data.isEmpty) {
                        return Text(
                          "지출 합계 : 0원",
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.mutedOf(context)),
                        );
                      }

                      for (var e in data) {
                        final expense = e['expenses'] as Expense;
                        totalExpense += expense.expense;
                      }

                      return Text(
                        "합계 : ${numberFormat.format(totalExpense)}원",
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: GetIt.I<LocalDatabase>().watchExpense(DateTime.parse(formatForSearch.format(widget.selectedDate))),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData || snapshot.data!.isEmpty){
                          return Center(
                              child: Text(
                                  '지출 내역이 없습니다!',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: AppColors.mutedOf(context),
                                  )
                              )
                          );
                        }
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final expense = snapshot.data![index]['expenses'];
                              final category = snapshot.data![index]['category'];

                              return Padding(
                                padding: EdgeInsets.only(top: 0, bottom: 12),
                                child: ExpenseCard(
                                  expenseId: expense.id,
                                  category: category,
                                  expenseName: expense.expenseName,
                                  expense: expense.expense,
                                  expenseDate: expense.expenseDate,
                                  expenseDetail: expense.expenseDetail!,
                                ),
                              );
                            }
                        );
                      }
                  )
                )

              )
            )
          ],
        )
      )
    );
  }
}
