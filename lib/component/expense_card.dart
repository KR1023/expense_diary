import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/screen/detail_screen.dart';

class ExpenseCard extends StatelessWidget {
  final int expenseId;
  final CategoryData category;
  final String expenseName;
  final int expense;
  final DateTime expenseDate;
  final String expenseDetail;

  const ExpenseCard({
    required this.expenseId,
    required this.category,
    required this.expenseName,
    required this.expense,
    required this.expenseDate,
    required this.expenseDetail
  });

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat('#,###');
    final expenseDateFormat = DateFormat('yy.MM.dd');

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailScreen(
              expenseId: expenseId,
              expenseName: expenseName,
              expenseDate: expenseDate,
              categoryId: category.id,
              expense: expense,
              detail: expenseDetail,
            ))
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 85,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(2, 6),
                blurRadius: 6,
                spreadRadius: 1,
              )
            ],
            border: Border.all(
                color: Color(0xffebebeb),
                width: 2.0
            )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  child: Text(
                    category.categoryName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 16
                    ),
                  ),
                )
            ),
            Flexible(
                flex:4,
                child: Container(
                  width: double.infinity,
                  child: Text(
                      expenseName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 28
                      )
                  ),
                )
            ),
            Flexible(
              flex: 4,
              child: Container(
                  width: double.infinity,
                  child: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                '${numberFormatter.format(expense)}원',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 22
                                )
                            ),
                            Text(
                                expenseDateFormat.format(expenseDate),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 14
                                )
                            ),
                          ]
                      )
                  )

              ),
            )
          ]
        )
      )
    );
  }
}