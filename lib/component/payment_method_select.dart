import 'package:expense_diary/component/common/select_field.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentMethodSelect extends StatefulWidget {
  final PaymentMethod? selectedValue;
  final FormFieldSetter<PaymentMethod> onSaved;

  const PaymentMethodSelect({
    super.key,
    this.selectedValue,
    required this.onSaved,
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
  Widget build(BuildContext context) {
    return StreamBuilder<List<PaymentMethod>>(
      stream: GetIt.I<LocalDatabase>().watchPaymentMethods(),
      builder: (context, snapshot) {
        final methods = snapshot.data ?? [];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SelectField<PaymentMethod>(
                label: 'payment_method.select_label'.tr(),
                hint: 'payment_method.select_hint'.tr(),
                icon: Icons.credit_card_outlined,
                value: _selectedValue,
                options: methods.map((m) {
                  return SelectOption<PaymentMethod>(
                    value: m,
                    label: m.name,
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
                onPressed: () => setState(() => _selectedValue = null),
              ),
            ),
          ],
        );
      },
    );
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
}
