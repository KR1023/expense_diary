import 'package:flutter/material.dart';
import 'package:expense_diary/component/calendar/expense_calendar.dart';
import 'package:expense_diary/component/expense_by_date.dart';
import 'package:expense_diary/component/expense_by_month.dart';
import 'package:expense_diary/component/expense_by_category.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  final PageController _pageController = PageController(initialPage: 0);

  void onTapDate(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
    });
  }

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
              'calendar.title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'calendar.subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.outlineOf(context)),
              ),
              child: ExpenseCalendar(
                selectedDate: selectedDate,
                onTapDate: onTapDate,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: PageViewChildren(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> PageViewChildren() {
    return [
      ExpenseByDate(selectedDate: selectedDate),
      ExpenseByMonth(selectedDate: selectedDate),
      ExpenseByCategory(selectedDate: selectedDate),
    ];
  }
}
