import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/service/app_settings.dart';

class ExpenseByWeek extends StatelessWidget {
  final DateTime selectedDate;

  ExpenseByWeek({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    int year = selectedDate.year;
    int month = selectedDate.month;

    DateTime lastDay = DateTime(year, month + 1, 0);

    DateTime? currentDate = null;

    List<DateTime> firstWeek = [];
    List<DateTime> secondWeek = [];
    List<DateTime> thirdWeek = [];
    List<DateTime> fourthWeek = [];
    List<DateTime> fifthWeek = [];
    List<DateTime> sixthWeek = [];
    int weekFlag = 1;

    for (int i = 1; i <= lastDay.day; i++) {
      currentDate = DateTime(selectedDate.year, selectedDate.month, i);
      switch (weekFlag) {
        case 1:
          firstWeek.add(currentDate);
          break;
        case 2:
          secondWeek.add(currentDate);
          break;
        case 3:
          thirdWeek.add(currentDate);
          break;
        case 4:
          fourthWeek.add(currentDate);
          break;
        case 5:
          fifthWeek.add(currentDate);
          break;
        default:
          sixthWeek.add(currentDate);
          break;
      }

      if (currentDate.weekday == 6) weekFlag++;
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _WeekRow(
            label: 'week.label'.tr(namedArgs: {'week': '1'}),
            child: getWeeklyExpenses(firstWeek.first, firstWeek.last),
          ),
          SizedBox(height: 8),
          _WeekRow(
            label: 'week.label'.tr(namedArgs: {'week': '2'}),
            child: getWeeklyExpenses(secondWeek.first, secondWeek.last),
          ),
          SizedBox(height: 8),
          _WeekRow(
            label: 'week.label'.tr(namedArgs: {'week': '3'}),
            child: getWeeklyExpenses(thirdWeek.first, thirdWeek.last),
          ),
          SizedBox(height: 8),
          _WeekRow(
            label: 'week.label'.tr(namedArgs: {'week': '4'}),
            child: getWeeklyExpenses(fourthWeek.first, fourthWeek.last),
          ),
          SizedBox(height: 8),
          fifthWeek.length > 0
              ? _WeekRow(
                label: 'week.label'.tr(namedArgs: {'week': '5'}),
                child: getWeeklyExpenses(fifthWeek.first, fifthWeek.last),
              )
              : Container(),
          SizedBox(height: 8),
          sixthWeek.length > 0
              ? _WeekRow(
                label: 'week.label'.tr(namedArgs: {'week': '6'}),
                child: getWeeklyExpenses(sixthWeek.first, sixthWeek.last),
              )
              : Container(),
        ],
      ),
    );
  }

  StreamBuilder<int> getWeeklyExpenses(DateTime startDate, DateTime endDate) {
    final currencyCode = GetIt.I<AppSettings>().currencyCode;

    return StreamBuilder<int>(
      stream: GetIt.I<LocalDatabase>().selectWeekExpense(startDate, endDate),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            CurrencyUtils.formatAmount(0, currencyCode),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedOf(context)),
          );
        }

        return Text(
          CurrencyUtils.formatAmount(snapshot.data ?? 0, currencyCode),
          style: Theme.of(context).textTheme.bodyLarge,
        );
      },
    );
  }
}

class _WeekRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _WeekRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          child,
        ],
      ),
    );
  }
}
