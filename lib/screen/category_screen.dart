import 'package:expense_diary/model/category_expense.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/database/drift_database.dart';
import 'package:get_it/get_it.dart';

class CategoryScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => CategoryScreenState();

}

class CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 8
              ),
              Text(
                '분류 관리',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600
                )
              ),
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    print('Clicked Button!');
                    _showInputDialog(context);
                  }
              )
            ]
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '검색',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w600
                  ),
                  filled: true,
                  fillColor: Color(0xFFFBFBFB),
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
              )
            )
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: GetIt.I<LocalDatabase>().watchCategory(),
              builder: (context, snapshot) {
                print(snapshot.data);
                if(!snapshot.hasData) {
                  return Center(
                      child: Text(
                          '등록된 분류 항목이 없습니다.'
                      )
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final category = snapshot.data![index];

                    return Container(
                      width: MediaQuery.of(context).size.width - 10,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFC8C8C8)
                          )
                        )
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text(
                          category.categoryName,
                          style: TextStyle(
                            fontSize: 20
                          )
                        ),
                      )
                    );
                  }
                );
              }
            )
          )
        ]
      )
    );
  }

  Future<void> _showInputDialog(BuildContext context) async {
    TextEditingController _textController = TextEditingController();

    String? result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('분류명 입력'),
              content: TextField(
                controller: _textController,
                decoration: InputDecoration(hintText: '내용을 입력하세요.')
              ),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () async {
                  await GetIt.I<LocalDatabase>().addCategory(
                    CategoryCompanion(
                      categoryName: Value(_textController.text!),
                    )
                  );
                  Navigator.of(context).pop(_textController.text);
                }
              ),
              TextButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                }
              )
            ]
          );
        }
    );
  }
}
