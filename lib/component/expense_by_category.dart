import 'package:expense_diary/model/category_expense.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class ExpenseByCategory extends StatelessWidget {
  final DateTime selectedDate;

  ExpenseByCategory({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat('#,###');

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
        StreamBuilder<List<CategoryExpense>>(
          stream: GetIt.I<LocalDatabase>().watchMonthlyCategoryExpense(
            selectedDate,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data?.length == 0) {
              return SizedBox(
                height: MediaQuery.of(context).size.height / 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'category_expense.empty'.tr(),
                        style: TextStyle(
                          fontSize: 20.0,
                          color: AppColors.mutedOf(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  String category;
                  if (data.category != '')
                    category = data.category;
                  else
                    category = 'common.unclassified'.tr();

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
                            '${numberFormatter.format(data.total)}${'common.currency_suffix'.tr()}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                  //   ListTile(
                  //     title: Text('${category}'),
                  //     subtitle: Text('합계: ${data.total}원')
                  // );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
