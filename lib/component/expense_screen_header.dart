import 'package:flutter/material.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/component/common/toast.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class ExpenseScreenHeader extends StatelessWidget {
  final bool isAdd;
  final onSavePressed;
  int? id;

  ExpenseScreenHeader({
    required this.isAdd,
    required this.onSavePressed,
    this.id,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        Expanded(
          child: Text(
            isAdd ? 'expense.header_add'.tr() : 'expense.header_detail'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Row(
          children: [
            FilledButton(
              onPressed: () {
                onSavePressed(context);
              },
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isAdd ? 'common.add'.tr() : 'common.save'.tr()),
            ),
            if (!isAdd)
              IconButton(
                onPressed: () {
                  onDeletePressed(context, id!);
                },
                icon: Icon(Icons.delete_outline),
              ),
          ],
        ),
      ],
    );
  }

  void onDeletePressed(BuildContext context, int id) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              SizedBox(width: 8),
              Text('expense.delete_title'.tr()),
            ],
          ),
          content: Text('expense.delete_confirm'.tr()),
          actions: [
            OutlinedButton(
              child: Text('common.cancel'.tr()),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: Text('common.delete'.tr()),
              onPressed: () async {
                try {
                  await GetIt.I<LocalDatabase>().removeExpense(id);
                  showToast(context, 'expense.toast_deleted'.tr(),
                      icon: Icons.delete_outline_rounded);
                  Navigator.pop(context);
                  Navigator.pop(context);
                } catch (e) {
                  debugPrint(e.toString());
                  showToast(context, 'error.generic'.tr(),
                      icon: Icons.error_outline_rounded);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
