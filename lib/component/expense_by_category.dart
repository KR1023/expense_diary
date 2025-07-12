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
      children: [
        Text('카테고리별 지출'),
        StreamBuilder<List<CategoryExpense>>(
          stream: GetIt.I<LocalDatabase>().watchMonthlyCategoryExpense(selectedDate),
          builder: (context, snapshot){
            if(!snapshot.hasData) {
              return Text(
                "지출이 없습니다!"
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final data = snapshot.data![index];
                return ListTile(
                  title: Text('${data.category}'),
                  subtitle: Text('합계: ${data.total}원')
                );
              }
            );
          }
        )
      ]
    );
  }
}