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
    final monthLabel = DateFormat('yyyy.MM').format(widget.selectedDate);
    final dayLabel = dateFormat.format(widget.selectedDate);
    final currencyCode = GetIt.I<AppSettings>().currencyCode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineOf(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<int>(
                stream: GetIt.I<LocalDatabase>().selectMonthExpense(
                  widget.selectedDate,
                ),
                builder: (context, snapshot) {
                  return _SummaryMetricTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'calendar.month_total_title'.tr(
                      namedArgs: {'month': monthLabel},
                    ),
                    amount: CurrencyUtils.formatAmount(
                      snapshot.data ?? 0,
                      currencyCode,
                    ),
                    accentColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: GetIt.I<LocalDatabase>().watchExpense(_queryDate),
                      builder: (context, snapshot) {
                        int totalExpense = 0;

                        final data = snapshot.data;
                        if (data != null && data.isNotEmpty) {
                          for (var e in data) {
                            final expense = e['expenses'] as Expense;
                            totalExpense += expense.expense;
                          }
                        }

                        return _SummaryMetricTile(
                          icon: Icons.today_rounded,
                          label: 'calendar.day_total_title'.tr(
                            namedArgs: {'date': dayLabel},
                          ),
                          amount: CurrencyUtils.formatAmount(
                            totalExpense,
                            currencyCode,
                          ),
                          accentColor: AppColors.secondary,
                          backgroundColor: AppColors.secondary.withValues(
                            alpha: 0.08,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: IconButton.filled(
                      onPressed: () {
                        _showDetailModal(context);
                      },
                      tooltip: 'calendar.detail_view'.tr(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceOf(context),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                      ),
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.list_alt_rounded, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetailModal(BuildContext context) async {
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                                    final paymentMethod = row['paymentMethod'];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: ExpenseCard(
                                        expenseId: expense.id,
                                        category: category,
                                        paymentMethod: paymentMethod,
                                        expenseName: expense.expenseName,
                                        expense: expense.expense,
                                        expenseDate: expense.expenseDate,
                                        expenseDetail:
                                            expense.expenseDetail ?? '',
                                        isRecurring:
                                            expense.recurringExpenseId != null,
                                      ),
                                    );
                                  }).toList(),
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
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color accentColor;
  final Color backgroundColor;

  const _SummaryMetricTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 16),
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.mutedOf(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          _SummaryAmountText(amount: amount),
        ],
      ),
    );
  }
}

class _SummaryAmountText extends StatelessWidget {
  final String amount;

  const _SummaryAmountText({required this.amount});

  @override
  Widget build(BuildContext context) {
    final isUsd = amount.startsWith(r'$');
    final hasWon = amount.endsWith('원');
    final unit =
        isUsd
            ? r'$'
            : hasWon
            ? '원'
            : '';
    final value =
        isUsd
            ? amount.substring(1)
            : hasWon
            ? amount.substring(0, amount.length - 1)
            : amount;
    final amountStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.inkOf(context),
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.45,
      height: 1.05,
    );
    final unitStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: AppColors.inkOf(context).withValues(alpha: 0.78),
      fontWeight: FontWeight.w700,
      height: 1.05,
    );

    if (unit.isEmpty) {
      return Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: amountStyle,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          isUsd
              ? [
                Text(unit, style: unitStyle),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: amountStyle,
                  ),
                ),
              ]
              : [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: amountStyle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(unit, style: unitStyle),
              ],
    );
  }
}

class MonthlyExpenseSummaryCard extends StatefulWidget {
  final DateTime selectedDate;

  const MonthlyExpenseSummaryCard({required this.selectedDate, super.key});

  @override
  State<MonthlyExpenseSummaryCard> createState() =>
      _MonthlyExpenseSummaryCardState();
}

class _MonthlyExpenseSummaryCardState extends State<MonthlyExpenseSummaryCard> {
  late final PageController _summaryPageController;
  int _summaryPage = 0;
  final List<double> _summaryPageHeights = [0, 0];

