import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/component/expense_card.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:expense_diary/model/category_expense.dart';

class ExpenseByDate extends StatefulWidget {
  final DateTime selectedDate;

  const ExpenseByDate({required this.selectedDate, super.key});

  @override
  State<StatefulWidget> createState() => _ExpenseByDateState();
}

class _ExpenseByDateState extends State<ExpenseByDate> {
  final dateFormat = DateFormat('yyyy.MM.dd');
  final formatForSearch = DateFormat('yyyy-MM-dd');

  DateTime get _queryDate =>
      DateTime.parse(formatForSearch.format(widget.selectedDate));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          border: Border.all(color: AppColors.outlineOf(context), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.mutedOf(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dateFormat.format(widget.selectedDate).toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24 * 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: GetIt.I<LocalDatabase>().watchExpense(_queryDate),
                builder: (context, snapshot) {
                  final currencyCode = GetIt.I<AppSettings>().currencyCode;
                  int totalExpense = 0;

                  final data = snapshot.data;
                  if (data != null && data.isNotEmpty) {
                    for (var e in data) {
                      final expense = e['expenses'] as Expense;
                      totalExpense += expense.expense;
                    }
                  }

                  final amount = CurrencyUtils.formatAmount(
                    totalExpense,
                    currencyCode,
                  );
                  return Text(
                    'calendar.expense_total'.tr(namedArgs: {'amount': amount}),
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedOf(context),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              onPressed: () {
                _showDetailModal(context);
              },
              tooltip: 'calendar.detail_view'.tr(),
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.list_alt_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetailModal(BuildContext context) async {
    final monthStart = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
    final monthEnd = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month + 1,
      0,
    );
    final weeklyRanges = _buildWeeklyRanges(monthStart, monthEnd);
    final summaryPageController = PageController(initialPage: 0);
    int summaryPage = 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: AppColors.outlineOf(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.outlineOf(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAltOf(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'calendar.detail_title'.tr(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateFormat.format(widget.selectedDate),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mutedOf(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        Text(
                          'calendar.section_expenses'.tr(),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: GetIt.I<LocalDatabase>().watchExpense(
                            _queryDate,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAltOf(context),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  'home.empty'.tr(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mutedOf(context),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children:
                                  snapshot.data!.map((row) {
                                    final expense = row['expenses'];
                                    final category = row['category'];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: ExpenseCard(
                                        expenseId: expense.id,
                                        category: category,
                                        expenseName: expense.expenseName,
                                        expense: expense.expense,
                                        expenseDate: expense.expenseDate,
                                        expenseDetail: expense.expenseDetail!,
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        StatefulBuilder(
                          builder: (context, setModalState) {
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceAltOf(context),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _SummarySegmentButton(
                                          label: 'calendar.section_weekly'.tr(),
                                          selected: summaryPage == 0,
                                        onTap: () {
                                            if (summaryPage != 0) {
                                              setModalState(() {
                                                summaryPage = 0;
                                              });
                                            }
                                            summaryPageController.animateToPage(
                                              0,
                                              duration: const Duration(
                                                milliseconds: 240,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: _SummarySegmentButton(
                                          label:
                                              'calendar.section_category'.tr(),
                                          selected: summaryPage == 1,
                                        onTap: () {
                                            if (summaryPage != 1) {
                                              setModalState(() {
                                                summaryPage = 1;
                                              });
                                            }
                                            summaryPageController.animateToPage(
                                              1,
                                              duration: const Duration(
                                                milliseconds: 240,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 280,
                                  child: PageView(
                                    controller: summaryPageController,
                                    onPageChanged: (index) {
                                      if (summaryPage != index) {
                                        setModalState(() {
                                          summaryPage = index;
                                        });
                                      }
                                    },
                                    children: [
                                      _WeeklySummaryPage(
                                        weeklyRanges: weeklyRanges,
                                      ),
                                      _CategorySummaryPage(
                                        selectedDate: widget.selectedDate,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(summaryPageController.dispose);
  }

  List<(DateTime, DateTime)> _buildWeeklyRanges(DateTime start, DateTime end) {
    final ranges = <(DateTime, DateTime)>[];
    var cursor = start;
    var weekStart = start;

    while (!cursor.isAfter(end)) {
      final isWeekEnd = cursor.weekday == DateTime.saturday;
      final isLastDay = cursor.day == end.day;

      if (isWeekEnd || isLastDay) {
        ranges.add((weekStart, cursor));
        final nextDay = cursor.add(const Duration(days: 1));
        weekStart = nextDay;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return ranges;
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final Stream<int> stream;

  const _SummaryRow({required this.label, required this.stream});

  @override
  Widget build(BuildContext context) {
    final currencyCode = GetIt.I<AppSettings>().currencyCode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          StreamBuilder<int>(
            stream: stream,
            builder: (context, snapshot) {
              return Text(
                CurrencyUtils.formatAmount(snapshot.data ?? 0, currencyCode),
                style: Theme.of(context).textTheme.bodyMedium,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummarySegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SummarySegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.surfaceOf(context) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border:
            selected
                ? Border.all(color: AppColors.outlineOf(context))
                : Border.all(color: Colors.transparent),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    selected
                        ? AppColors.inkOf(context)
                        : AppColors.mutedOf(context),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklySummaryPage extends StatelessWidget {
  final List<(DateTime, DateTime)> weeklyRanges;

  const _WeeklySummaryPage({required this.weeklyRanges});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children:
          weeklyRanges.asMap().entries.map((entry) {
            final weekIndex = entry.key + 1;
            final start = entry.value.$1;
            final end = entry.value.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SummaryRow(
                label: 'week.label'.tr(namedArgs: {'week': '$weekIndex'}),
                stream: GetIt.I<LocalDatabase>().selectWeekExpense(start, end),
              ),
            );
          }).toList(),
    );
  }
}

class _CategorySummaryPage extends StatelessWidget {
  final DateTime selectedDate;

  const _CategorySummaryPage({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryExpense>>(
      stream: GetIt.I<LocalDatabase>().watchMonthlyCategoryExpense(
        selectedDate,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'category_expense.empty'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
          );
        }

        return ListView(
          children:
              snapshot.data!.map((data) {
                final category =
                    data.category.isNotEmpty
                        ? data.category
                        : 'common.unclassified'.tr();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FixedSummaryRow(label: category, amount: data.total),
                );
              }).toList(),
        );
      },
    );
  }
}

class _FixedSummaryRow extends StatelessWidget {
  final String label;
  final int amount;

  const _FixedSummaryRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final currencyCode = GetIt.I<AppSettings>().currencyCode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            CurrencyUtils.formatAmount(amount, currencyCode),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
