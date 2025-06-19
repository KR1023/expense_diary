import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showBasicToast({
  required String message
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Color(0xAA333333),
    textColor: Colors.white,
    fontSize: 16.0,
  );
}