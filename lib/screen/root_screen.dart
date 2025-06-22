import 'package:expense_diary/screen/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/screen/home_screen.dart';
import 'package:expense_diary/screen/calendar_screen.dart';

class RootScreen extends StatefulWidget {

  @override
  State<RootScreen> createState() => _RootScreenState();

}

class _RootScreenState extends State<RootScreen>{

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    CalendarScreen(),
    Center(child:Text("설정"))
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: renderBottomNavigation(),
    );
  }

  BottomNavigationBar renderBottomNavigation(){
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
            icon: Icon(
                Icons.paid
            ),
            label: '지출'
        ),
        BottomNavigationBarItem(
            icon: Icon(
                Icons.list_alt
            ),
            label: '지출 내역'
        ),
        BottomNavigationBarItem(
            icon: Icon(
                Icons.settings
            ),
            label: '설정'
        ),
      ]
    );
  }
}

