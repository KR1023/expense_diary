import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/screen/detail_screen.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class ExpenseCard extends StatelessWidget {
  final int expenseId;
  final CategoryData? category;
  final String expenseName;
  final int expense;
  final DateTime expenseDate;
  final String expenseDetail;

  const ExpenseCard({
    required this.expenseId,
    this.category,
    required this.expenseName,
    required this.expense,
    required this.expenseDate,
    required this.expenseDetail,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat('#,###');
    final expenseDateFormat = DateFormat('yy.MM.dd');
    final isDark = AppColors.isDark(context);

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: isDark ? 0.24 : 0.08),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: isDark ? 0.42 : 0.15,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  category != null
                      ? category!.categoryName
                      : 'common.unclassified'.tr(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
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
                    '${numberFormatter.format(expense)}${'common.currency_suffix'.tr()}',
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
