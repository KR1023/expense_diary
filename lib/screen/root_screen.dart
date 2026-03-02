import 'package:expense_diary/screen/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/screen/home_screen.dart';
import 'package:expense_diary/screen/category_screen.dart';
import 'package:expense_diary/screen/config_screen.dart';
import 'package:expense_diary/screen/statistics_tab_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    CalendarScreen(),
    CategoryScreen(),
    StatisticsTabScreen(),
    ConfigScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    return Scaffold(
      key: ValueKey('root_${locale.languageCode}'),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: renderBottomNavigation(),
    );
  }

  Widget renderBottomNavigation() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.paid_outlined),
          selectedIcon: const Icon(Icons.paid),
          label: 'tab.expense'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today),
          label: 'tab.history'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.topic_outlined),
          selectedIcon: const Icon(Icons.topic),
          label: 'tab.category'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart),
          label: 'tab.stats'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.tune_outlined),
          selectedIcon: const Icon(Icons.tune),
          label: 'tab.settings'.tr(),
        ),
      ],
    );
  }
}
