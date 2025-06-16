import 'package:flutter/material.dart';

class ExpenseScreenHeader extends StatelessWidget {
  final bool isAdd;
  final onSavePressed;

  const ExpenseScreenHeader({
    required this.isAdd,
    required this.onSavePressed,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Text(
            isAdd ? '지출 내역 추가' : '지출 내역 상세',
            style: TextStyle(
                fontSize: 16.0
            )
        ),
        Row(
          children: [
            SizedBox(
              width: 40,
              height: 29,
              child: OutlinedButton(
                  onPressed: () {
                    onSavePressed();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFFFFFFFF),
                      backgroundColor: Color(0x9958D68D),
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      minimumSize: Size(0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                          color: Color(0xFFFFF)
                      )
                  ),
                  child: Text(
                      '+',
                      style: TextStyle(
                          fontSize: 20.0
                      )
                  )
              ),
            ),
            isAdd ? Container() :
            IconButton(
                onPressed: (){
                },
                icon: Icon(Icons.delete)
            )
          ]
        )

      ],
    );
  }

}