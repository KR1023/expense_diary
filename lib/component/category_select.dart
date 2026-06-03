import 'package:expense_diary/component/common/select_field.dart';
import 'package:expense_diary/component/common/thousands_formatter.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/database/drift_database.dart';
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('category.input_title'.tr()),
      content: SingleChildScrollView(
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
                prefixIcon: const Icon(Icons.sell_outlined),
              ),
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _usePresetAmount,
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
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
              ),
            ],
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _autoFillExpenseName,
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
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        FilledButton(onPressed: _save, child: Text('common.confirm'.tr())),
      ],
    );
  }
}
