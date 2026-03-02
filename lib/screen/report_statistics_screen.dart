import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/model/category_expense.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReportStatisticsScreen extends StatefulWidget {
  const ReportStatisticsScreen({super.key});

  @override
  State<ReportStatisticsScreen> createState() => _ReportStatisticsScreenState();
}

class _ReportStatisticsScreenState extends State<ReportStatisticsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  static const int _topN = 5;

  LocalDatabase get _db => GetIt.I<LocalDatabase>();

  @override
  Widget build(BuildContext context) {
    final currencyCode = GetIt.I<AppSettings>().currencyCode;

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
                    'Report 통계',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                'Report 플랜 전용. SQLite 로컬 데이터를 기준으로 월간 통계를 계산합니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ),
            _MonthSelector(
              month: _selectedMonth,
              onChanged: (next) {
                setState(() {
                  _selectedMonth = DateTime(next.year, next.month);
                });
              },
            ),
            const SizedBox(height: 12),
            StreamBuilder<int>(
              stream: _db.selectMonthExpense(_selectedMonth),
              builder: (context, snapshot) {
                final expenseTotal = snapshot.data ?? 0;
                return _MonthlySummaryCard(
                  month: _selectedMonth,
                  expenseTotal: expenseTotal,
                  currencyCode: currencyCode,
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<CategoryExpense>>(
                stream: _db.watchMonthlyCategoryExpense(_selectedMonth),
                builder: (context, snapshot) {
                  final items = [
                    ...(snapshot.data ?? const <CategoryExpense>[]),
                  ]..sort((a, b) => b.total.compareTo(a.total));
                  final topItems = items.take(_topN).toList(growable: false);

                  return Column(
                    children: [
                      Expanded(
                        child: _CategoryTopChart(
                          items: topItems,
                          currencyCode: currencyCode,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _CategoryTopList(
                          items: topItems,
                          currencyCode: currencyCode,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('yyyy.MM').format(month);
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
                    label,
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

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.month,
    required this.expenseTotal,
    required this.currencyCode,
  });

  final DateTime month;
  final int expenseTotal;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('yyyy.MM').format(month)} 월별 요약',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              label: '총 지출',
              value: CurrencyUtils.formatAmount(expenseTotal, currencyCode),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CategoryTopChart extends StatelessWidget {
  const _CategoryTopChart({required this.items, required this.currencyCode});

  final List<CategoryExpense> items;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyCard(message: '해당 월의 지출 데이터가 없습니다.');
    }

    final maxValue = items.map((e) => e.total).fold<int>(0, math.max);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리별 지출 TOP ${items.length} (차트)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final ratio = maxValue == 0 ? 0.0 : (item.total / maxValue);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.category.isEmpty ? '미분류' : item.category,
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
                            style: Theme.of(context).textTheme.bodyMedium,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTopList extends StatelessWidget {
  const _CategoryTopList({required this.items, required this.currencyCode});

  final List<CategoryExpense> items;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyCard(message: '카테고리 합계 목록이 없습니다.');
    }

    final total = items.fold<int>(0, (sum, item) => sum + item.total);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리별 지출 TOP ${items.length} (리스트)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final pct =
                      total == 0 ? 0 : ((item.total / total) * 100).round();
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 14,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(item.category.isEmpty ? '미분류' : item.category),
                    subtitle: Text('비중 $pct%'),
                    trailing: Text(
                      CurrencyUtils.formatAmount(item.total, currencyCode),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.all(16),
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
