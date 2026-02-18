import 'package:expense_diary/screen/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/screen/home_screen.dart';
import 'package:expense_diary/screen/category_screen.dart';
import 'package:expense_diary/screen/config_screen.dart';

class RootScreen extends StatefulWidget {

  @override
  State<RootScreen> createState() => _RootScreenState();

}

class _RootScreenState extends State<RootScreen>{

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    CalendarScreen(),
    CategoryScreen(),
    ConfigScreen()
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

  Widget renderBottomNavigation(){
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.paid_outlined),
          selectedIcon: Icon(Icons.paid),
          label: '지출',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: '지출 내역',
        ),
        NavigationDestination(
          icon: Icon(Icons.topic_outlined),
          selectedIcon: Icon(Icons.topic),
          label: '분류',
        ),
        NavigationDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune),
          label: '설정',
        ),
      ],
    );
  }
}
