import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class LabelField extends StatefulWidget {
  final String label;
  final bool isDetail;
  final bool isDate;
  final bool isExpense;
  String? initValue;

  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;

  LabelField({
    required this.label,
    required this.isDetail,
    required this.isDate,
    required this.isExpense,
    required this.onSaved,
    required this.validator,
    required this.initValue,
  });

  @override
  State<LabelField> createState() => _LabelFieldState();
}

class _LabelFieldState extends State<LabelField> {
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    if (widget.initValue == null) {
      if (widget.isDate) {
        DateTime now = DateTime.now();

        String formattedDate =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        _textController.text = formattedDate;
      }
    } else if (widget.initValue != null) {
      if (widget.isDate) {
        String expenseDate = widget.initValue!.substring(0, 10);
        _textController.text = expenseDate;
      } else {
        _textController.text = widget.initValue!;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                inputFormatters:
                    widget.isExpense
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : [],
                decoration: InputDecoration(
                  suffixText:
                      widget.isExpense ? 'common.currency_suffix'.tr() : '',
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
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: context.locale,
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      if (widget.isDate) {
        _textController.text = formattedDate;
      }
    }
  }
}
