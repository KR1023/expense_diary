import 'package:flutter/material.dart';
import 'package:expense_diary/component/expense_card.dart';
import 'package:expense_diary/screen/add_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton(context),
      body: SafeArea(
        child:
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                Expanded(
                  child: StreamBuilder<List<Expense>>(
                      stream: GetIt.I<LocalDatabase>().watchExpense(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData || snapshot.data!.isEmpty){
                          return Center(
                              child: Text(
                                '지출 내용이 없습니다!',
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
                )
              ],
            )
          )
      ),
      bottomNavigationBar: renderBottomNavigation(),
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

  BottomNavigationBar renderBottomNavigation(){
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.paid
          ),
          label: '지출'
        ),
        BottomNavigationBarItem(
            icon: Icon(
                Icons.list_alt
            ),
            label: '지출 내역'
        ),
        BottomNavigationBarItem(
            icon: Icon(
                Icons.settings
            ),
            label: '설정'
        ),
      ]
    );
  }
}