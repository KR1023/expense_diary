import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/model/category_expense.dart';
import 'package:expense_diary/model/payment_method_expense.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReportStatisticsScreen extends StatefulWidget {
  const ReportStatisticsScreen({super.key});

  @override
  State<ReportStatisticsScreen> createState() =>
      _ReportStatisticsScreenState();
}

class _ReportStatisticsScreenState extends State<ReportStatisticsScreen> {
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  int _monthTotal = 0;
  int _prevMonthTotal = 0;
  int _expenseCount = 0;
  Map<DateTime, int> _dailyTotals = {};
  List<CategoryExpense> _categoryItems = [];
  List<PaymentMethodExpense> _paymentItems = [];

  final List<StreamSubscription<dynamic>> _subs = [];

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
    for (final s in _subs) s.cancel();
    _subs.clear();
  }

  void _subscribe() {
    _cancelAll();
    final prev =
        DateTime(_selectedMonth.year, _selectedMonth.month - 1);

    _subs.addAll([
      _db.selectMonthExpense(_selectedMonth).listen(
        (v) { if (mounted) setState(() => _monthTotal = v); },
      ),
      _db.selectMonthExpense(prev).listen(
        (v) { if (mounted) setState(() => _prevMonthTotal = v); },
      ),
      _db.countMonthExpenses(_selectedMonth).listen(
        (v) { if (mounted) setState(() => _expenseCount = v); },
      ),
      _db.watchDailyExpenseTotals(_selectedMonth).listen(
        (v) { if (mounted) setState(() => _dailyTotals = v); },
      ),
      _db.watchMonthlyCategoryExpense(_selectedMonth).listen((v) {
        if (mounted) {
          setState(() {
            _categoryItems = [...v]
              ..sort((a, b) => b.total.compareTo(a.total));
          });
        }
      }),
      _db.watchMonthlyPaymentMethodExpense(_selectedMonth).listen((v) {
        if (mounted) {
          setState(() {
            _paymentItems = [...v]
              ..sort((a, b) => b.total.compareTo(a.total));
          });
        }
      }),
    ]);
  }

  void _changeMonth(DateTime next) {
    setState(() {
      _selectedMonth = DateTime(next.year, next.month);
      _monthTotal = 0;
      _prevMonthTotal = 0;
      _expenseCount = 0;
      _dailyTotals = {};
      _categoryItems = [];
      _paymentItems = [];
    });
    _subscribe();
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
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'report.stats.title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
            _MonthSelector(
              month: _selectedMonth,
              onChanged: _changeMonth,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildSummaryCard(currencyCode),
                  const SizedBox(height: 12),
                  if (topItems.isEmpty)
                    _EmptyCard(message: 'report.stats.empty_month'.tr())
                  else ...[
                    _CategoryBarCard(
                      items: topItems,
                      currencyCode: currencyCode,
                    ),
                    const SizedBox(height: 12),
                    _CategoryListCard(
                      items: topItems,
                      currencyCode: currencyCode,
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
    final dailyAvg =
        daysInMonth > 0 ? (_monthTotal / daysInMonth).round() : 0;

    MapEntry<DateTime, int>? peakEntry;
    if (_dailyTotals.isNotEmpty) {
      peakEntry = _dailyTotals.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
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
      vsText = diff > 0
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
              onPressed: () =>
                  onChanged(DateTime(month.year, month.month - 1)),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
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
              onPressed: () =>
                  onChanged(DateTime(month.year, month.month + 1)),
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.mutedOf(context),
              ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
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
  const _CategoryBarCard(
      {required this.items, required this.currencyCode});

  final List<CategoryExpense> items;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final maxValue =
        items.map((e) => e.total).fold<int>(0, math.max);
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
            ...items.map((item) {
              final ratio =
                  maxValue == 0 ? 0.0 : (item.total / maxValue);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.category.isEmpty
                                ? 'common.unclassified'.tr()
                                : item.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyUtils.formatAmount(
                            item.total,
                            currencyCode,
                          ),
                          style:
                              Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 10,
                        backgroundColor:
                            AppColors.outlineOf(context),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryListCard extends StatelessWidget {
  const _CategoryListCard(
      {required this.items, required this.currencyCode});

  final List<CategoryExpense> items;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final total =
        items.fold<int>(0, (sum, item) => sum + item.total);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report.stats.list_title'.tr(
                namedArgs: {'count': '${items.length}'},
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...items.asMap().entries.map((e) {
              final index = e.key;
              final item = e.value;
              final pct = total == 0
                  ? 0
                  : ((item.total / total) * 100).round();
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 14,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      item.category.isEmpty
                          ? 'common.unclassified'.tr()
                          : item.category,
                    ),
                    subtitle: Text(
                      'report.stats.share'
                          .tr(namedArgs: {'pct': '$pct'}),
                    ),
                    trailing: Text(
                      CurrencyUtils.formatAmount(
                        item.total,
                        currencyCode,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
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
              final pct = totalAmount == 0
                  ? 0
                  : ((item.total / totalAmount) * 100).round();
              final name = item.name.isEmpty
                  ? 'common.unclassified'.tr()
                  : item.name;
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
                          backgroundColor: AppColors.outlineOf(context),
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
      BuildContext context, PaymentMethodExpense item, String displayName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PaymentMethodDetailSheet(
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
    final isDark = AppColors.isDark(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 핸들
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.credit_card_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('yyyy.MM').format(selectedMonth),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.mutedOf(context),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.formatAmount(total, currencyCode),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'report.stats.total_expense'.tr(),
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.mutedOf(context),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.outlineOf(context)),
            // 목록
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: GetIt.I<LocalDatabase>()
                    .watchMonthExpensesByPaymentMethod(
                  selectedMonth,
                  paymentMethodId,
                ),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? [];
                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 40,
                            color: AppColors.mutedOf(context),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'home.empty'.tr(),
                            style: TextStyle(
                                color: AppColors.mutedOf(context)),
                          ),
                        ],
                      ),
                    );
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAltOf(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.outlineOf(context),
                          ),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(
                                                  alpha: isDark ? 0.22 : 0.09),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          categoryName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.primary,
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
                                        DateFormat('MM.dd')
                                            .format(expense.expenseDate),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
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
                              CurrencyUtils.formatAmount(
                                  expense.expense, currencyCode),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

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
