import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/core/recurring/recurring_expense_service.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/screen/recurring_expense_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class RecurringExpenseScreen extends StatefulWidget {
  const RecurringExpenseScreen({super.key});

  @override
  State<RecurringExpenseScreen> createState() =>
      _RecurringExpenseScreenState();
}

class _RecurringExpenseScreenState extends State<RecurringExpenseScreen> {
  @override
  void initState() {
    super.initState();
    RecurringExpenseService.generateDueExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'recurring_expense.title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'recurring_expense.subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<RecurringExpense>>(
                stream:
                    GetIt.I<LocalDatabase>().watchRecurringExpenses(),
                builder: (context, snapshot) {
                  final all = snapshot.data ?? [];
                  final active =
                      all.where((r) => r.isActive).toList();
                  final inactive =
                      all.where((r) => !r.isActive).toList();

                  if (all.isEmpty) {
                    return Center(
                      child: Text(
                        'recurring_expense.empty'.tr(),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mutedOf(context),
                                ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      if (active.isNotEmpty) ...[
                        _SectionHeader(
                            'recurring_expense.section_active'.tr()),
                        ...active.map(
                          (r) => _RecurringExpenseTile(item: r),
                        ),
                      ],
                      if (inactive.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SectionHeader(
                            'recurring_expense.section_inactive'.tr()),
                        ...inactive.map(
                          (r) => _RecurringExpenseTile(item: r),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recurring_expense_fab',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RecurringExpenseFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: Text('common.add'.tr()),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.mutedOf(context),
            ),
      ),
    );
  }
}

class _RecurringExpenseTile extends StatelessWidget {
  const _RecurringExpenseTile({required this.item});
  final RecurringExpense item;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    final frequencyLabel =
        'recurring_expense.frequency.${item.frequency}'.tr();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: item.isActive
                              ? null
                              : AppColors.mutedOf(context),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$frequencyLabel · ${_formatAmount(item.amount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedOf(context),
                        ),
                  ),
                  if (item.isActive) ...[
                    const SizedBox(height: 2),
                    Text(
                      'recurring_expense.next_run'.tr(
                        namedArgs: {
                          'date': dateFormat.format(item.nextRunDate),
                        },
                      ),
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                              ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecurringExpenseFormScreen(existing: item),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                item.isActive
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: item.isActive
                    ? AppColors.mutedOf(context)
                    : AppColors.primary,
              ),
              onPressed: () => _toggleActive(context, item),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return NumberFormat('#,###').format(amount);
  }

  Future<void> _toggleActive(
      BuildContext context, RecurringExpense item) async {
    if (item.isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text('recurring_expense.deactivate_confirm'.tr()),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('recurring_expense.deactivate'.tr()),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await GetIt.I<LocalDatabase>().deactivateRecurringExpense(item.id);
    } else {
      await GetIt.I<LocalDatabase>().updateRecurringExpense(
        RecurringExpensesCompanion(
          id: Value(item.id),
          isActive: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }
}
