import 'package:expense_diary/component/common/select_field.dart';
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
                tooltip: 'common.cancel'.tr(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceAltOf(context),
                  foregroundColor: AppColors.mutedOf(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppColors.outlineOf(context)),
                  ),
                ),
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

    //   DropdownButtonFormField<String> (
    //     decoration: InputDecoration(labelText: '분류'),
    //     value: widget.selectedValue,
    //     items: ['식비', '교통비'].map((value) {
    //       return DropdownMenuItem<String>(
    //         value: value,
    //         child: Text(value)
    //       );
    //     }).toList(),
    //     onChanged: (newValue) {
    //       setState(() {
    //         widget.selectedValue = newValue;
    //       });
    //     },
    // );
  }
}
