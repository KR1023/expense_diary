import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:expense_diary/component/common/toast.dart';
import 'package:expense_diary/component/common/thousands_formatter.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  String? _errorText;
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
                  onPressed: () {
                    _showInputDialog(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text('common.add'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputCategoryController,
              decoration: InputDecoration(
                hintText: 'category.search_hint'.tr(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 12),
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
                        onTap: () {
                          _showUpdateDialog(context, category);
                        },
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
                              icon: Icon(Icons.delete_outline),
                              onPressed: () async {
                                int count = await GetIt.I<LocalDatabase>()
                                    .countExpensesByCategory(category.id);
                                if (!context.mounted) return;
                                if (count > 0) {
                                  _showAlertDialog(
                                    context,
                                    'category.delete_blocked'.tr(),
                                  );
                                  return;
                                } else {
                                  await GetIt.I<LocalDatabase>().deleteCategory(
                                    category.id,
                                  );
                                  if (context.mounted) {
                                    showToast(
                                      context,
                                      'expense.toast_deleted'.tr(),
                                      icon: Icons.delete_outline_rounded,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('category.alert_title'.tr()),
            ],
          ),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInputDialog(BuildContext context) async {
    TextEditingController textController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    bool usePresetAmount = false;
    bool autoFillExpenseName = false;
    String? amountErrorText;
    _errorText = null;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.label_outline,
                      color: AppColors.primary,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('category.input_title'.tr())),
                ],
              ),
              content: _CategoryDialogBody(
                nameController: textController,
                amountController: amountController,
                nameHint: 'category.input_hint'.tr(),
                nameErrorText: _errorText,
                amountErrorText: amountErrorText,
                usePresetAmount: usePresetAmount,
                autoFillExpenseName: autoFillExpenseName,
                onUsePresetAmountChanged: (value) {
                  setState(() {
                    usePresetAmount = value;
                    if (!usePresetAmount) {
                      amountController.clear();
                      amountErrorText = null;
                    }
                  });
                },
                onAutoFillExpenseNameChanged: (value) {
                  setState(() {
                    autoFillExpenseName = value;
                  });
                },
              ),
              actions: <Widget>[
                OutlinedButton(
                  child: Text('common.cancel'.tr()),
                  onPressed: () {
                    setState(() {
                      _errorText = null;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  child: Text('common.confirm'.tr()),
                  onPressed: () async {
                    try {
                      final presetAmount = int.tryParse(
                        amountController.text.replaceAll(',', ''),
                      );
                      if (usePresetAmount && presetAmount == null) {
                        setState(() {
                          amountErrorText =
                              'category.preset_amount_required'.tr();
                        });
                        return;
                      }
                      await GetIt.I<LocalDatabase>().addCategory(
                        CategoryCompanion(
                          categoryName: Value(textController.text),
                          usePresetAmount: Value(usePresetAmount),
                          presetAmount: Value(
                            usePresetAmount ? presetAmount : null,
                          ),
                          autoFillExpenseName: Value(autoFillExpenseName),
                        ),
                      );
                      setState(() => _errorText = null);
                      if (context.mounted) {
                        showToast(context, 'category.toast_added'.tr());
                      }
                    } catch (e) {
                      bool conflictName = e.toString().contains('2067');
                      if (conflictName) {
                        setState(() {
                          _errorText = 'category.duplicate_error'.tr();
                        });
                        return;
                      }
                    }

                    setState(() {
                      _errorText = null;
                    });

                    if (!context.mounted) return;
                    Navigator.of(context).pop(textController.text);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUpdateDialog(
    BuildContext context,
    CategoryData category,
  ) async {
    TextEditingController textController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    textController.text = category.categoryName;
    amountController.text =
        category.presetAmount == null
            ? ''
            : ThousandsFormatter.format(category.presetAmount!);
    bool usePresetAmount = category.usePresetAmount;
    bool autoFillExpenseName = category.autoFillExpenseName;
    String? amountErrorText;
    _errorText = null;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('category.edit_title'.tr())),
                ],
              ),
              content: _CategoryDialogBody(
                nameController: textController,
                amountController: amountController,
                nameHint: 'category.edit_hint'.tr(),
                nameErrorText: _errorText,
                amountErrorText: amountErrorText,
                usePresetAmount: usePresetAmount,
                autoFillExpenseName: autoFillExpenseName,
                onUsePresetAmountChanged: (value) {
                  setState(() {
                    usePresetAmount = value;
                    if (!usePresetAmount) {
                      amountController.clear();
                      amountErrorText = null;
                    }
                  });
                },
                onAutoFillExpenseNameChanged: (value) {
                  setState(() {
                    autoFillExpenseName = value;
                  });
                },
              ),
              actions: <Widget>[
                OutlinedButton(
                  child: Text('common.cancel'.tr()),
                  onPressed: () {
                    setState(() {
                      _errorText = null;
                    });

                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  child: Text('common.confirm'.tr()),
                  onPressed: () async {
                    try {
                      final presetAmount = int.tryParse(
                        amountController.text.replaceAll(',', ''),
                      );
                      if (usePresetAmount && presetAmount == null) {
                        setState(() {
                          amountErrorText =
                              'category.preset_amount_required'.tr();
                        });
                        return;
                      }
                      await GetIt.I<LocalDatabase>().updateCategory(
                        CategoryCompanion(
                          id: Value(category.id),
                          categoryName: Value(textController.text),
                          usePresetAmount: Value(usePresetAmount),
                          presetAmount: Value(
                            usePresetAmount ? presetAmount : null,
                          ),
                          autoFillExpenseName: Value(autoFillExpenseName),
                        ),
                      );
                      if (context.mounted) {
                        showToast(context, 'category.toast_updated'.tr());
                      }
                    } catch (e) {
                      bool conflictName = e.toString().contains('2067');
                      if (conflictName) {
                        setState(() {
                          _errorText = 'category.duplicate_error'.tr();
                        });
                        return;
                      }
                    }
                    setState(() {
                      _errorText = null;
                    });

                    if (!context.mounted) return;
                    Navigator.of(context).pop(textController.text);
                  },
                ),
              ],
            );
          },
        );
      },
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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SingleChildScrollView(
        child: Column(
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
                child:
                    usePresetAmount
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
                              prefixIcon: const Icon(
                                Icons.attach_money_rounded,
                              ),
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
          ],
        ),
      ),
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
    final borderColor =
        checked ? AppColors.primary : AppColors.outlineOf(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(!checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              checked
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surfaceAltOf(context),
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
                    color:
                        checked
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : AppColors.surfaceOf(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color:
                        checked
                            ? AppColors.primary
                            : AppColors.mutedOf(context),
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
                          color:
                              checked
                                  ? AppColors.primary
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
                  onChanged: (value) => onChanged(value ?? false),
                ),
              ],
            ),
            if (child != null) child!,
          ],
        ),
      ),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedOf(context)),
          ),
        ],
      ),
    );
  }
}
