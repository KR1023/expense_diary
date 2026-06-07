import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SelectOption<T> {
  const SelectOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class SelectField<T> extends StatelessWidget {
  const SelectField({
    super.key,
    required this.options,
    required this.onChanged,
    this.value,
    this.onSaved,
    this.label,
    this.hint,
    this.icon,
    this.enabled = true,
  });

  final T? value;
  final List<SelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;
  final String? label;
  final String? hint;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: GetIt.I<AppSettings>(),
      builder: (context, _) {
        final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
        final accentColor = AppColors.accentColorForBackground(bgIndex, context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(label!, style: textTheme.labelSmall),
              const SizedBox(height: 6),
            ],
            DropdownButtonFormField<T>(
              value: value,
              items: options.map((option) {
                return DropdownMenuItem<T>(
                  value: option.value,
                  child: _SelectOptionContent<T>(
                    option: option,
                    isSelected: option.value == value,
                    showSelection: true,
                    accentColor: accentColor,
                  ),
                );
              }).toList(),
              selectedItemBuilder: (context) =>
                  options.map((option) {
                    return _SelectOptionContent<T>(
                      option: option,
                      isSelected: option.value == value,
                      showSelection: false,
                      accentColor: accentColor,
                    );
                  }).toList(),
              onChanged: enabled ? onChanged : null,
              onSaved: onSaved,
              isExpanded: true,
              menuMaxHeight: 320,
              borderRadius: BorderRadius.circular(18),
              dropdownColor: AppColors.surfaceOf(context),
              elevation: 6,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.mutedOf(context),
              ),
              style: textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: icon == null
                    ? null
                    : Icon(icon, color: accentColor, size: 20),
                filled: true,
                fillColor: AppColors.surfaceAltOf(context),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.outlineOf(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.outlineOf(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: accentColor, width: 1.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SelectOptionContent<T> extends StatelessWidget {
  const _SelectOptionContent({
    required this.option,
    required this.isSelected,
    required this.showSelection,
    required this.accentColor,
  });

  final SelectOption<T> option;
  final bool isSelected;
  final bool showSelection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        if (option.icon != null) ...[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(option.icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            option.label,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? accentColor : AppColors.inkOf(context),
            ),
          ),
        ),
        if (showSelection && isSelected) ...[
          const SizedBox(width: 10),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 16, color: accentColor),
          ),
        ],
      ],
    );
  }
}
