import 'package:expense_diary/model/category_expense.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/service/app_settings.dart';

class ExpenseByCategory extends StatelessWidget {
  final DateTime selectedDate;

  ExpenseByCategory({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final currencyCode = GetIt.I<AppSettings>().currencyCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'category_expense.title'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<CategoryExpense>>(
            stream: GetIt.I<LocalDatabase>().watchMonthlyCategoryExpense(
              selectedDate,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'category_expense.empty'.tr(),
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.mutedOf(context),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  final category =
                      data.category != ''
                          ? data.category
                          : 'common.unclassified'.tr();

                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineOf(context)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            CurrencyUtils.formatAmount(
                              data.total,
                              currencyCode,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
