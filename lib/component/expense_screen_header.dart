import 'package:flutter/material.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/component/common/toast.dart';
import 'package:expense_diary/const/app_colors.dart';

class ExpenseScreenHeader extends StatelessWidget {
  final bool isAdd;
  final onSavePressed;
  int? id;

  ExpenseScreenHeader({
    required this.isAdd,
    required this.onSavePressed,
    this.id,
    super.key
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
            isAdd ? '지출 내역 추가' : '지출 내역 상세',
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
              child: Text(isAdd ? '추가' : '저장'),
            ),
            if (!isAdd)
              IconButton(
                onPressed: () {
                  onDeletePressed(context, id!);
                },
                icon: Icon(Icons.delete_outline),
              ),
          ],
        )

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
              Text('삭제'),
            ],
          ),
          content: Text('정말 삭제하시겠습니까?'),
          actions: [
            OutlinedButton(
              child: Text('취소'),
              onPressed:() {
                Navigator.of(context).pop(false);
              }
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: Text(
                '삭제'
              ),
              onPressed: () async {
                try{
                  await GetIt.I<LocalDatabase>().removeExpense(id);
                  showBasicToast(message: "삭제되었습니다.");
                  Navigator.pop(context);
                  Navigator.pop(context);
                } catch(e){
                  print(e);
                  showBasicToast(message: "오류가 발생했습니다.");
                }
              }
            )
          ]
        );
      }
    );
  }
}
