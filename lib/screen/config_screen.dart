import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';

class ConfigScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 20
          ),
          TextButton(
            onPressed: (){
              print('초기화');
              initConfirmDialog(context);
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              )
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                '모든 데이터 초기화',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600
                )
              )
            )
          )
        ],
      )
    );
  }

  Future<void> initConfirmDialog(BuildContext context) async {
    final result = await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('데이터 삭제'),
          content: Text('정말 모든 데이터를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () async {
                await GetIt.I<LocalDatabase>().deleteAllData();
                Navigator.of(context).pop();
              },
              child: Text(
                '확인'
              )
            ),
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text('취소')
            )
          ]
        );
      }
    );
  }
}
