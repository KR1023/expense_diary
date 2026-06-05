import 'package:flutter/material.dart';
import 'package:expense_diary/component/calendar/expense_calendar.dart';
import 'package:expense_diary/component/expense_by_date.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/service/app_settings.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  void onTapDate(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
    });
  }

  void onPageChanged(DateTime focusedDay) {
    setState(() {
      selectedDate = DateTime(focusedDay.year, focusedDay.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const gap = 8.0;
            const combinedSummaryHeight = 132.0;
            const bottomPadding = 12.0;
            final calendarHeight =
                constraints.maxHeight < 760
                    ? 360.0
                    : constraints.maxHeight < 840
                    ? 390.0
                    : 420.0;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: gap),
                  SizedBox(height: calendarHeight, child: _calendarCard(context)),
                  const SizedBox(height: gap),
                  SizedBox(
                    height: combinedSummaryHeight,
                    child: ExpenseByDate(selectedDate: selectedDate),
                  ),
                  const SizedBox(height: gap),
                  MonthlyExpenseSummaryCard(selectedDate: selectedDate),
                  const SizedBox(height: bottomPadding),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'calendar.title'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'calendar.subtitle'.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedOf(context)),
        ),
      ],
    );
  }

  Widget _calendarCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: StreamBuilder<Map<DateTime, int>>(
        stream: GetIt.I<LocalDatabase>().watchDailyExpenseTotals(selectedDate),
        builder: (context, snapshot) {
          return ExpenseCalendar(
            selectedDate: selectedDate,
            onTapDate: onTapDate,
            onPageChanged: onPageChanged,
            dailyTotals: snapshot.data ?? const {},
            currencyCode: GetIt.I<AppSettings>().currencyCode,
          );
        },
      ),
    );
  }
}
