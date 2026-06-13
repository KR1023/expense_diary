import 'dart:async';
import 'package:expense_diary/const/app_theme.dart';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/component/expense_card.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/model/category_expense.dart';
import 'package:expense_diary/model/payment_method_expense.dart';
import 'package:expense_diary/screen/report_export_screen.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReportStatisticsScreen extends StatefulWidget {
  const ReportStatisticsScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<ReportStatisticsScreen> createState() => _ReportStatisticsScreenState();
}

class _ReportStatisticsScreenState extends State<ReportStatisticsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _distributionMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  int _monthTotal = 0;
  int _prevMonthTotal = 0;
  int _expenseCount = 0;
  Map<DateTime, int> _dailyTotals = {};
  List<CategoryExpense> _categoryItems = [];
  List<PaymentMethodExpense> _paymentItems = [];
  _TrendRange _trendRange = _TrendRange.sixMonths;

  final List<StreamSubscription<dynamic>> _subs = [];
  StreamSubscription<Map<DateTime, int>>? _dailyTotalsSub;

  static const int _topN = 5;

  LocalDatabase get _db => GetIt.I<LocalDatabase>();

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }

  void _cancelAll() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _dailyTotalsSub?.cancel();
    _dailyTotalsSub = null;
  }

  void _subscribe() {
    _cancelAll();
    final prev = DateTime(_selectedMonth.year, _selectedMonth.month - 1);

    _subs.addAll([
      _db.selectMonthExpense(_selectedMonth).listen((v) {
        if (mounted) setState(() => _monthTotal = v);
      }),
      _db.selectMonthExpense(prev).listen((v) {
        if (mounted) setState(() => _prevMonthTotal = v);
      }),
      _db.countMonthExpenses(_selectedMonth).listen((v) {
        if (mounted) setState(() => _expenseCount = v);
      }),
      _db.watchMonthlyCategoryExpense(_selectedMonth).listen((v) {
        if (mounted) {
          setState(() {
            _categoryItems = [...v]..sort((a, b) => b.total.compareTo(a.total));
          });
        }
      }),
      _db.watchMonthlyPaymentMethodExpense(_selectedMonth).listen((v) {
        if (mounted) {
          setState(() {
            _paymentItems = [...v]..sort((a, b) => b.total.compareTo(a.total));
          });
        }
      }),
    ]);
    _subscribeDailyTotals();
  }

  void _subscribeDailyTotals() {
    _dailyTotalsSub?.cancel();
    _dailyTotalsSub = _db.watchDailyExpenseTotals(_distributionMonth).listen((
      v,
    ) {
      if (mounted) setState(() => _dailyTotals = v);
    });
  }

  void _changeMonth(DateTime next) {
    setState(() {
      _selectedMonth = DateTime(next.year, next.month);
      _distributionMonth = DateTime(next.year, next.month);
      _monthTotal = 0;
      _prevMonthTotal = 0;
      _expenseCount = 0;
      _dailyTotals = {};
      _categoryItems = [];
      _paymentItems = [];
    });
    _subscribe();
  }

  void _changeDistributionMonth(DateTime next) {
    setState(() {
      _distributionMonth = DateTime(next.year, next.month);
      _dailyTotals = {};
    });
    _subscribeDailyTotals();
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = GetIt.I<AppSettings>().currencyCode;
    final topItems = _categoryItems.take(_topN).toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.showBackButton) ...[
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    'report.stats.title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _ReportExportShortcutButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReportExportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                'report.stats.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ),
            _MonthSelector(month: _selectedMonth, onChanged: _changeMonth),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildSummaryCard(currencyCode),
                  const SizedBox(height: 12),
                  _MonthlyTrendCard(
                    baseMonth: _selectedMonth,
                    highlightedMonth: _distributionMonth,
                    range: _trendRange,
                    currencyCode: currencyCode,
                    onRangeChanged: (value) {
                      setState(() {
                        _trendRange = value;
                      });
                    },
                    onMonthSelected: _changeDistributionMonth,
                  ),
                  const SizedBox(height: 12),
                  _DailyDistributionCard(
                    month: _distributionMonth,
                    dailyTotals: _dailyTotals,
                    currencyCode: currencyCode,
                    onDateSelected: (date) {
                      _showDailyExpenseSheet(
                        context,
                        date,
                        _dailyTotals[DateTime(
                              date.year,
                              date.month,
                              date.day,
                            )] ??
                            0,
                        currencyCode,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (topItems.isEmpty)
                    _EmptyCard(message: 'report.stats.empty_month'.tr())
                  else ...[
                    _CategoryBarCard(
                      items: topItems,
                      currencyCode: currencyCode,
                      selectedMonth: _selectedMonth,
                      totalAmount: _monthTotal,
                    ),
                  ],
                  if (_paymentItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _PaymentMethodCard(
                      items: _paymentItems,
                      currencyCode: currencyCode,
                      selectedMonth: _selectedMonth,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String currencyCode) {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final dailyAvg = daysInMonth > 0 ? (_monthTotal / daysInMonth).round() : 0;

    MapEntry<DateTime, int>? peakEntry;
    if (_dailyTotals.isNotEmpty) {
      peakEntry = _dailyTotals.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
    }

    final diff = _monthTotal - _prevMonthTotal;
    final String vsText;
    final Color? vsColor;
    if (_prevMonthTotal == 0) {
      vsText = 'report.stats.vs_no_prev'.tr();
      vsColor = AppColors.mutedOf(context);
    } else if (diff == 0) {
      vsText = 'report.stats.vs_no_change'.tr();
      vsColor = null;
    } else {
      final pct = ((diff.abs() / _prevMonthTotal) * 100).round();
      final amount = CurrencyUtils.formatAmount(diff.abs(), currencyCode);
      vsText =
          diff > 0
              ? 'report.stats.vs_increased'.tr(
                namedArgs: {'amount': amount, 'pct': '$pct'},
              )
              : 'report.stats.vs_decreased'.tr(
                namedArgs: {'amount': amount, 'pct': '$pct'},
              );
      vsColor = diff > 0 ? AppColors.danger : Colors.green.shade600;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report.stats.monthly_summary'.tr(
                namedArgs: {
                  'month': DateFormat('yyyy.MM').format(_selectedMonth),
                },
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'report.stats.total_expense'.tr(),
                    value: CurrencyUtils.formatAmount(
                      _monthTotal,
                      currencyCode,
                    ),
                  ),
                ),
                Expanded(
                  child: _StatBlock(
                    label: 'report.stats.expense_count'.tr(),
                    value: '$_expenseCount건',
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _StatRow(
              label: 'report.stats.daily_avg'.tr(),
              value: CurrencyUtils.formatAmount(dailyAvg, currencyCode),
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: 'report.stats.vs_prev_month'.tr(),
              value: vsText,
              valueColor: vsColor,
            ),
            if (peakEntry != null) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: 'report.stats.peak_day'.tr(),
                value: 'report.stats.peak_day_value'.tr(
                  namedArgs: {
                    'date': DateFormat('d일').format(peakEntry.key),
                    'amount': CurrencyUtils.formatAmount(
                      peakEntry.value,
                      currencyCode,
                    ),
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDailyExpenseSheet(
    BuildContext context,
    DateTime date,
    int total,
    String currencyCode,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _DailyExpenseDetailSheet(
            date: date,
            total: total,
            currencyCode: currencyCode,
          ),
    );
  }
}

class _ReportExportShortcutButton extends StatelessWidget {
  const _ReportExportShortcutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
    final gradient = AppColors.heroGradientForBackground(bgIndex, context);

    return Tooltip(
      message: 'report.export.title'.tr(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.file_download_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'report.export.short_label'.tr(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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

enum _TrendRange {
  threeMonths(3),
  sixMonths(6),
  twelveMonths(12);

  const _TrendRange(this.monthCount);

  final int monthCount;
}

// ── Trend charts ────────────────────────────────────────────────────────────

class _MonthlyTrendCard extends StatelessWidget {
  const _MonthlyTrendCard({
    required this.baseMonth,
    required this.highlightedMonth,
    required this.range,
    required this.currencyCode,
    required this.onRangeChanged,
    required this.onMonthSelected,
  });

  final DateTime baseMonth;
  final DateTime highlightedMonth;
  final _TrendRange range;
  final String currencyCode;
  final ValueChanged<_TrendRange> onRangeChanged;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final endMonth = DateTime(baseMonth.year, baseMonth.month, 1);
    final startMonth = DateTime(
      baseMonth.year,
      baseMonth.month - range.monthCount + 1,
      1,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'report.stats.monthly_trend'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<_TrendRange>(
                    value: range,
                    borderRadius: BorderRadius.circular(14),
                    style: Theme.of(context).textTheme.labelLarge,
                    items: [
                      DropdownMenuItem(
                        value: _TrendRange.threeMonths,
                        child: Text('report.stats.range_3m'.tr()),
                      ),
                      DropdownMenuItem(
                        value: _TrendRange.sixMonths,
                        child: Text('report.stats.range_6m'.tr()),
                      ),
                      DropdownMenuItem(
                        value: _TrendRange.twelveMonths,
                        child: Text('report.stats.range_12m'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      onRangeChanged(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<Map<DateTime, int>>(
              stream: GetIt.I<LocalDatabase>().watchMonthlyExpenseTotalsInRange(
                startMonth: startMonth,
                endMonth: endMonth,
              ),
              builder: (context, snapshot) {
                final totals = snapshot.data ?? const <DateTime, int>{};
                final items = totals.entries
                    .map(
                      (entry) => _ChartPoint(
                        keyDate: entry.key,
                        label: DateFormat('MM월').format(entry.key),
                        amount: entry.value,
                        selected:
                            entry.key.year == highlightedMonth.year &&
                            entry.key.month == highlightedMonth.month,
                      ),
                    )
                    .toList(growable: false);

                return _HorizontalAmountChart(
                  items: items,
                  currencyCode: currencyCode,
                  itemWidth: 52,
                  barWidth: 16,
                  barRadius: 6,
                  onTap: onMonthSelected,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyDistributionCard extends StatelessWidget {
  const _DailyDistributionCard({
    required this.month,
    required this.dailyTotals,
    required this.currencyCode,
    required this.onDateSelected,
  });

  final DateTime month;
  final Map<DateTime, int> dailyTotals;
  final String currencyCode;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final items = List.generate(daysInMonth, (index) {
      final day = DateTime(month.year, month.month, index + 1);
      return _ChartPoint(
        keyDate: day,
        label: '${index + 1}',
        amount: dailyTotals[day] ?? 0,
      );
    });

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report.stats.daily_distribution'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'report.stats.daily_distribution_desc'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 12),
            _HorizontalAmountChart(
              items: items,
              currencyCode: currencyCode,
              itemWidth: 42,
              barWidth: 14,
              barRadius: 5,
              onTap: onDateSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPoint {
  const _ChartPoint({
    required this.keyDate,
    required this.label,
    required this.amount,
    this.selected = false,
  });

  final DateTime keyDate;
  final String label;
  final int amount;
  final bool selected;
}

class _HorizontalAmountChart extends StatelessWidget {
  const _HorizontalAmountChart({
    required this.items,
    required this.currencyCode,
    required this.itemWidth,
    required this.barWidth,
    required this.barRadius,
    this.onTap,
  });

  final List<_ChartPoint> items;
  final String currencyCode;
  final double itemWidth;
  final double barWidth;
  final double barRadius;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final maxValue = items.map((e) => e.amount).fold<int>(0, math.max);
    final chartHeight = 126.0;
    final unitLabel = currencyCode == 'USD' ? 'USD' : '만원';
    final backgroundIndex = GetIt.I<AppSettings>().backgroundIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeGradient = AppColors.heroGradientForBackground(
      backgroundIndex,
      context,
    );
    final themeAccent = AppColors.accentColorForBackground(
      backgroundIndex,
      context,
    );
    final selectedBarColor =
        isDark ? Color.lerp(themeAccent, Colors.white, 0.18)! : themeAccent;
    final secondaryBarColor =
        themeGradient.colors.length > 1
            ? themeGradient.colors.last
            : themeAccent;
    final unselectedBarColor =
        isDark
            ? Color.lerp(
              secondaryBarColor,
              Colors.white,
              0.12,
            )!.withValues(alpha: 0.45)
            : secondaryBarColor.withValues(alpha: 0.42);
    final zeroBarColor =
        isDark
            ? AppColors.outlineOf(context).withValues(alpha: 0.6)
            : AppColors.outlineOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '($unitLabel)',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.mutedOf(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: items
                .map((item) {
                  final ratio = maxValue == 0 ? 0.0 : item.amount / maxValue;
                  final barHeight = math.max(8.0, chartHeight * ratio);
                  final accent =
                      item.selected ? selectedBarColor : unselectedBarColor;
                  final content = SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          child: Text(
                            item.amount == 0
                                ? ''
                                : _chartAmountLabel(item.amount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color:
                                  item.selected
                                      ? selectedBarColor
                                      : AppColors.mutedOf(context),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: chartHeight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: barWidth,
                              height: item.amount == 0 ? 8 : barHeight,
                              decoration: BoxDecoration(
                                color: item.amount == 0 ? zeroBarColor : accent,
                                borderRadius: BorderRadius.circular(barRadius),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color:
                                item.selected
                                    ? selectedBarColor
                                    : AppColors.mutedOf(context),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (onTap == null) return content;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onTap!(item.keyDate),
                    child: content,
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  String _chartAmountLabel(int amount) {
    if (currencyCode == 'USD') {
      return NumberFormat.compact().format(amount);
    }
    return NumberFormat('#,##0.#').format(amount / 10000);
  }
}

// ── Month selector ──────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await AppTheme.showDatePickerDialog(
                    context: context,
                    initialDate: month,
                  );
                  if (picked == null) return;
                  onChanged(DateTime(picked.year, picked.month));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    DateFormat('yyyy.MM').format(month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary helpers ─────────────────────────────────────────────────────────

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.mutedOf(context)),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedOf(context)),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Category charts ─────────────────────────────────────────────────────────

class _CategoryBarCard extends StatelessWidget {
  const _CategoryBarCard({
    required this.items,
    required this.currencyCode,
    required this.selectedMonth,
    required this.totalAmount,
  });

  final List<CategoryExpense> items;
  final String currencyCode;
  final DateTime selectedMonth;
  final int totalAmount;

  @override
  Widget build(BuildContext context) {
    final maxValue = items.map((e) => e.total).fold<int>(0, math.max);
    final backgroundIndex = GetIt.I<AppSettings>().backgroundIndex;
    final accentColor = AppColors.accentColorForBackground(
      backgroundIndex,
      context,
    );
    final isDark = AppColors.isDark(context);
    final indicatorColor =
        isDark ? Color.lerp(accentColor, Colors.white, 0.18)! : accentColor;
    final trackColor = AppColors.outlineColorOf(
      backgroundIndex,
      context,
    ).withValues(alpha: isDark ? 0.45 : 0.55);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report.stats.chart_title'.tr(
                namedArgs: {'count': '${items.length}'},
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final ratio = maxValue == 0 ? 0.0 : (item.total / maxValue);
              final pct =
                  totalAmount == 0
                      ? 0
                      : ((item.total / totalAmount) * 100).round();
              final name =
                  item.category.isEmpty
                      ? 'common.unclassified'.tr()
                      : item.category;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showDetail(context, item, name),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: indicatorColor.withValues(
                                alpha: isDark ? 0.28 : 0.14,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.copyWith(
                                  color: indicatorColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${CurrencyUtils.formatAmount(item.total, currencyCode)}  ($pct%)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppColors.mutedOf(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            color: indicatorColor,
                            backgroundColor: trackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, CategoryExpense item, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _CategoryDetailSheet(
            name: name,
            total: item.total,
            categoryId: item.categoryId,
            selectedMonth: selectedMonth,
            currencyCode: currencyCode,
          ),
    );
  }
}

// ── Category detail sheet ───────────────────────────────────────────────────

class _ThemedDetailSheet extends StatelessWidget {
  const _ThemedDetailSheet({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.total,
    required this.currencyCode,
    required this.bodyBuilder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int total;
  final String currencyCode;
  final Widget Function(
    BuildContext context,
    ScrollController scrollController,
    _SheetTheme theme,
  )
  bodyBuilder;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return AnimatedBuilder(
          animation: GetIt.I<AppSettings>(),
          builder: (context, _) {
            final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
            final bgColor = AppColors.cardColorOf(bgIndex, context);
            final outlineColor = AppColors.outlineColorOf(bgIndex, context);
            final gradient = AppColors.heroGradientForBackground(
              bgIndex,
              context,
            );
            final accentColor = AppColors.accentColorForBackground(
              bgIndex,
              context,
            );
            final sheetTheme = _SheetTheme(
              backgroundColor: bgColor,
              outlineColor: outlineColor,
              accentColor: accentColor,
              cardColor: AppColors.outlineColorOf(
                bgIndex,
                context,
              ).withValues(alpha: 0.18),
            );

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    surface: bgColor,
                    surfaceContainerHighest: bgColor,
                    outline: outlineColor,
                  ),
                  cardTheme: Theme.of(context).cardTheme.copyWith(
                    color: bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: outlineColor),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 8),
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 8, 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    icon,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.75,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyUtils.formatAmount(
                                        total,
                                        currencyCode,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'report.stats.total_expense'.tr(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: bodyBuilder(context, scrollController, sheetTheme),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SheetTheme {
  const _SheetTheme({
    required this.backgroundColor,
    required this.outlineColor,
    required this.accentColor,
    required this.cardColor,
  });

  final Color backgroundColor;
  final Color outlineColor;
  final Color accentColor;
  final Color cardColor;
}

class _DailyExpenseDetailSheet extends StatelessWidget {
  const _DailyExpenseDetailSheet({
    required this.date,
    required this.total,
    required this.currencyCode,
  });

  final DateTime date;
  final int total;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return _ThemedDetailSheet(
      icon: Icons.calendar_today_rounded,
      title: DateFormat('yyyy.MM.dd').format(date),
      subtitle: 'report.stats.daily_distribution'.tr(),
      total: total,
      currencyCode: currencyCode,
      bodyBuilder: (context, scrollController, sheetTheme) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: GetIt.I<LocalDatabase>().watchExpense(date),
          builder: (context, snapshot) {
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return _SheetEmptyState(sheetTheme: sheetTheme);
            }

            return ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final expense = data[index]['expenses'] as Expense;
                final category = data[index]['category'] as CategoryData?;
                final paymentMethod =
                    data[index]['paymentMethod'] as PaymentMethod?;

                return ExpenseCard(
                  expenseId: expense.id,
                  category: category,
                  paymentMethod: paymentMethod,
                  expenseName: expense.expenseName,
                  expense: expense.expense,
                  expenseDate: expense.expenseDate,
                  expenseDetail: expense.expenseDetail ?? '',
                  isRecurring: expense.recurringExpenseId != null,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CategoryDetailSheet extends StatelessWidget {
  const _CategoryDetailSheet({
    required this.name,
    required this.total,
    required this.categoryId,
    required this.selectedMonth,
    required this.currencyCode,
  });

  final String name;
  final int total;
  final int? categoryId;
  final DateTime selectedMonth;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return _ThemedDetailSheet(
      icon: Icons.category_rounded,
      title: name,
      subtitle: DateFormat('yyyy.MM').format(selectedMonth),
      total: total,
      currencyCode: currencyCode,
      bodyBuilder: (context, scrollController, sheetTheme) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: GetIt.I<LocalDatabase>().watchMonthExpensesByCategory(
            selectedMonth,
            categoryId,
          ),
          builder: (context, snapshot) {
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return _SheetEmptyState(sheetTheme: sheetTheme);
            }

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final expense = data[index]['expense'] as Expense;
                final paymentMethod =
                    data[index]['paymentMethod'] as PaymentMethod?;
                final paymentMethodName =
                    paymentMethod?.name ?? 'common.unclassified'.tr();
                return _SheetExpenseSummaryTile(
                  expense: expense,
                  badgeLabel: paymentMethodName,
                  currencyCode: currencyCode,
                  sheetTheme: sheetTheme,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── Payment method card ─────────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.items,
    required this.currencyCode,
    required this.selectedMonth,
  });

  final List<PaymentMethodExpense> items;
  final String currencyCode;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final maxValue = items.map((e) => e.total).fold<int>(0, math.max);
    final totalAmount = items.fold<int>(0, (sum, e) => sum + e.total);
    final backgroundIndex = GetIt.I<AppSettings>().backgroundIndex;
    final accentColor = AppColors.accentColorForBackground(
      backgroundIndex,
      context,
    );
    final isDark = AppColors.isDark(context);
    final indicatorColor =
        isDark ? Color.lerp(accentColor, Colors.white, 0.18)! : accentColor;
    final trackColor = AppColors.outlineColorOf(
      backgroundIndex,
      context,
    ).withValues(alpha: isDark ? 0.45 : 0.55);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report.stats.payment_method_title'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              final ratio = maxValue == 0 ? 0.0 : (item.total / maxValue);
              final pct =
                  totalAmount == 0
                      ? 0
                      : ((item.total / totalAmount) * 100).round();
              final name =
                  item.name.isEmpty ? 'common.unclassified'.tr() : item.name;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showDetail(context, item, name),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${CurrencyUtils.formatAmount(item.total, currencyCode)}  ($pct%)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.mutedOf(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 10,
                          color: indicatorColor,
                          backgroundColor: trackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showDetail(
    BuildContext context,
    PaymentMethodExpense item,
    String displayName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _PaymentMethodDetailSheet(
            name: displayName,
            total: item.total,
            paymentMethodId: item.paymentMethodId,
            selectedMonth: selectedMonth,
            currencyCode: currencyCode,
          ),
    );
  }
}

// ── Payment method detail sheet ─────────────────────────────────────────────

class _PaymentMethodDetailSheet extends StatelessWidget {
  const _PaymentMethodDetailSheet({
    required this.name,
    required this.total,
    required this.paymentMethodId,
    required this.selectedMonth,
    required this.currencyCode,
  });

  final String name;
  final int total;
  final int? paymentMethodId;
  final DateTime selectedMonth;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return _ThemedDetailSheet(
      icon: Icons.credit_card_rounded,
      title: name,
      subtitle: DateFormat('yyyy.MM').format(selectedMonth),
      total: total,
      currencyCode: currencyCode,
      bodyBuilder: (context, scrollController, sheetTheme) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: GetIt.I<LocalDatabase>().watchMonthExpensesByPaymentMethod(
            selectedMonth,
            paymentMethodId,
          ),
          builder: (context, snapshot) {
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return _SheetEmptyState(sheetTheme: sheetTheme);
            }

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final expense = data[index]['expense'] as Expense;
                final cat = data[index]['category'] as CategoryData?;
                final categoryName =
                    cat?.categoryName ?? 'common.unclassified'.tr();
                return _SheetExpenseSummaryTile(
                  expense: expense,
                  badgeLabel: categoryName,
                  currencyCode: currencyCode,
                  sheetTheme: sheetTheme,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _SheetEmptyState extends StatelessWidget {
  const _SheetEmptyState({required this.sheetTheme});

  final _SheetTheme sheetTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: sheetTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sheetTheme.outlineColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 20,
              color: AppColors.mutedOf(context),
            ),
            const SizedBox(width: 8),
            Text(
              'home.empty'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetExpenseSummaryTile extends StatelessWidget {
  const _SheetExpenseSummaryTile({
    required this.expense,
    required this.badgeLabel,
    required this.currencyCode,
    required this.sheetTheme,
  });

  final Expense expense;
  final String badgeLabel;
  final String currencyCode;
  final _SheetTheme sheetTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: sheetTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sheetTheme.outlineColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.expenseName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: sheetTheme.accentColor.withValues(
                          alpha: AppColors.isDark(context) ? 0.22 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: sheetTheme.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: AppColors.mutedOf(context),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      DateFormat('MM.dd').format(expense.expenseDate),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            CurrencyUtils.formatAmount(expense.expense, currencyCode),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            style: TextStyle(color: AppColors.mutedOf(context)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
