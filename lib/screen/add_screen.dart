import 'package:expense_diary/component/common/toast.dart';
import 'package:expense_diary/component/common/thousands_formatter.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/component/label_field.dart';
import 'package:expense_diary/component/expense_screen_header.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/component/category_select.dart';
import 'package:expense_diary/component/payment_method_select.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:easy_localization/easy_localization.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _expenseAmountController =
      TextEditingController();

  String? expenseName;
  DateTime? expenseDate;
  int? expense;
  int? categoryId;
  int? paymentMethodId;
  String? detail;

  @override
  void dispose() {
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  void _applyCategoryDefaults(CategoryData? category) {
    if (category == null) return;
    if (category.autoFillExpenseName) {
      _expenseNameController.text = category.categoryName;
    }
    if (category.usePresetAmount && category.presetAmount != null) {
      _expenseAmountController.text = ThousandsFormatter.format(
        category.presetAmount!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            ExpenseScreenHeader(isAdd: true, onSavePressed: onSavePressed),
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
                            initValue: null,
                            controller: _expenseNameController,
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
                            initValue: widget.initialDate?.toIso8601String(),
                            onSaved: (String? val) {
                              DateFormat formatter = DateFormat('yyyy-MM-dd');
                              expenseDate = formatter.parse(val!);
                            },
                            validator: (String? val) => null,
                          ),
                          const SizedBox(height: 20),
                          LabelField(
                            label: 'expense.form.amount'.tr(),
                            isDetail: false,
                            isDate: false,
                            isExpense: true,
                            initValue: null,
                            controller: _expenseAmountController,
                            onSaved: (String? val) {
                              expense = int.parse(val!.replaceAll(',', ''));
                            },
                            validator: (String? val) {
                              if (val == '' || val == null) {
                                return 'expense.form.amount_required'.tr();
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          CategorySelect(
                            showIcon: false,
                            onChanged: _applyCategoryDefaults,
                            onSavedCategory: (CategoryData? val) {
                              categoryId = val?.id;
                            },
                          ),
                          const SizedBox(height: 20),
                          PaymentMethodSelect(
                            showIcon: false,
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
                            initValue: null,
                            onSaved: (String? val) {
                              detail = val!;
                            },
                            validator: (String? val) => null,
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

      await GetIt.I<LocalDatabase>().createExpense(
        ExpensesCompanion(
          expenseName: Value(expenseName!),
          expenseDate: Value(expenseDate!),
          expense: Value(expense!),
          categoryId: Value(categoryId),
          paymentMethodId: Value(paymentMethodId),
          expenseDetail: Value(detail!),
        ),
      );
      if (!context.mounted) return;
      showToast(context, 'expense.toast_added'.tr());
      Navigator.pop(context);
    }
  }
}
