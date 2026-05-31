import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/label_field.dart';
import 'package:expense_diary/component/expense_screen_header.dart';
import 'package:expense_diary/component/category_select.dart';
import 'package:expense_diary/component/payment_method_select.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class DetailScreen extends StatefulWidget {
  final int expenseId;
  final String expenseName;
  final DateTime expenseDate;
  final int expense;
  final CategoryData? category;
  final PaymentMethod? paymentMethod;
  final String detail;

  DetailScreen({
    required this.expenseId,
    required this.expenseName,
    required this.expenseDate,
    required this.expense,
    this.category,
    this.paymentMethod,
    required this.detail,
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
  int? paymentMethodId;
  PaymentMethod? paymentMethod;
  String? detail;

  @override
  void initState() {
    expenseId = widget.expenseId;
    expenseName = widget.expenseName;
    expenseDate = widget.expenseDate;
    expense = widget.expense;
    categoryId = widget.category?.id;
    category = widget.category;
    paymentMethodId = widget.paymentMethod?.id;
    paymentMethod = widget.paymentMethod;
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
                            label: 'expense.form.name'.tr(),
                            isDetail: false,
                            isDate: false,
                            isExpense: false,
                            initValue: expenseName,
                            onSaved: (String? val) {
                              expenseName = val!;
                            },
                            validator: (String? val) {
                              if (val == '' || val == null) {
                                return 'expense.form.name_required'.tr();
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          LabelField(
                            label: 'expense.form.date'.tr(),
                            isDetail: false,
                            isDate: true,
                            isExpense: false,
                            initValue: expenseDate.toString(),
                            onSaved: (String? val) {
                              DateFormat formatter = DateFormat('yyyy-MM-dd');
                              expenseDate = formatter.parse(val!);
                            },
                            validator: (String? val) {},
                          ),
                          const SizedBox(height: 20),
                          LabelField(
                            label: 'expense.form.amount'.tr(),
                            isDetail: false,
                            isDate: false,
                            isExpense: true,
                            initValue: expense.toString(),
                            onSaved: (String? val) {
                              expense = int.parse(val!);
                            },
                            validator: (String? val) {
                              if (val == '' || val == null) {
                                return 'expense.form.amount_required'.tr();
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          CategorySelect(
                            selectedValue: category,
                            onSavedCategory: (CategoryData? val) {
                              categoryId = val?.id;
                            },
                          ),
                          const SizedBox(height: 20),
                          PaymentMethodSelect(
                            selectedValue: paymentMethod,
                            onSaved: (val) {
                              paymentMethodId = val?.id;
                            },
                          ),
                          const SizedBox(height: 20),
                          LabelField(
                            label: 'expense.form.detail'.tr(),
                            isDetail: true,
                            isDate: false,
                            isExpense: false,
                            initValue: detail,
                            onSaved: (String? val) {
                              detail = val!;
                            },
                            validator: (String? val) {},
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAltOf(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.outlineOf(context),
                              ),
                            ),
                            child: Text(
                              'expense.detail_hint'.tr(),
                              style: Theme.of(context).textTheme.bodySmall
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
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      await GetIt.I<LocalDatabase>().updateExpense(
        ExpensesCompanion(
          id: Value(expenseId!),
          expenseName: Value(expenseName!),
          expenseDate: Value(expenseDate!),
          expense: Value(expense!),
          categoryId: Value(categoryId),
          paymentMethodId: Value(paymentMethodId),
          expenseDetail: Value(detail!),
        ),
      );

      Navigator.pop(context);
    }
  }
}
