import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';

class ConfigScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '설정',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '앱 데이터를 관리하고 초기화할 수 있습니다.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Icons.delete_sweep_outlined, color: AppColors.danger),
                title: Text('모든 데이터 초기화'),
                subtitle: Text('복구할 수 없는 작업입니다.'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  initConfirmDialog(context);
                },
              ),
            ),
            const Spacer(),
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Future<void> initConfirmDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              SizedBox(width: 8),
              Text('데이터 삭제'),
            ],
          ),
          content: Text('정말 모든 데이터를 삭제하시겠습니까?'),
          actions: [
            OutlinedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text('취소')
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await GetIt.I<LocalDatabase>().deleteAllData();
                Navigator.of(context).pop();
              },
              child: Text('확인')
            ),
          ]
        );
      }
    );
  }
}
