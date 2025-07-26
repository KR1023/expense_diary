import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/model/category.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategorySelect extends StatefulWidget {
  int? categoryId;
  String? categoryName;
  CategoryData? selectedValue;
  final FormFieldSetter<CategoryData> onSavedCategory;


  CategorySelect({
    this.categoryId,
    this.categoryName,
    required this.onSavedCategory
  });

  @override
  State<CategorySelect> createState() => _CategorySelectState();
}

class _CategorySelectState extends State<CategorySelect> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryData>>(
      stream: GetIt.I<LocalDatabase>().watchCategory(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: DropdownButtonFormField<String> (
              items: [].map((value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value)
                );
              }).toList(),
              decoration: InputDecoration(labelText: '분류'),
              onChanged: (String? value) {  },
            )
          );
        }

        final categories = snapshot.data!;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 7,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: DropdownButtonFormField<CategoryData>(
                  decoration: InputDecoration(
                    labelText: '분류',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                            color: Color(0xFF9F9C9C),
                            width: 1.5
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                            color: Color(0xFF9F9C9C),
                            width: 1.5
                        )
                    )
                  ),
                  value: widget.selectedValue,
                  items: categories.map((category) {
                    return DropdownMenuItem<CategoryData>(
                      value: category,
                      child: Container(
                          child: Text(category.categoryName)
                      )
                    );
                  }).toList(),
                  onChanged: (newCategory) {
                    setState(() {
                      widget.selectedValue = newCategory;
                    });
                  },
                  onSaved: widget.onSavedCategory,
                )
              )
            ),
            Flexible(
              flex: 1,
              child: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: (){
                  setState(() {
                    widget.selectedValue = null;
                  });
                },
              )
            )
          ]
        );
      }
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

