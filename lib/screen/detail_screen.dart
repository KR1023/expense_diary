import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/label_field.dart';
import 'package:expense_diary/component/expense_screen_header.dart';
import 'package:expense_diary/component/category_select.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';

class DetailScreen extends StatefulWidget {
  final int expenseId;
  final String expenseName;
  final DateTime expenseDate;
  final int expense;
  final CategoryData? category;
  final String detail;


  DetailScreen({
    required this.expenseId,
    required this.expenseName,
    required this.expenseDate,
    required this.expense,
    this.category,
    required this.detail
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? expenseId;
  String? expenseName;
  DateTime? expenseDate;
  int? expense;
  int? categoryId;
  CategoryData? category;
  String? detail;

  @override
  void initState() {
    expenseId = widget.expenseId;
    expenseName = widget.expenseName;
    expenseDate = widget.expenseDate;
    expense = widget.expense;
    categoryId = widget.category != null ? widget.category!.id : null;
    category = widget.category != null ? widget.category : null;
    detail = widget.detail;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Column(
            children: [
              ExpenseScreenHeader(
                isAdd: false,
                onSavePressed: onSavePressed,
                id: expenseId,
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
                              initValue: expenseName,
                              onSaved: (String? val){
                                expenseName = val!;
                              },
                              validator: (String? val){
                                if(val == '' || val == null){
                                  return '지출명을 입력해 주세요.';
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 25),
                            LabelField(
                              label: '지출일자',
                              isDetail: false,
                              isDate: true,
                              isExpense: false,
                              initValue: expenseDate.toString(),
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
                              initValue: expense.toString(),
                              onSaved: (String? val){
                                expense = int.parse(val!);
                              },
                              validator: (String? val){
                                if(val == '' || val == null){
                                  return "금액을 입력해 주세요.";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 25),
                            // LabelField(
                            //   label: '분류',
                            //   isDetail: false,
                            //   isDate: false,
                            //   isExpense: false,
                            //   initValue: categoryId,
                            //   onSaved: (String? val){
                            //     categoryId = int.parse(val!);
                            //   },
                            //   validator: (String? val){},
                            // ),
                            CategorySelect(
                              selectedValue: category,
                              onSavedCategory: (CategoryData? val){
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
                              initValue: detail,
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

  void onSavePressed(BuildContext context) async {
    if(formKey.currentState!.validate()) {
      formKey.currentState!.save();

      await GetIt.I<LocalDatabase>().updateExpense(
        Expense(
          id: expenseId!,
          expenseName: expenseName!,
          expenseDate: expenseDate!,
          expense: expense!,
          categoryId: categoryId,
          expenseDetail: detail!,
        )
      );

      Navigator.pop(context);
    }
  }
}

