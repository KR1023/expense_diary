import 'package:flutter/material.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/component/common/toast.dart';

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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Text(
            isAdd ? '지출 내역 추가' : '지출 내역 상세',
            style: TextStyle(
                fontSize: 16.0
            )
        ),
        Row(
          children: [
            SizedBox(
              width: 40,
              height: 29,
              child: OutlinedButton(
                  onPressed: () {
                    onSavePressed(context);
                    // Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFFFFFFFF),
                      backgroundColor: Color(0x9958D68D),
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      minimumSize: Size(0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                          color: Color(0xFFFFF)
                      )
                  ),
                  child: Text(
                      '+',
                      style: TextStyle(
                          fontSize: 20.0
                      )
                  )
              ),
            ),
            isAdd ? Container() :
            IconButton(
                onPressed: (){
                  onDeletePressed(context, id!);
                },
                icon: Icon(Icons.delete)
            )
          ]
        )

      ],
    );
  }

  void onDeletePressed(BuildContext context, int id) async {
    bool? selected = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제'),
          content: Text('정말 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed:() {
                Navigator.of(context).pop(false);
              }
            ),
            TextButton(
              child: Text(
                '삭제',
                style: TextStyle(
                  color: Colors.red
                )
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