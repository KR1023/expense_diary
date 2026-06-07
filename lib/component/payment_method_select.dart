import 'package:expense_diary/component/common/select_field.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/screen/subscription_screen.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentMethodSelect extends StatefulWidget {
  final PaymentMethod? selectedValue;
  final FormFieldSetter<PaymentMethod> onSaved;
  final bool showIcon;

  const PaymentMethodSelect({
    super.key,
    this.selectedValue,
    required this.onSaved,
    this.showIcon = true,
  });

  @override
  State<PaymentMethodSelect> createState() => _PaymentMethodSelectState();
}

class _PaymentMethodSelectState extends State<PaymentMethodSelect> {
  PaymentMethod? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(PaymentMethodSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        _selectedValue = widget.selectedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PaymentMethod>>(
      stream: GetIt.I<LocalDatabase>().watchPaymentMethods(),
      builder: (context, snapshot) {
        final methods = snapshot.data ?? [];
        final options = [...methods];
        final selected = _resolveSelectedPaymentMethod(methods);
        if (selected != null && !options.any((m) => m.id == selected.id)) {
          options.add(selected);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SelectField<PaymentMethod>(
                label: 'payment_method.select_label'.tr(),
                hint: 'payment_method.select_hint'.tr(),
                icon: widget.showIcon ? Icons.credit_card_outlined : null,
                value: selected,
                options:
                    options.map((m) {
                      return SelectOption<PaymentMethod>(
                        value: m,
                        label:
                            m.isArchived
                                ? 'payment_method.archived_label'.tr(
                                  args: [m.name],
                                )
                                : m.name,
                        icon: _iconForType(m.type),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _selectedValue = val),
                onSaved: widget.onSaved,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: IconButton.filledTonal(
                tooltip: 'payment_method.quick_add'.tr(),
                style: _actionButtonStyle(context),
                icon: const Icon(Icons.add_rounded),
                onPressed: _quickAddPaymentMethod,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: IconButton.filledTonal(
                tooltip: 'common.cancel'.tr(),
                style: _actionButtonStyle(context),
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedValue = null),
              ),
            ),
          ],
        );
      },
    );
  }

  PaymentMethod? _resolveSelectedPaymentMethod(List<PaymentMethod> methods) {
    final selected = _selectedValue;
    if (selected == null) return null;

    for (final method in methods) {
      if (method.id == selected.id) return method;
    }
    return selected;
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'cash' => Icons.money_rounded,
      'card' => Icons.credit_card_rounded,
      'bank' => Icons.account_balance_rounded,
      'mobilePay' => Icons.phone_android_rounded,
      _ => Icons.payment_rounded,
    };
  }

