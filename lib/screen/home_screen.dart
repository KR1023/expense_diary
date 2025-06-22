import 'package:flutter/material.dart';
import 'package:expense_diary/component/expense_card.dart';
import 'package:expense_diary/screen/add_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: SafeArea(
        child:
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 10,
                  child: StreamBuilder<List<Expense>>(
                      stream: GetIt.I<LocalDatabase>().watchExpense(),
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
                                padding: EdgeInsets.only(top: 10),
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
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Color(0xFFFFF6F6),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: StreamBuilder <List<Expense>>(
                              stream: GetIt.I<LocalDatabase>().watchExpense(),
                              builder: (context, snapshot) {
                                return Text(
                                    '지출 : ${snapshot.data?.length ?? 0}건'
                                );
                              }
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder <List<Expense>>(
                              stream: GetIt.I<LocalDatabase>().watchExpense(),
                              builder: (context, snapshot) {
                                final numberFormatter = NumberFormat('#,###');
                                int totalExpense = 0;

                                final data = snapshot.data;
                                if(data == null || data.isEmpty) {
                                  return Text(
                                      "지출 합계 : 0원"
                                  );
                                }

                                for(Expense e in data) {
                                  totalExpense += e.expense;
                                }

                                return Text(
                                  "합계 : ${numberFormatter.format(totalExpense)}원"
                                );
                              }
                            )
                          )
                        ]
                      )
                    )
                  )
                )
              ],
            )
          )
      ),
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