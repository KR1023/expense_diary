import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/const/app_theme.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/data/firestore/firestore_transaction_repository.dart';
import 'package:expense_diary/data/firestore/transaction_dto.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CloudTransactionScreen extends StatefulWidget {
  const CloudTransactionScreen({super.key});

  @override
  State<CloudTransactionScreen> createState() => _CloudTransactionScreenState();
}

class _CloudTransactionScreenState extends State<CloudTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController(text: 'misc');
  final _memoController = TextEditingController();

  LedgerTransactionType _selectedType = LedgerTransactionType.expense;
  DateTime _selectedSpentAt = DateTime.now();
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String? _editingId;
  bool _isSaving = false;

  String get _yyyyMM =>
      '${_selectedMonth.year}${_selectedMonth.month.toString().padLeft(2, '0')}';

  FirestoreTransactionRepository get _repo =>
      GetIt.I<FirestoreTransactionRepository>();

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await AppTheme.showDatePickerDialog(
      context: context,
      initialDate: _selectedSpentAt,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedSpentAt = picked;
      _selectedMonth = DateTime(picked.year, picked.month);
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedType = LedgerTransactionType.expense;
      _selectedSpentAt = DateTime.now();
    });
    _amountController.clear();
    _categoryController.text = 'misc';
    _memoController.clear();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final dto = TransactionDto(
        id: _editingId ?? '',
        amount: int.parse(_amountController.text.trim()),
        type: _selectedType,
        categoryId: _categoryController.text.trim(),
        memo: _memoController.text.trim(),
        spentAt: _selectedSpentAt,
        createdAt: now,
        updatedAt: now,
      );
      await _repo.createOrUpdate(dto);
      if (!mounted) return;
      _clearForm();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('cloud_tx.saved'.tr())));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('cloud_tx.error.generic'.tr())));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _delete(String id) async {
    await _repo.delete(id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('cloud_tx.deleted'.tr())));
  }

  void _startEdit(TransactionDto tx) {
    setState(() {
      _editingId = tx.id;
      _selectedType = tx.type;
      _selectedSpentAt = tx.spentAt;
      _selectedMonth = DateTime(tx.spentAt.year, tx.spentAt.month);
    });
    _amountController.text = tx.amount.toString();
    _categoryController.text = tx.categoryId;
    _memoController.text = tx.memo;
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = GetIt.I<AppSettings>().currencyCode;
    final dateText = DateFormat('yyyy.MM.dd').format(_selectedSpentAt);
    final monthText = DateFormat('yyyy.MM').format(_selectedMonth);

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
                    'cloud_tx.title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                'cloud_tx.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<LedgerTransactionType>(
                              segments: [
                                ButtonSegment(
                                  value: LedgerTransactionType.expense,
                                  label: Text('cloud_tx.type.expense'.tr()),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                ButtonSegment(
                                  value: LedgerTransactionType.income,
                                  label: Text('cloud_tx.type.income'.tr()),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                              selected: {_selectedType},
                              onSelectionChanged: (values) {
                                setState(() {
                                  _selectedType = values.first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'cloud_tx.form.amount'.tr(),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return 'cloud_tx.error.amount'.tr();
                          if (int.tryParse(text) == null) {
                            return 'cloud_tx.error.amount'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'cloud_tx.form.category'.tr(),
                          prefixIcon: const Icon(Icons.sell_outlined),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'cloud_tx.error.category'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _memoController,
                        decoration: InputDecoration(
                          labelText: 'cloud_tx.form.memo'.tr(),
                          prefixIcon: const Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'cloud_tx.form.spent_at'.tr(),
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                          ),
                          child: Row(
                            children: [
                              Text(dateText),
                              const Spacer(),
                              const Icon(Icons.expand_more_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : _clearForm,
                              child: Text('cloud_tx.form.clear'.tr()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: _isSaving ? null : _save,
                              child: Text(
                                (_editingId == null
                                        ? 'cloud_tx.form.create'
                                        : 'cloud_tx.form.update')
                                    .tr(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month - 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Text(
                        '${'cloud_tx.month'.tr()} $monthText',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<TransactionDto>>(
                stream: _repo.watchByMonth(_yyyyMM),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('cloud_tx.error.generic'.tr()));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'cloud_tx.empty'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedOf(context),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = items[index];
                      final sign =
                          tx.type == LedgerTransactionType.expense ? '-' : '+';
                      final amountText = CurrencyUtils.formatAmount(
                        tx.amount,
                        currencyCode,
                      );
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                tx.type == LedgerTransactionType.expense
                                    ? AppColors.danger.withValues(alpha: 0.12)
                                    : AppColors.secondary.withValues(alpha: 0.12),
                            child: Icon(
                              tx.type == LedgerTransactionType.expense
                                  ? Icons.remove
                                  : Icons.add,
                              color:
                                  tx.type == LedgerTransactionType.expense
                                      ? AppColors.danger
                                      : AppColors.secondary,
                            ),
                          ),
                          title: Text(
                            tx.categoryId.isEmpty
                                ? 'common.unclassified'.tr()
                                : tx.categoryId,
                          ),
                          subtitle: Text(
                            '${DateFormat('yyyy.MM.dd').format(tx.spentAt)}'
                            '${tx.memo.isNotEmpty ? ' • ${tx.memo}' : ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: SizedBox(
                            width: 132,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    '$sign$amountText',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _startEdit(tx);
                                      return;
                                    }
                                    if (value == 'delete') {
                                      await _delete(tx.id);
                                    }
                                  },
                                  itemBuilder:
                                      (_) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('common.edit'.tr()),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('common.delete'.tr()),
                                        ),
                                      ],
                                ),
                              ],
                            ),
                          ),
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
}
