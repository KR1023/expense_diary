import 'package:expense_diary/component/common/select_field.dart';
import 'package:expense_diary/component/common/thousands_formatter.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';

class CategorySelect extends StatefulWidget {
  final CategoryData? selectedValue;
  final FormFieldSetter<CategoryData> onSavedCategory;
  final ValueChanged<CategoryData?>? onChanged;
  final bool showIcon;

  const CategorySelect({
    super.key,
    this.selectedValue,
    required this.onSavedCategory,
    this.onChanged,
    this.showIcon = true,
  });

  @override
  State<CategorySelect> createState() => _CategorySelectState();
}

class _CategorySelectState extends State<CategorySelect> {
  CategoryData? _selectedValue;
  String? _nameErrorText;
  String? _amountErrorText;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(CategorySelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        _selectedValue = widget.selectedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryData>>(
      stream: GetIt.I<LocalDatabase>().watchCategory(null),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SelectField<String>(
            label: 'category.select_label'.tr(),
            hint: 'category.select_hint'.tr(),
            icon: Icons.category_outlined,
            options: const [],
            enabled: false,
            onChanged: (_) {},
          );
        }

        final categories = snapshot.data!;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SelectField<CategoryData>(
                label: 'category.select_label'.tr(),
                hint: 'category.select_hint'.tr(),
                icon: widget.showIcon ? Icons.category_outlined : null,
                value: _selectedValue,
                options:
                    categories.map((category) {
                      return SelectOption<CategoryData>(
                        value: category,
                        label: category.categoryName,
                        icon: Icons.sell_outlined,
                      );
                    }).toList(),
                onChanged: (newCategory) {
                  setState(() {
                    _selectedValue = newCategory;
                  });
                  widget.onChanged?.call(newCategory);
                },
                onSaved: widget.onSavedCategory,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: IconButton.filledTonal(
                tooltip: 'category.quick_add'.tr(),
                style: _actionButtonStyle(context),
                icon: const Icon(Icons.add_rounded),
                onPressed: _quickAddCategory,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: IconButton.filledTonal(
                tooltip: 'common.cancel'.tr(),
                style: _actionButtonStyle(context),
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  setState(() {
                    _selectedValue = null;
                  });
                  widget.onChanged?.call(null);
                },
              ),
            ),
          ],
        );
      },
    );
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

  Future<void> _quickAddCategory() async {
    final created = await showDialog<CategoryData>(
      context: context,
      builder:
          (_) => _QuickCategoryDialog(
            nameErrorText: _nameErrorText,
            amountErrorText: _amountErrorText,
          ),
    );

    if (created == null || !mounted) return;
    setState(() {
      _selectedValue = created;
    });
    widget.onChanged?.call(created);
  }
}

class _QuickCategoryDialog extends StatefulWidget {
  const _QuickCategoryDialog({this.nameErrorText, this.amountErrorText});

  final String? nameErrorText;
  final String? amountErrorText;

  @override
  State<_QuickCategoryDialog> createState() => _QuickCategoryDialogState();
}

class _QuickCategoryDialogState extends State<_QuickCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _usePresetAmount = false;
  bool _autoFillExpenseName = false;
  String? _nameErrorText;
  String? _amountErrorText;

  @override
  void initState() {
    super.initState();
    _nameErrorText = widget.nameErrorText;
    _amountErrorText = widget.amountErrorText;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameErrorText = 'category.input_hint'.tr();
      });
      return;
    }

    final presetAmount = int.tryParse(
      _amountController.text.replaceAll(',', ''),
    );
    if (_usePresetAmount && presetAmount == null) {
      setState(() {
        _amountErrorText = 'category.preset_amount_required'.tr();
      });
      return;
    }

    try {
      final db = GetIt.I<LocalDatabase>();
      final id = await db.addCategory(
        CategoryCompanion(
          categoryName: Value(name),
          usePresetAmount: Value(_usePresetAmount),
          presetAmount: Value(_usePresetAmount ? presetAmount : null),
          autoFillExpenseName: Value(_autoFillExpenseName),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(
        CategoryData(
          id: id,
          categoryName: name,
          usePresetAmount: _usePresetAmount,
          presetAmount: _usePresetAmount ? presetAmount : null,
          autoFillExpenseName: _autoFillExpenseName,
        ),
      );
    } catch (e) {
      final conflictName = e.toString().contains('2067');
      if (conflictName) {
        setState(() {
          _nameErrorText = 'category.duplicate_error'.tr();
        });
      }
    }
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
              Container(
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
                        child: const Icon(
                          Icons.sell_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'category.input_title'.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'category.input_hint'.tr(),
                          errorText: _nameErrorText,
                          prefixIcon: Icon(
                            Icons.sell_outlined,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _usePresetAmount,
                        activeColor: accentColor,
                        title: Text('category.preset_amount_option'.tr()),
                        subtitle: Text('category.preset_amount_help'.tr()),
                        onChanged: (value) {
                          setState(() {
                            _usePresetAmount = value ?? false;
                            if (!_usePresetAmount) {
                              _amountController.clear();
                              _amountErrorText = null;
                            }
                          });
                        },
                      ),
                      if (_usePresetAmount) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsFormatter()],
                          decoration: InputDecoration(
                            hintText: 'category.preset_amount_hint'.tr(),
                            errorText: _amountErrorText,
                            prefixIcon: Icon(
                              Icons.payments_outlined,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _autoFillExpenseName,
                        activeColor: accentColor,
                        title: Text('category.auto_name_option'.tr()),
                        subtitle: Text('category.auto_name_help'.tr()),
                        onChanged: (value) {
                          setState(() {
                            _autoFillExpenseName = value ?? false;
                          });
                        },
                      ),
                    ],
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
                        child: Text('common.confirm'.tr()),
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
