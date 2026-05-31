import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/component/expense_card.dart';
import 'package:expense_diary/screen/add_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:intl/intl.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/service/app_settings.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final selectedDate = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: AppBackground(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BannerAdWidget(),
            const SizedBox(height: 12),
            Text(
              'home.title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              DateFormat('yyyy.MM.dd').format(selectedDate),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<int>(
              stream: GetIt.I<LocalDatabase>().selectDayExpense(selectedDate),
              builder: (context, totalSnapshot) {
                final currencyCode = GetIt.I<AppSettings>().currencyCode;
                final total = totalSnapshot.data ?? 0;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradientOf(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'home.today_total'.tr(),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyUtils.formatAmount(total, currencyCode),
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            StreamBuilder<List<Map<String, dynamic>>>(
                              stream: GetIt.I<LocalDatabase>().watchExpense(
                                selectedDate,
                              ),
                              builder: (context, countSnapshot) {
                                final count = countSnapshot.data?.length ?? 0;
                                return Text(
                                  'home.count_label'.tr(
                                    namedArgs: {'count': '$count'},
                                  ),
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: Colors.white),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: GetIt.I<LocalDatabase>().watchExpense(selectedDate),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        'home.empty'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedOf(context),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final expense = data[index]['expenses'];
                      final category = data[index]['category'];
                      final paymentMethod = data[index]['paymentMethod'];

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 240 + (index * 40)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: ExpenseCard(
                          expenseId: expense.id,
                          category: category,
                          paymentMethod: paymentMethod,
                          expenseName: expense.expenseName,
                          expense: expense.expense,
                          expenseDate: expense.expenseDate,
                          expenseDetail: expense.expenseDetail ?? '',
                          isRecurring: expense.recurringExpenseId != null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton floatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'home_fab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddScreen()),
        );
      },
      icon: Icon(Icons.add),
      label: Text('common.add'.tr()),
    );
  }
}
