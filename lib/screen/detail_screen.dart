import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/label_field.dart';
import 'package:expense_diary/component/expense_screen_header.dart';
import 'package:expense_diary/component/category_select.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';

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
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            ExpenseScreenHeader(
              isAdd: false,
              onSavePressed: onSavePressed,
              id: expenseId,
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
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAltOf(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outlineOf(context)),
                            ),
                            child: Text(
                              '수정 사항은 저장 버튼을 눌러 반영됩니다.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.mutedOf(context)),
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
