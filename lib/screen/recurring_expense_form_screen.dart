import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/const/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/category_select.dart';
import 'package:expense_diary/component/common/thousands_formatter.dart';
import 'package:expense_diary/component/common/toast.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:expense_diary/screen/subscription_screen.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/component/payment_method_select.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/core/recurring/recurring_expense_service.dart';
import 'package:expense_diary/core/recurring/recurring_schedule.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class RecurringExpenseFormScreen extends StatefulWidget {
  const RecurringExpenseFormScreen({super.key, this.existing});
  final RecurringExpense? existing;

  @override
  State<RecurringExpenseFormScreen> createState() =>
      _RecurringExpenseFormScreenState();
}

class _RecurringExpenseFormScreenState
    extends State<RecurringExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _detailCtrl;

  int? _categoryId;
  CategoryData? _category;
  int? _paymentMethodId;
  PaymentMethod? _paymentMethod;
  String _frequency = 'monthly';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _noEndDate = true;

  static const _frequencies = ['daily', 'weekly', 'monthly', 'yearly'];
  final _dateFmt = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl = TextEditingController(
        text: e != null ? ThousandsFormatter.format(e.amount) : '');
    _detailCtrl = TextEditingController(text: e?.detail ?? '');
    _frequency = e?.frequency ?? 'monthly';
    _startDate = e?.startDate;
    _endDate = e?.endDate;
    _noEndDate = e?.endDate == null;
    _categoryId = e?.categoryId;
    _paymentMethodId = e?.paymentMethodId;
    if (e != null) _loadExistingRelations(e);
  }

  void _showLimitDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('subscription.limit_recurring_title'.tr()),
        content: Text('subscription.limit_recurring_msg'.tr()),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SubscriptionScreen(),
                ),
              );
            },
            child: Text('subscription.upgrade_plan'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _loadExistingRelations(RecurringExpense e) async {
    final db = GetIt.I<LocalDatabase>();

    CategoryData? category;
    if (e.categoryId != null) {
      final all = await db.select(db.category).get();
      category = all.where((c) => c.id == e.categoryId).firstOrNull;
    }

    PaymentMethod? paymentMethod;
    if (e.paymentMethodId != null) {
      final all = await db.getPaymentMethods();
      paymentMethod = all.where((m) => m.id == e.paymentMethodId).firstOrNull;
    }

    if (mounted) {
      setState(() {
        _category = category;
        _paymentMethod = paymentMethod;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                Text(
                  isEdit
                      ? 'recurring_expense.edit_title'.tr()
                      : 'recurring_expense.add_title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText:
                                  'recurring_expense.name_label'.tr(),
                              hintText: 'recurring_expense.name_hint'.tr(),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'recurring_expense.name_required'.tr()
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: InputDecoration(
                              labelText:
                                  'recurring_expense.amount_label'.tr(),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'recurring_expense.amount_required'
                                    .tr();
                              }
                              if (int.tryParse(v.replaceAll(',', '')) == null) {
                                return 'recurring_expense.amount_required'
                                    .tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // 반복 주기
                          Text(
                            'recurring_expense.frequency_label'.tr(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _frequencies.map((f) {
                              return ChoiceChip(
                                label: Text(
                                  'recurring_expense.frequency.$f'.tr(),
                                ),
                                selected: _frequency == f,
                                onSelected: (_) =>
                                    setState(() => _frequency = f),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          // 분류
                          CategorySelect(
                            selectedValue: _category,
                            showIcon: false,
                            onSavedCategory: (val) {
                              _categoryId = val?.id;
                              _category = val;
                            },
                          ),
                          const SizedBox(height: 20),
                          // 결제 수단
                          PaymentMethodSelect(
                            selectedValue: _paymentMethod,
                            showIcon: false,
                            onSaved: (val) {
                              _paymentMethodId = val?.id;
                              _paymentMethod = val;
                            },
                          ),
                          const SizedBox(height: 20),
                          // 시작일
                          _DateField(
                            label: 'recurring_expense.start_date_label'.tr(),
                            value: _startDate,
                            onPicked: (d) =>
                                setState(() => _startDate = d),
                          ),
                          const SizedBox(height: 16),
                          // 종료일
                          Row(
                            children: [
                              Checkbox(
                                value: _noEndDate,
                                onChanged: (v) => setState(
                                    () => _noEndDate = v ?? true),
                              ),
                              Text(
                                'recurring_expense.no_end_date'.tr(),
                              ),
                            ],
                          ),
                          if (!_noEndDate) ...[
                            const SizedBox(height: 8),
                            _DateField(
                              label:
                                  'recurring_expense.end_date_label'.tr(),
                              value: _endDate,
                              onPicked: (d) =>
                                  setState(() => _endDate = d),
                            ),
                          ],
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _detailCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText:
                                  'recurring_expense.detail_label'.tr(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              if (widget.existing != null) ...[
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                    side: BorderSide(
                                        color: AppColors.danger),
                                  ),
                                  onPressed: _delete,
                                  child: Text('common.delete'.tr()),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: FilledButton(
                                  onPressed: _save,
                                  child: Text('common.save'.tr()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('recurring_expense.start_date_required'.tr()),
        ),
      );
      return;
    }

    if (!_noEndDate &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('recurring_expense.end_date_before_start'.tr()),
        ),
      );
      return;
    }

    final db = GetIt.I<LocalDatabase>();
    final now = DateTime.now();
    final amount = ThousandsFormatter.parse(_amountCtrl.text.trim());
    final endDate = _noEndDate ? null : _endDate;

    // 무료 플랜 한도 체크 (추가 시에만)
    if (widget.existing == null) {
      final isSubscribed =
          GetIt.I<SubscriptionService>().isCloudEntitled;
      if (!isSubscribed) {
        final count = await db.countActiveRecurringExpenses();
        if (count >= 10) {
          if (mounted) _showLimitDialog();
          return;
        }
      }
    }

    if (widget.existing == null) {
      await db.createRecurringExpense(
        RecurringExpensesCompanion(
          name: Value(_nameCtrl.text.trim()),
          amount: Value(amount),
          categoryId: Value(_categoryId),
          paymentMethodId: Value(_paymentMethodId),
          detail: Value(
              _detailCtrl.text.trim().isEmpty ? null : _detailCtrl.text.trim()),
          frequency: Value(_frequency),
          interval: const Value(1),
          startDate: Value(_startDate!),
          endDate: Value(endDate),
          nextRunDate: Value(_startDate!),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    } else {
      final e = widget.existing!;
      // nextRunDate: 시작일이 변경된 경우 재계산, 그렇지 않으면 유지
      final nextRun = _startDate != e.startDate ? _startDate! : e.nextRunDate;
      await db.updateRecurringExpense(
        RecurringExpensesCompanion(
          id: Value(e.id),
          name: Value(_nameCtrl.text.trim()),
          amount: Value(amount),
          categoryId: Value(_categoryId),
          paymentMethodId: Value(_paymentMethodId),
          detail: Value(
              _detailCtrl.text.trim().isEmpty ? null : _detailCtrl.text.trim()),
          frequency: Value(_frequency),
          startDate: Value(_startDate!),
          endDate: Value(endDate),
          nextRunDate: Value(nextRun),
          updatedAt: Value(now),
        ),
      );
    }

    // 저장 직후 due 지출 생성
    await RecurringExpenseService.generateDueExpenses();

    if (mounted) {
      showToast(
        context,
        widget.existing == null
            ? 'recurring_expense.toast_added'.tr()
            : 'recurring_expense.toast_updated'.tr(),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.existing!.name),
        content: Text('recurring_expense.delete_confirm'.tr()),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await GetIt.I<LocalDatabase>()
        .deleteRecurringExpense(widget.existing!.id);
    if (mounted) {
      showToast(context, 'recurring_expense.toast_deleted'.tr(),
          icon: Icons.delete_outline);
      Navigator.of(context).pop();
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final picked = await AppTheme.showDatePickerDialog(
          context: context,
          initialDate: value ?? DateTime.now(),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineOf(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value != null
                      ? DateFormat('yyyy.MM.dd').format(value!)
                      : '날짜 선택',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
