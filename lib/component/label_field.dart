import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
    required this.initValue
  });

  @override
  State<LabelField> createState() => _LabelFieldState();

}

class _LabelFieldState extends State<LabelField> {
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    if(widget.initValue == null) {
      if(widget.isDate) {
        DateTime now = DateTime.now();

        String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        _textController.text = formattedDate;
      }
    }else if(widget.initValue != null ) {
      if(widget.isDate){
        String expenseDate = widget.initValue!.substring(0,10);
        _textController.text = expenseDate;
      }else {
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
        SizedBox(
          child: Text(
            widget.label,
            style: textTheme.labelSmall
          )
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                enabled: widget.isDate ? false : true,
                onSaved: widget.onSaved,
                validator: widget.validator,
                keyboardType: widget.isExpense ? TextInputType.number : TextInputType.multiline,
                inputFormatters: widget.isExpense ? [
                  FilteringTextInputFormatter.digitsOnly
                ] : [],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFFBFBFB),
                  suffixText: widget.isExpense ? '원' : '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Color(0xFFDFDBDB),
                        width: 2,
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF9F9C9C),
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(7)
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFFF00),
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(7)
                  )
                ),
                maxLines: widget.isDetail ? null : 1,
              )
            ),
            widget.isDate ? IconButton(
              icon: Icon(Icons.calendar_month),
              onPressed: (){
                _expenseDate(context);
              },
            ) : Container(),
            widget.isDate ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.25
            ) : Container()
          ],
        )
      ]
    );
  }

  Future<void> _expenseDate(BuildContext context) async{
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: const Locale('ko')
    );

    if(pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      if(widget.isDate) {
        _textController.text = pickedDate.toString().split(' ')[0];
      }
    }

    print('pickedDate: ${pickedDate}');
  }

}