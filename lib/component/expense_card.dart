import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/screen/detail_screen.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/service/app_settings.dart';

class ExpenseCard extends StatelessWidget {
  final int expenseId;
  final CategoryData? category;
  final PaymentMethod? paymentMethod;
  final String expenseName;
  final int expense;
  final DateTime expenseDate;
  final String expenseDetail;

  const ExpenseCard({
    required this.expenseId,
    this.category,
    this.paymentMethod,
    required this.expenseName,
    required this.expense,
    required this.expenseDate,
    required this.expenseDetail,
  });

  @override
  Widget build(BuildContext context) {
    final expenseDateFormat = DateFormat('yy.MM.dd');
    final isDark = AppColors.isDark(context);
    final currencyCode = GetIt.I<AppSettings>().currencyCode;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DetailScreen(
                    expenseId: expenseId,
                    expenseName: expenseName,
                    expenseDate: expenseDate,
                    category: category,
                    paymentMethod: paymentMethod,
                    expense: expense,
                    detail: expenseDetail,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(
                    label: category != null
                        ? category!.categoryName
                        : 'common.unclassified'.tr(),
                    isDark: isDark,
                    context: context,
                  ),
                  if (paymentMethod != null) ...[
                    const SizedBox(height: 4),
                    _Badge(
                      label: paymentMethod!.name,
                      isDark: isDark,
                      context: context,
                      muted: true,
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  expenseName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.formatAmount(expense, currencyCode),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expenseDateFormat.format(expenseDate),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.isDark,
    required this.context,
    this.muted = false,
  });

  final String label;
  final bool isDark;
  final BuildContext context;
  final bool muted;

  @override
  Widget build(BuildContext _) {
    final color = muted
        ? Theme.of(context).colorScheme.outline
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.08),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.36 : 0.15)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: muted ? AppColors.mutedOf(context) : null,
            ),
      ),
    );
  }
}
