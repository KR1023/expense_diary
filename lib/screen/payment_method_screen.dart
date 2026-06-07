import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/screen/subscription_screen.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  'payment_method.manage_title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Text(
              'payment_method.manage_subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<PaymentMethod>>(
                stream: GetIt.I<LocalDatabase>().watchPaymentMethods(),
                builder: (context, snapshot) {
                  final methods = snapshot.data ?? [];

                  if (methods.isEmpty) {
                    return Center(
                      child: Text(
                        'payment_method.empty'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedOf(context),
                        ),
                      ),
                    );
                  }

                  return ReorderableListView.builder(
                    itemCount: methods.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) newIndex--;
                      final reordered = [...methods];
                      final item = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, item);
                      await GetIt.I<LocalDatabase>().reorderPaymentMethods(
                        reordered.map((m) => m.id).toList(),
                      );
                    },
                    itemBuilder: (context, index) {
                      final method = methods[index];
                      return _PaymentMethodTile(
                        key: ValueKey(method.id),
                        method: method,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: GetIt.I<AppSettings>(),
              builder: (context, _) {
                final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
                final accentColor =
                    AppColors.accentColorForBackground(bgIndex, context);
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                    ),
                    onPressed: () => _showForm(context, null),
                    icon: const Icon(Icons.add),
                    label: Text('payment_method.add_title'.tr()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showForm(BuildContext context, PaymentMethod? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentMethodForm(existing: existing),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({super.key, required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _TypeIcon(type: method.type),
        title: Text(method.name),
        subtitle:
            method.memo?.isNotEmpty == true
                ? Text(
                  method.memo!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                )
                : Text(
                  'payment_method.type.${method.type}'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showForm(context, method),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _confirmDelete(context, method),
            ),
            const Icon(Icons.drag_handle_rounded),
          ],
        ),
      ),
    );
  }

  void _showForm(BuildContext context, PaymentMethod? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentMethodForm(existing: existing),
    );
  }

  void _confirmDelete(BuildContext context, PaymentMethod method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('payment_method.delete_confirm'.tr().split('\n').first),
            content: Text('payment_method.delete_confirm'.tr()),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('common.cancel'.tr()),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('common.delete'.tr()),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await GetIt.I<LocalDatabase>().archivePaymentMethod(method.id);
    }
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      'cash' => Icons.money_rounded,
      'card' => Icons.credit_card_rounded,
      'bank' => Icons.account_balance_rounded,
      'mobilePay' => Icons.phone_android_rounded,
      _ => Icons.payment_rounded,
    };
    return AnimatedBuilder(
      animation: GetIt.I<AppSettings>(),
      builder: (context, _) {
        final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
        final accentColor = AppColors.accentColorForBackground(bgIndex, context);
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: accentColor),
        );
      },
    );
  }
}

class _PaymentMethodForm extends StatefulWidget {
  const _PaymentMethodForm({this.existing});
  final PaymentMethod? existing;

  @override
  State<_PaymentMethodForm> createState() => _PaymentMethodFormState();
}

class _PaymentMethodFormState extends State<_PaymentMethodForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _memoCtrl;
  String _type = 'card';

  static const _types = ['cash', 'card', 'bank', 'mobilePay', 'other'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _memoCtrl = TextEditingController(text: widget.existing?.memo ?? '');
    _type = widget.existing?.type ?? 'card';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AnimatedBuilder(
      animation: GetIt.I<AppSettings>(),
      builder: (context, _) {
        final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
        final bgColor = AppColors.cardColorOf(bgIndex, context);
        final gradient = AppColors.heroGradientForBackground(bgIndex, context);
        final accentColor = AppColors.accentColorForBackground(bgIndex, context);
        final outlineColor = AppColors.outlineColorOf(bgIndex, context);
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient header
              Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        children: [
                          Icon(
                            isEdit ? Icons.edit_outlined : Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEdit
                                ? 'payment_method.edit_title'.tr()
                                : 'payment_method.add_title'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Form content
              Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'payment_method.type_label'.tr(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.mutedOf(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _types.map((t) {
                          final selected = _type == t;
                          return FilterChip(
                            label: Text('payment_method.type.$t'.tr()),
                            selected: selected,
                            onSelected: (_) => setState(() => _type = t),
                            backgroundColor:
                                outlineColor.withValues(alpha: 0.15),
                            selectedColor:
                                accentColor.withValues(alpha: 0.12),
                            checkmarkColor: accentColor,
                            side: BorderSide(
                              color: selected ? accentColor : outlineColor,
                              width: selected ? 1.4 : 1.0,
                            ),
                            labelStyle: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: selected
                                  ? accentColor
                                  : AppColors.inkOf(context),
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'payment_method.name_label'.tr(),
                          hintText: 'payment_method.name_hint'.tr(),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty)
                                ? 'payment_method.name_required'.tr()
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _memoCtrl,
                        decoration: InputDecoration(
                          labelText: 'payment_method.memo_label'.tr(),
                          hintText: 'payment_method.memo_hint'.tr(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: accentColor,
                          ),
                          onPressed: _save,
                          child: Text('common.save'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = GetIt.I<LocalDatabase>();
    final now = DateTime.now();

    if (widget.existing == null) {
      final methods = await db.getPaymentMethods();
      final name = _nameCtrl.text.trim();
      final memo = _memoCtrl.text.trim();
      final activeDuplicate = await db.findPaymentMethodByTypeAndName(
        type: _type,
        name: name,
        isArchived: false,
      );
      if (activeDuplicate != null) {
        if (mounted) _showInfoDialog('payment_method.duplicate_error'.tr());
        return;
      }

      final isSubscribed = GetIt.I<SubscriptionService>().isCloudEntitled;
      if (!isSubscribed && methods.length >= 5) {
        if (mounted) _showLimitDialog();
        return;
      }

      final archivedDuplicate = await db.findPaymentMethodByTypeAndName(
        type: _type,
        name: name,
        isArchived: true,
      );
      if (archivedDuplicate != null) {
        final restore = await _confirmRestore();
        if (restore != true) return;
        await db.restorePaymentMethod(
          archivedDuplicate,
          memo: memo,
          sortOrder: methods.length,
        );
        if (mounted) Navigator.of(context).pop();
        return;
      }

      await db.createPaymentMethod(
        PaymentMethodsCompanion(
          type: Value(_type),
          name: Value(name),
          memo: Value(memo.isEmpty ? null : memo),
          sortOrder: Value(methods.length),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    } else {
      final name = _nameCtrl.text.trim();
      final memo = _memoCtrl.text.trim();
      final activeDuplicate = await db.findPaymentMethodByTypeAndName(
        type: _type,
        name: name,
        isArchived: false,
        excludeId: widget.existing!.id,
      );
      if (activeDuplicate != null) {
        if (mounted) _showInfoDialog('payment_method.duplicate_error'.tr());
        return;
      }

      await db.updatePaymentMethod(
        PaymentMethodsCompanion(
          id: Value(widget.existing!.id),
          type: Value(_type),
          name: Value(name),
          memo: Value(memo.isEmpty ? null : memo),
          updatedAt: Value(now),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<bool?> _confirmRestore() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('payment_method.restore_title'.tr()),
        content: Text('payment_method.restore_message'.tr()),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('payment_method.restore_action'.tr()),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('payment_method.add_title'.tr()),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('common.confirm'.tr()),
          ),
        ],
      ),
    );
  }

  void _showLimitDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('subscription.limit_payment_title'.tr()),
        content: Text('subscription.limit_payment_msg'.tr()),
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
}
