import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/component/expense_card.dart';
import 'package:expense_diary/screen/add_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final selectedDate = DateTime(now.year, now.month, now.day);

    return Scaffold(
      floatingActionButton: floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body:
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BannerAdWidget(),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: GetIt.I<LocalDatabase>().watchExpense(selectedDate),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? [];

                    return Column(
                      children: [
                        Expanded(
                          child: data.isEmpty
                              ? Center(
                                  child: Text(
                                    '지출 내역이 없습니다!',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Color(0xFFD1D1D1),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    final expense = data[index]['expenses'];
                                    final category = data[index]['category'];

                                    return Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Center(
                                        child: ExpenseCard(
                                          expenseId: expense.id,
                                          category: category,
                                          expenseName: expense.expenseName,
                                          expense: expense.expense,
                                          expenseDate: expense.expenseDate,
                                          expenseDetail: expense.expenseDetail!,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Color(0xFFFFF6F6),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('지출 : ${data.length}건'),
                                ),
                                Expanded(
                                  child: StreamBuilder<int>(
                                    stream: GetIt.I<LocalDatabase>()
                                        .selectDayExpense(selectedDate),
                                    builder: (context, totalSnapshot) {
                                      final numberFormatter = NumberFormat('#,###');
                                      final total = totalSnapshot.data ?? 0;
                                      return Text(
                                        "합계 : ${numberFormatter.format(total)}원",
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          )
        )
    );
  }

  FloatingActionButton floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      shape: CircleBorder(),
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddScreen())
        );
      },
      backgroundColor: Color(0xCCe8e8e8),
      child: Icon(
        Icons.add
      )
    );
  }
}
