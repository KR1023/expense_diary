import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class ExpenseCalendar extends StatefulWidget {
  DateTime selectedDate;
  final onTapDate;

  ExpenseCalendar({required this.selectedDate, required this.onTapDate});

  @override
  State<ExpenseCalendar> createState() => _ExpenseCalendarState();
}

class _ExpenseCalendarState extends State<ExpenseCalendar> {
  // widget.selectedDate = DateTime.utc(
  //   DateTime.now().year,
  //   DateTime.now().month,
  //   DateTime.now().day,
  // );

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: widget.selectedDate,
      firstDay: DateTime(1900, 1, 1),
      lastDay: DateTime(2999, 12, 31),
      locale: context.locale.toString(),
      rowHeight: 48,
      daysOfWeekHeight: 28,
      onDaySelected: widget.onTapDate,
      selectedDayPredicate: (DateTime day) {
        return day.year == widget.selectedDate.year &&
            day.month == widget.selectedDate.month &&
            day.day == widget.selectedDate.day;
      },
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: AppColors.mutedOf(context),
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: AppColors.mutedOf(context),
        ),
        titleTextStyle:
            Theme.of(context).textTheme.titleMedium ??
            TextStyle(
              color: AppColors.inkOf(context),
              fontWeight: FontWeight.w600,
            ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle:
            Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.mutedOf(context),
            ) ??
            TextStyle(color: AppColors.mutedOf(context)),
        weekendStyle:
            Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.mutedOf(context),
            ) ??
            TextStyle(color: AppColors.mutedOf(context)),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
        weekendTextStyle: Theme.of(context).textTheme.bodyMedium!,
        todayTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        selectedTextStyle: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: Colors.white),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
