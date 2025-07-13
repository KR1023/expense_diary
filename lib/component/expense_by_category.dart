import 'package:expense_diary/model/category_expense.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';

class ExpenseByCategory extends StatelessWidget {
  final DateTime selectedDate;

  ExpenseByCategory({
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '카테고리별 지출',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22

            )
          ),
        ),
        StreamBuilder<List<CategoryExpense>>(
          stream: GetIt.I<LocalDatabase>().watchMonthlyCategoryExpense(selectedDate),
          builder: (context, snapshot){
            print(snapshot.data);
            if(!snapshot.hasData) {
              return Text(
                "지출이 없습니다!"
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

                  return ListTile(
                      title: Text('${category}'),
                      subtitle: Text('합계: ${data.total}원')
                  );
                }
              )
            );
          }
        )
      ]
    );
  }
}