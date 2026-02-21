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
            const headerBlockHeight = 64.0;
            const gap = 10.0;
            const minCalendarHeight = 272.0;
            const summaryHeight = 80.0;
            const bottomPadding = 12.0;
            final requiredMinHeight =
                headerBlockHeight +
                gap +
                minCalendarHeight +
                gap +
                summaryHeight +
                bottomPadding;

            if (constraints.maxHeight < requiredMinHeight) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context),
                    const SizedBox(height: gap),
                    SizedBox(height: minCalendarHeight, child: _calendarCard()),
                    const SizedBox(height: gap),
                    SizedBox(
                      height: summaryHeight,
                      child: ExpenseByDate(selectedDate: selectedDate),
                    ),
                    const SizedBox(height: bottomPadding),
                  ],
                ),
              );
            }

            final availableCalendarHeight =
                constraints.maxHeight -
                headerBlockHeight -
                summaryHeight -
                (gap * 2) -
                bottomPadding;
            final calendarHeight = availableCalendarHeight.clamp(
              minCalendarHeight,
              380.0,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: gap),
                SizedBox(height: calendarHeight, child: _calendarCard()),
                const SizedBox(height: gap),
                SizedBox(
                  height: summaryHeight,
                  child: ExpenseByDate(selectedDate: selectedDate),
                ),
                const SizedBox(height: bottomPadding),
              ],
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

  Widget _calendarCard() {
    return Container(
      padding: const EdgeInsets.all(12),
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
