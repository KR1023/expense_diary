import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/const/currency_utils.dart';

class ExpenseCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime, DateTime) onTapDate;
  final ValueChanged<DateTime> onPageChanged;
  final Map<DateTime, int> dailyTotals;
  final String currencyCode;

  const ExpenseCalendar({
    required this.selectedDate,
    required this.onTapDate,
    required this.onPageChanged,
    required this.dailyTotals,
    required this.currencyCode,
    super.key,
  });

  @override
  State<ExpenseCalendar> createState() => _ExpenseCalendarState();
}

class _ExpenseCalendarState extends State<ExpenseCalendar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactMode = constraints.maxHeight < 340;
        final daysOfWeekHeight = compactMode ? 20.0 : 24.0;
        // Reserve space for header + weekdays while keeping date cells readable.
        const safeHeaderReserve = 112.0;
        final calculatedRowHeight =
            (constraints.maxHeight - safeHeaderReserve) / 6;
        final rowHeight =
            (calculatedRowHeight - 1).clamp(32.0, 60.0).floorToDouble();
        final showAmount = rowHeight >= 27;

        return TableCalendar(
          focusedDay: widget.selectedDate,
          firstDay: DateTime(1900, 1, 1),
          lastDay: DateTime(2999, 12, 31),
          locale: context.locale.toString(),
          rowHeight: rowHeight,
          daysOfWeekHeight: daysOfWeekHeight,
          sixWeekMonthsEnforced: false,
          onDaySelected: widget.onTapDate,
          onPageChanged: widget.onPageChanged,
          shouldFillViewport: true,
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
            cellMargin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
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
          calendarBuilders: CalendarBuilders(
            defaultBuilder:
                (context, day, focusedDay) => _buildDayCell(
                  context: context,
                  day: day,
                  isSelected: false,
                  isToday: false,
                  compactMode: compactMode,
                  rowHeight: rowHeight,
                  showAmount: showAmount,
                ),
            todayBuilder:
                (context, day, focusedDay) => _buildDayCell(
                  context: context,
                  day: day,
                  isSelected: false,
                  isToday: true,
                  compactMode: compactMode,
                  rowHeight: rowHeight,
                  showAmount: showAmount,
                ),
            selectedBuilder:
                (context, day, focusedDay) => _buildDayCell(
                  context: context,
                  day: day,
                  isSelected: true,
                  isToday: false,
                  compactMode: compactMode,
                  rowHeight: rowHeight,
                  showAmount: showAmount,
                ),
          ),
        );
      },
    );
  }

  Widget _buildDayCell({
    required BuildContext context,
    required DateTime day,
    required bool isSelected,
    required bool isToday,
    required bool compactMode,
    required double rowHeight,
    required bool showAmount,
  }) {
    final dayKey = DateTime(day.year, day.month, day.day);
    final amount = widget.dailyTotals[dayKey];
    final muted = AppColors.mutedOf(context);

    final amountText =
        amount == null || amount == 0
            ? null
            : CurrencyUtils.formatCompactAmount(amount, widget.currencyCode);

    final dayFontSize = (rowHeight * 0.48).clamp(15.0, 21.0);
    final dayTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: dayFontSize,
      fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
      color:
          isSelected
              ? Colors.white
              : isToday
              ? AppColors.primary
              : AppColors.inkOf(context),
    );

    final dayCircleSize = (rowHeight * 0.68).clamp(28.0, 36.0);
    final amountFontSize = (rowHeight * 0.25).clamp(10.5, 13.0);
    final dayText = Text('${day.day}', style: dayTextStyle);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child:
                (isSelected || isToday)
                    ? Container(
                      width: dayCircleSize,
                      height: dayCircleSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: FittedBox(child: dayText),
                    )
                    : dayText,
          ),
          if (showAmount && amountText != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: compactMode ? 0 : 1),
                child: Text(
                  amountText,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? AppColors.primary : muted,
                    fontSize: amountFontSize,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
