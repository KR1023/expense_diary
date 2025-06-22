import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarScreenState();

}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text("Calendar")
      )
    );
  }
}