import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/expense_card.dart';

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
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFC8C8C8), width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${dateFormat.format(widget.selectedDate).toString()}',
                        style: TextStyle(
                            fontSize: 16
                        )
                    ),
                    StreamBuilder<List<Expense>>(
                        stream: GetIt.I<LocalDatabase>().watchExpense(DateTime.parse(formatForSearch.format(widget.selectedDate))),
                        builder: (context, snapshot) {
                          final numberFormat = NumberFormat('#,###');
                          int totalExpense = 0;

                          final data = snapshot.data;
                          if(data == null || data.isEmpty) {
                            return Text(
                              "지출 합계 : 0원",
                              maxLines: 1,
                            );
                          }

                          for(Expense e in data) {
                            totalExpense += e.expense;
                          }

                          return Text(
                            "합계 : ${numberFormat.format(totalExpense)}원",
                            maxLines: 1,
                          );
                        }
                    )
                  ],
                )
              )
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: StreamBuilder<List<Expense>> (
                      stream: GetIt.I<LocalDatabase>().watchExpense(DateTime.parse(formatForSearch.format(widget.selectedDate))),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData || snapshot.data!.isEmpty){
                          return Center(
                              child: Text(
                                  '지출 내역이 없습니다!',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Color(0xFFD1D1D1),
                                  )
                              )
                          );
                        }
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final expenseElement = snapshot.data![index];
                              return Padding(
                                padding: EdgeInsets.only(top: 0, bottom: 15),
                                child: Center(
                                  child: ExpenseCard(
                                      expenseId: expenseElement.id,
                                      category: expenseElement.category!,
                                      expenseName: expenseElement.expenseName,
                                      expense: expenseElement.expense,
                                      expenseDate: expenseElement.expenseDate,
                                      expenseDetail: expenseElement.expenseDetail!
                                  )
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