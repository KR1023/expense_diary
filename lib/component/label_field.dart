import 'package:expense_diary/component/common/thousands_formatter.dart';
import 'package:expense_diary/const/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/service/app_settings.dart';

class LabelField extends StatefulWidget {
  final String label;
  final bool isDetail;
  final bool isDate;
  final bool isExpense;
  final TextEditingController? controller;
  final String? initValue;

  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;

  const LabelField({
    super.key,
    required this.label,
    required this.isDetail,
    required this.isDate,
    required this.isExpense,
    required this.onSaved,
    required this.validator,
    required this.initValue,
    this.controller,
  });

  @override
  State<LabelField> createState() => _LabelFieldState();
}

class _LabelFieldState extends State<LabelField> {
  late final TextEditingController _textController;
  late final bool _ownsController;

  @override
  void initState() {
    _ownsController = widget.controller == null;
    _textController = widget.controller ?? TextEditingController();

    if (widget.initValue == null) {
      if (widget.isDate) {
        DateTime now = DateTime.now();

        String formattedDate =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        if (_textController.text.isEmpty) {
          _textController.text = formattedDate;
        }
      }
    } else if (widget.initValue != null) {
      if (_textController.text.isEmpty) {
        if (widget.isDate) {
          _textController.text = widget.initValue!.substring(0, 10);
        } else if (widget.isExpense) {
          final num = int.tryParse(widget.initValue!);
          _textController.text =
              num != null ? ThousandsFormatter.format(num) : widget.initValue!;
        } else {
          _textController.text = widget.initValue!;
        }
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _textController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currencyCode = GetIt.I<AppSettings>().currencyCode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(child: Text(widget.label, style: textTheme.labelSmall)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                readOnly: widget.isDate,
                onSaved: widget.onSaved,
                validator: widget.validator,
                keyboardType:
                    widget.isExpense
                        ? TextInputType.number
                        : TextInputType.multiline,
                inputFormatters: widget.isExpense ? [ThousandsFormatter()] : [],
                decoration: InputDecoration(
                  suffixText:
                      widget.isExpense
                          ? CurrencyUtils.inputSuffix(currencyCode)
                          : '',
                  suffixStyle: textTheme.labelLarge,
                ),
                maxLines: widget.isDetail ? null : 1,
              ),
            ),
            if (widget.isDate)
              IconButton(
                icon: Icon(Icons.calendar_month_outlined),
                onPressed: () {
                  _expenseDate(context);
                },
              ),
            if (widget.isDate)
              SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          ],
        ),
      ],
    );
  }

  Future<void> _expenseDate(BuildContext context) async {
    final DateTime? pickedDate = await AppTheme.showDatePickerDialog(
      context: context,
      initialDate: DateTime.tryParse(_textController.text) ?? DateTime.now(),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      if (widget.isDate) {
        _textController.text = formattedDate;
      }
    }
  }
}