  @override
  void initState() {
    super.initState();
    _summaryPageController = PageController();
  }

  @override
  void dispose() {
    _summaryPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border.all(color: AppColors.outlineOf(context)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'calendar.monthly_summary'.tr(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummarySegmentButton(
                    icon: Icons.view_week_rounded,
                    label: 'calendar.section_weekly'.tr(),
                    selected: _summaryPage == 0,
                    onTap: () => _animateSummaryPage(0),
                  ),
                ),
                Expanded(
                  child: _SummarySegmentButton(
                    icon: Icons.category_rounded,
                    label: 'calendar.section_category'.tr(),
                    selected: _summaryPage == 1,
                    onTap: () => _animateSummaryPage(1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: _currentSummaryHeight,
              child: PageView(
                controller: _summaryPageController,
                onPageChanged: _setSummaryPage,
                children: [
                  _MeasuredSummaryPage(
                    onChange: (height) => _setSummaryPageHeight(0, height),
                    child: _WeeklySummaryPage(weeklyRanges: weeklyRanges),
                  ),
                  _MeasuredSummaryPage(
                    onChange: (height) => _setSummaryPageHeight(1, height),
                    child: _CategorySummaryPage(
                      selectedDate: widget.selectedDate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _currentSummaryHeight {
    final measuredHeight = _summaryPageHeights[_summaryPage];
    return measuredHeight > 0 ? measuredHeight : 280;
  }

  void _animateSummaryPage(int page) {
    if (_summaryPage == page) return;
    _setSummaryPage(page);
    _summaryPageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _setSummaryPage(int page) {
    if (_summaryPage == page) return;
    setState(() {
      _summaryPage = page;
    });
  }

  void _setSummaryPageHeight(int page, double height) {
    if (!mounted || (_summaryPageHeights[page] - height).abs() < 0.5) return;
    setState(() {
      _summaryPageHeights[page] = height;
    });
  }
}

class _MeasuredSummaryPage extends StatefulWidget {
  final Widget child;
  final ValueChanged<double> onChange;

  const _MeasuredSummaryPage({required this.child, required this.onChange});

  @override
  State<_MeasuredSummaryPage> createState() => _MeasuredSummaryPageState();
}

class _MeasuredSummaryPageState extends State<_MeasuredSummaryPage> {
  final GlobalKey _key = GlobalKey();
  double _height = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
  }

  @override
  void didUpdateWidget(covariant _MeasuredSummaryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
  }

  void _notifySize() {
    final context = _key.currentContext;
    if (context == null) return;

    final size = context.size;
    if (size == null || (_height - size.height).abs() < 0.5) return;

    _height = size.height;
    widget.onChange(size.height);
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: KeyedSubtree(key: _key, child: widget.child),
    );
  }
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
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SummarySegmentButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        selected ? AppColors.primary : AppColors.mutedOf(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? AppColors.surfaceOf(context) : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color:
              selected
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : Colors.transparent,
        ),
        boxShadow:
            selected
                ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.surfaceOf(
                              context,
                            ).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 14, color: foreground),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          selected
                              ? AppColors.inkOf(context)
                              : AppColors.mutedOf(context),
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
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
    return Column(
      children:
          weeklyRanges.asMap().entries.map((entry) {
            final weekIndex = entry.key + 1;
            final start = entry.value.$1;
            final end = entry.value.$2;
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == weeklyRanges.length - 1 ? 0 : 8,
              ),
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
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surfaceAltOf(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'category_expense.empty'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
          );
        }

        final items = snapshot.data!;
        return Column(
          children:
              items.asMap().entries.map((entry) {
                final data = entry.value;
                final category =
                    data.category.isNotEmpty
                        ? data.category
                        : 'common.unclassified'.tr();
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == items.length - 1 ? 0 : 8,
                  ),
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
