import 'package:expense_diary/component/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/label_field.dart';
import 'package:expense_diary/component/expense_screen_header.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/component/category_select.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';

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
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            ExpenseScreenHeader(
              isAdd: true,
              onSavePressed: onSavePressed,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          LabelField(
                            label: '지출명',
                            isDetail: false,
                            isDate: false,
                            isExpense: false,
                            initValue: null,
                            onSaved: (String? val) {
                              expenseName = val!;
                            },
                            validator: (String? val) {
                              if (val == '' || val == null) {
                                return '지출명을 입력해 주세요.';
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          LabelField(
                            label: '지출일자',
                            isDetail: false,
                            isDate: true,
                            isExpense: false,
                            initValue: null,
                            onSaved: (String? val) {
                              DateFormat formatter = DateFormat('yyyy-MM-dd');
                              expenseDate = formatter.parse(val!);
                            },
                            validator: (String? val) {},
                          ),
                          const SizedBox(height: 20),
                          LabelField(
                            label: '지출금액',
                            isDetail: false,
                            isDate: false,
                            isExpense: true,
                            initValue: null,
                            onSaved: (String? val) {
                              expense = int.parse(val!);
                            },
                            validator: (String? val) {
                              if (val == '' || val == null) {
                                return "금액을 입력해 주세요.";
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          CategorySelect(
                            onSavedCategory: (CategoryData? val) {
                              if (val != null) {
                                categoryId = val.id;
                              } else {
                                categoryId = null;
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          LabelField(
                            label: '지출상세내용',
                            isDetail: true,
                            isDate: false,
                            isExpense: false,
                            initValue: null,
                            onSaved: (String? val) {
                              detail = val!;
                            },
                            validator: (String? val) {},
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Text(
                              '저장 후에는 홈에서 바로 확인할 수 있어요.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSavePressed(BuildContext context) async {
    if(formKey.currentState!.validate()) {
      formKey.currentState!.save();

      await GetIt.I<LocalDatabase>().createExpense(
        ExpensesCompanion(
          expenseName: Value(expenseName!),
          expenseDate: Value(expenseDate!),
          expense: Value(expense!),
          categoryId: Value(categoryId),
          expenseDetail: Value(detail!)
        )
      );
      showBasicToast(message: "지출을 추가했습니다.");
      Navigator.pop(context);
    }
  }

}
