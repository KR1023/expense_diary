import 'package:expense_diary/model/category_expense.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/database/drift_database.dart';

class ExpenseByCategory extends StatelessWidget {
  final DateTime selectedDate;

  ExpenseByCategory({
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '분류별 지출',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22

            )
          ),
        ),
        StreamBuilder<List<CategoryExpense>>(
          stream: GetIt.I<LocalDatabase>().watchMonthlyCategoryExpense(selectedDate),
          builder: (context, snapshot){
            if(!snapshot.hasData || snapshot.data?.length == 0) {
              return SizedBox(
                height: MediaQuery.of(context).size.height / 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                            "지출이 없습니다!",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color(0xFFD1D1D1),
                          ),
                        )
                    )
                  ],
                )
              );
            }

            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  String category;
                  if(data.category != '')
                    category = data.category;
                  else
                    category = '미분류';

                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 23),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${category}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500
                              )
                          ),
                          Text(
                            '${numberFormatter.format(data.total)} 원',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400
                            )
                          )
                        ],
                      )
                    )

                  );
                  //   ListTile(
                  //     title: Text('${category}'),
                  //     subtitle: Text('합계: ${data.total}원')
                  // );
                }
              )
            );
          }
        )
      ]
    );
  }
}