import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:expense_diary/component/common/toast.dart';
import 'package:expense_diary/component/common/thousands_formatter.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _inputCategoryController =
      TextEditingController();
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _inputCategoryController.addListener(() {
      setState(() {
        _keyword = _inputCategoryController.text;
      });
    });
  }

  @override
  void dispose() {
    _inputCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'category.manage_title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () => _showCategoryDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text('common.add'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputCategoryController,
              decoration: InputDecoration(
                hintText: 'category.search_hint'.tr(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: GetIt.I<LocalDatabase>().watchCategory(
                  _keyword.isEmpty ? null : _keyword,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'category.empty'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedOf(context),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final category = snapshot.data![index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showCategoryDialog(context, existing: category),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            title: Text(category.categoryName),
                            subtitle:
                                category.usePresetAmount ||
                                        category.autoFillExpenseName
                                    ? Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          if (category.usePresetAmount &&
                                              category.presetAmount != null)
                                            _OptionChip(
                                              icon: Icons.payments_outlined,
                                              label:
                                                  'category.preset_amount_chip'
                                                      .tr(
                                                        namedArgs: {
                                                          'amount': NumberFormat(
                                                            '#,###',
                                                          ).format(
                                                            category
                                                                .presetAmount,
                                                          ),
                                                        },
                                                      ),
                                            ),
                                          if (category.autoFillExpenseName)
                                            _OptionChip(
                                              icon: Icons.text_fields_rounded,
                                              label:
                                                  'category.auto_name_chip'
                                                      .tr(),
                                            ),
                                        ],
                                      ),
                                    )
                                    : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteCategory(category),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(CategoryData category) async {
    final db = GetIt.I<LocalDatabase>();
    final count = await db.countExpensesByCategory(category.id);
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              const SizedBox(width: 8),
              Expanded(child: Text('category.delete_title'.tr())),
            ],
          ),
          content: Text(
            count > 0
                ? 'category.delete_with_expenses'.tr(
                  namedArgs: {'count': '$count'},
                )
                : 'category.delete_confirm'.tr(),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                count > 0
                    ? 'category.delete_unassign_action'.tr()
                    : 'common.delete'.tr(),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await db.deleteCategoryAndUnassignExpenses(category.id);
    if (!mounted) return;
    showToast(
      context,
      'expense.toast_deleted'.tr(),
      icon: Icons.delete_outline_rounded,
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    CategoryData? existing,
  }) async {
    final isEditing = existing != null;
    final textController = TextEditingController(
      text: existing?.categoryName ?? '',
    );
    final amountController = TextEditingController(
      text: existing?.presetAmount == null
          ? ''
          : ThousandsFormatter.format(existing!.presetAmount!),
    );
    bool usePresetAmount = existing?.usePresetAmount ?? false;
    bool autoFillExpenseName = existing?.autoFillExpenseName ?? false;
    String? nameErrorText;
    String? amountErrorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AnimatedBuilder(
            animation: GetIt.I<AppSettings>(),
            builder: (context, _) {
              final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
              final gradient =
                  AppColors.heroGradientForBackground(bgIndex, context);
              final dialogBgColor = AppColors.cardColorOf(bgIndex, context);
              final dividerColor = AppColors.outlineColorOf(bgIndex, context);
              final accentColor =
                  AppColors.accentColorForBackground(bgIndex, context);

              return Dialog(
                backgroundColor: dialogBgColor,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420,
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Gradient header
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        decoration: BoxDecoration(gradient: gradient),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isEditing
                                    ? Icons.edit_outlined
                                    : Icons.label_outline,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isEditing
                                    ? 'category.edit_title'.tr()
                                    : 'category.input_title'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Scrollable content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          child: _CategoryDialogBody(
                            nameController: textController,
                            amountController: amountController,
                            nameHint: isEditing
                                ? 'category.edit_hint'.tr()
                                : 'category.input_hint'.tr(),
                            nameErrorText: nameErrorText,
                            amountErrorText: amountErrorText,
                            usePresetAmount: usePresetAmount,
                            autoFillExpenseName: autoFillExpenseName,
                            onUsePresetAmountChanged: (value) {
                              setDialogState(() {
                                usePresetAmount = value;
                                if (!value) {
                                  amountController.clear();
                                  amountErrorText = null;
                                }
                              });
                            },
                            onAutoFillExpenseNameChanged: (value) {
                              setDialogState(() => autoFillExpenseName = value);
                            },
                          ),
                        ),
                      ),
                      // Divider + actions
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: dividerColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: dividerColor),
                              ),
                              child: Text('common.cancel'.tr()),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: accentColor,
                              ),
                              onPressed: () async {
                                final presetAmount = int.tryParse(
                                  amountController.text.replaceAll(',', ''),
                                );
                                if (usePresetAmount && presetAmount == null) {
                                  setDialogState(() {
                                    amountErrorText =
                                        'category.preset_amount_required'.tr();
                                  });
                                  return;
                                }
                                try {
                                  if (isEditing) {
                                    await GetIt.I<LocalDatabase>()
                                        .updateCategory(
                                      CategoryCompanion(
                                        id: Value(existing.id),
                                        categoryName:
                                            Value(textController.text),
                                        usePresetAmount: Value(usePresetAmount),
                                        presetAmount: Value(
                                          usePresetAmount ? presetAmount : null,
                                        ),
                                        autoFillExpenseName: Value(
                                          autoFillExpenseName,
                                        ),
                                      ),
                                    );
                                    if (context.mounted) {
                                      showToast(
                                        context,
                                        'category.toast_updated'.tr(),
                                      );
                                    }
                                  } else {
                                    await GetIt.I<LocalDatabase>().addCategory(
                                      CategoryCompanion(
                                        categoryName:
                                            Value(textController.text),
                                        usePresetAmount: Value(usePresetAmount),
                                        presetAmount: Value(
                                          usePresetAmount ? presetAmount : null,
                                        ),
                                        autoFillExpenseName: Value(
                                          autoFillExpenseName,
                                        ),
                                      ),
                                    );
                                    if (context.mounted) {
                                      showToast(
                                        context,
                                        'category.toast_added'.tr(),
                                      );
                                    }
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (e.toString().contains('2067')) {
                                    setDialogState(() {
                                      nameErrorText =
                                          'category.duplicate_error'.tr();
                                    });
                                  }
                                }
                              },
                              child: Text('common.confirm'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryDialogBody extends StatelessWidget {
  const _CategoryDialogBody({
    required this.nameController,
    required this.amountController,
    required this.nameHint,
    required this.usePresetAmount,
    required this.autoFillExpenseName,
    required this.onUsePresetAmountChanged,
    required this.onAutoFillExpenseNameChanged,
    this.nameErrorText,
    this.amountErrorText,
  });

  final TextEditingController nameController;
  final TextEditingController amountController;
  final String nameHint;
  final String? nameErrorText;
  final String? amountErrorText;
  final bool usePresetAmount;
  final bool autoFillExpenseName;
  final ValueChanged<bool> onUsePresetAmountChanged;
  final ValueChanged<bool> onAutoFillExpenseNameChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'category.select_label'.tr(),
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.mutedOf(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: nameHint,
            errorText: nameErrorText,
            prefixIcon: const Icon(Icons.sell_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'category.default_options_title'.tr(),
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.mutedOf(context),
          ),
        ),
        const SizedBox(height: 8),
        _DialogOptionCard(
          icon: Icons.payments_outlined,
          title: 'category.preset_amount_option'.tr(),
          description: 'category.preset_amount_help'.tr(),
          checked: usePresetAmount,
          onChanged: onUsePresetAmountChanged,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: usePresetAmount
                ? Padding(
                    key: const ValueKey('amount-field'),
                    padding: const EdgeInsets.only(top: 12),
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsFormatter()],
                      decoration: InputDecoration(
                        hintText: 'category.preset_amount_hint'.tr(),
                        errorText: amountErrorText,
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-amount')),
          ),
        ),
        const SizedBox(height: 10),
        _DialogOptionCard(
          icon: Icons.text_fields_rounded,
          title: 'category.auto_name_option'.tr(),
          description: 'category.auto_name_help'.tr(),
          checked: autoFillExpenseName,
          onChanged: onAutoFillExpenseNameChanged,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _DialogOptionCard extends StatelessWidget {
  const _DialogOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.checked,
    required this.onChanged,
    this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: GetIt.I<AppSettings>(),
      builder: (context, _) {
        final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
        final accentColor = AppColors.accentColorForBackground(bgIndex, context);
        final outlineColor = AppColors.outlineColorOf(bgIndex, context);
        final borderColor = checked ? accentColor : outlineColor;
        final uncheckedBg = outlineColor.withValues(alpha: 0.18);

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(!checked),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: checked
                  ? accentColor.withValues(alpha: 0.08)
                  : uncheckedBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: checked ? 1.4 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: checked
                            ? accentColor.withValues(alpha: 0.14)
                            : outlineColor.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: checked ? accentColor : AppColors.mutedOf(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: checked
                                  ? accentColor
                                  : AppColors.inkOf(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: checked,
                      activeColor: accentColor,
                      checkColor: Colors.white,
                      onChanged: (value) => onChanged(value ?? false),
                    ),
                  ],
                ),
                if (child != null) child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltOf(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.mutedOf(context)),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mutedOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