  ButtonStyle _actionButtonStyle(BuildContext context) {
    return IconButton.styleFrom(
      backgroundColor: AppColors.surfaceAltOf(context),
      foregroundColor: AppColors.mutedOf(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.outlineOf(context)),
      ),
    );
  }

  Future<void> _quickAddPaymentMethod() async {
    final db = GetIt.I<LocalDatabase>();
    final methods = await db.getPaymentMethods();
    final isSubscribed = GetIt.I<SubscriptionService>().isCloudEntitled;
    if (!isSubscribed && methods.length >= 5) {
      if (mounted) _showLimitDialog();
      return;
    }

    if (!mounted) return;
    final created = await showDialog<PaymentMethod>(
      context: context,
      builder: (_) => _QuickPaymentMethodDialog(sortOrder: methods.length),
    );

    if (created == null || !mounted) return;
    setState(() {
      _selectedValue = created;
    });
  }

  void _showLimitDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AnimatedBuilder(
          animation: GetIt.I<AppSettings>(),
          builder: (context, _) {
            final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
            final cardColor = AppColors.cardColorOf(bgIndex, context);
            final gradient =
                AppColors.heroGradientForBackground(bgIndex, context);
            final accentColor =
                AppColors.accentColorForBackground(bgIndex, context);
            final outlineColor = AppColors.outlineColorOf(bgIndex, context);

            return Dialog(
              backgroundColor: cardColor,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogHeader(
                    gradient: gradient,
                    icon: Icons.workspace_premium_outlined,
                    title: 'subscription.limit_payment_title'.tr(),
                    onClose: () => Navigator.of(ctx).pop(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      'subscription.limit_payment_msg'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: outlineColor),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text('common.cancel'.tr()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: accentColor,
                            ),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final VoidCallback onClose;

  const _DialogHeader({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPaymentMethodDialog extends StatefulWidget {
  const _QuickPaymentMethodDialog({required this.sortOrder});

  final int sortOrder;

  @override
  State<_QuickPaymentMethodDialog> createState() =>
      _QuickPaymentMethodDialogState();
}

class _QuickPaymentMethodDialogState
    extends State<_QuickPaymentMethodDialog> {
  static const List<String> _types = [
    'cash',
    'card',
    'bank',
    'mobilePay',
    'other',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String _type = 'card';

  @override
  void dispose() {
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = GetIt.I<LocalDatabase>();
    final now = DateTime.now();
    final name = _nameController.text.trim();
    final memo = _memoController.text.trim();
    final activeDuplicate = await db.findPaymentMethodByTypeAndName(
      type: _type,
      name: name,
      isArchived: false,
    );
    if (activeDuplicate != null) {
      if (mounted) _showInfoDialog('payment_method.duplicate_error'.tr());
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
      final restored = await db.restorePaymentMethod(
        archivedDuplicate,
        memo: memo,
        sortOrder: widget.sortOrder,
      );
      if (!mounted) return;
      Navigator.of(context).pop(restored);
      return;
    }

    final id = await db.createPaymentMethod(
      PaymentMethodsCompanion(
        type: Value(_type),
        name: Value(name),
        memo: Value(memo.isEmpty ? null : memo),
        sortOrder: Value(widget.sortOrder),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(
      PaymentMethod(
        id: id,
        type: _type,
        name: name,
        memo: memo.isEmpty ? null : memo,
        sortOrder: widget.sortOrder,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<bool?> _confirmRestore() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AnimatedBuilder(
          animation: GetIt.I<AppSettings>(),
          builder: (context, _) {
            final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
            final cardColor = AppColors.cardColorOf(bgIndex, context);
            final gradient =
                AppColors.heroGradientForBackground(bgIndex, context);
            final accentColor =
                AppColors.accentColorForBackground(bgIndex, context);
            final outlineColor = AppColors.outlineColorOf(bgIndex, context);

            return Dialog(
              backgroundColor: cardColor,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogHeader(
                    gradient: gradient,
                    icon: Icons.restore_rounded,
                    title: 'payment_method.restore_title'.tr(),
                    onClose: () => Navigator.of(ctx).pop(false),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      'payment_method.restore_message'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: outlineColor),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text('common.cancel'.tr()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: accentColor,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(
                              'payment_method.restore_action'.tr(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showInfoDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AnimatedBuilder(
          animation: GetIt.I<AppSettings>(),
          builder: (context, _) {
            final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
            final cardColor = AppColors.cardColorOf(bgIndex, context);
            final gradient =
                AppColors.heroGradientForBackground(bgIndex, context);
            final accentColor =
                AppColors.accentColorForBackground(bgIndex, context);

            return Dialog(
              backgroundColor: cardColor,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogHeader(
                    gradient: gradient,
                    icon: Icons.info_outline_rounded,
                    title: 'payment_method.add_title'.tr(),
                    onClose: () => Navigator.of(ctx).pop(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('common.confirm'.tr()),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GetIt.I<AppSettings>(),
      builder: (context, _) {
        final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
        final cardColor = AppColors.cardColorOf(bgIndex, context);
        final gradient = AppColors.heroGradientForBackground(bgIndex, context);
        final accentColor = AppColors.accentColorForBackground(bgIndex, context);
        final outlineColor = AppColors.outlineColorOf(bgIndex, context);

        return Dialog(
          backgroundColor: cardColor,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient header
              _DialogHeader(
                gradient: gradient,
                icon: Icons.credit_card_outlined,
                title: 'payment_method.add_title'.tr(),
                onClose: () => Navigator.of(context).pop(),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'payment_method.type_label'.tr(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _types.map((type) {
                                final selected = _type == type;
                                return FilterChip(
                                  label: Text(
                                    'payment_method.type.$type'.tr(),
                                  ),
                                  selected: selected,
                                  backgroundColor: outlineColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  selectedColor: accentColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  checkmarkColor: accentColor,
                                  side: BorderSide(
                                    color:
                                        selected ? accentColor : outlineColor,
                                    width: selected ? 1.4 : 1.0,
                                  ),
                                  labelStyle: TextStyle(
                                    color: selected ? accentColor : null,
                                    fontWeight:
                                        selected ? FontWeight.w600 : null,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _type = type),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'payment_method.name_label'.tr(),
                            hintText: 'payment_method.name_hint'.tr(),
                            prefixIcon: Icon(
                              Icons.payment_rounded,
                              color: accentColor,
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'payment_method.name_required'.tr()
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _memoController,
                          decoration: InputDecoration(
                            labelText: 'payment_method.memo_label'.tr(),
                            hintText: 'payment_method.memo_hint'.tr(),
                            prefixIcon: Icon(
                              Icons.notes_rounded,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: outlineColor),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('common.cancel'.tr()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
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
            ],
          ),
        );
      },
    );
  }
}
