import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/label_field.dart';
import 'package:expense_diary/component/expense_screen_header.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/component/category_select.dart';

class AddScreen extends StatefulWidget {
  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  String? expenseName;
  DateTime? expenseDate;
  int? expense;
  int? categoryId;
  String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Column(
            children: [
              ExpenseScreenHeader(
                isAdd: true,
                onSavePressed: onSavePressed
              ),
              const SizedBox(height: 40),
              Form(
                key: formKey,
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            LabelField(
                              label: '지출명',
                              isDetail: false,
                              isDate: false,
                              isExpense: false,
                              initValue: null,
                              onSaved: (String? val){
                                expenseName = val!;
                              },
                              validator: (String? val){},
                            ),
                            const SizedBox(height: 25),
                            LabelField(
                              label: '지출일자',
                              isDetail: false,
                              isDate: true,
                              isExpense: false,
                              initValue: null,
                              onSaved: (String? val){
                                DateFormat formatter = DateFormat('yyyy-MM-dd');
                                expenseDate = formatter.parse(val!);
                              },
                              validator: (String? val){},
                            ),
                            const SizedBox(height: 25),
                            LabelField(
                              label: '지출금액',
                              isDetail: false,
                              isDate: false,
                              isExpense: true,
                              initValue: null,
                              onSaved: (String? val){
                                expense = int.parse(val!);
                              },
                              validator: (String? val){},
                            ),
                            const SizedBox(height: 40),
                            // LabelField(
                            //   label: '분류',
                            //   isDetail: false,
                            //   isDate: false,
                            //   isExpense: false,
                            //   initValue: null,
                            //   onSaved: (String? val){
                            //     print(val);
                            //     if(val != null)
                            //       categoryId = int.parse(val!);
                            //   },
                            //   validator: (String? val){},
                            // ),
                            CategorySelect(
                              onSavedCategory: (CategoryData? val){
                                // categoryId = val;
                                print('category:::${val}');
                                if(val != null) {
                                  categoryId = val.id;
                                } else {
                                  categoryId = null;
                                }
                              }
                            ),
                            const SizedBox(height: 25),
                            LabelField(
                              label: '지출상세내용',
                              isDetail: true,
                              isDate: false,
                              isExpense: false,
                              initValue: null,
                              onSaved: (String? val){
                                detail = val!;
                              },
                              validator: (String? val){},
                            ),
                            SizedBox(height: 40),
                          ]
                        )
                      )
                    )
                  )
                )
              )
            ],
          )
        )
      )
    );
  }

  void onSavePressed() async {
    if(formKey.currentState!.validate()) {
      formKey.currentState!.save();

      await GetIt.I<LocalDatabase>().createExpense(
        ExpensesCompanion(
          expenseName: Value(expenseName!),
          expenseDate: Value(expenseDate!),
          expense: Value(expense!),
          categoryId: Value(categoryId!),
          expenseDetail: Value(detail!)
        )
      );
    }
  }

}

