import 'package:expense_diary/screen/calendar_screen.dart';
import 'package:expense_diary/screen/recurring_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/screen/home_screen.dart';
import 'package:expense_diary/screen/category_screen.dart';
import 'package:expense_diary/screen/config_screen.dart';
import 'package:expense_diary/screen/statistics_tab_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:expense_diary/const/app_colors.dart';

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
    RecurringExpenseScreen(),
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
    return AnimatedBuilder(
      animation: GetIt.I<AppSettings>(),
      builder: (context, _) {
        final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
        final cardColor = AppColors.cardColorOf(bgIndex, context);
        final outlineColor = AppColors.outlineColorOf(bgIndex, context);
        final accentColor = AppColors.accentColorForBackground(bgIndex, context);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, thickness: 1, color: outlineColor),
            Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor: cardColor,
                  elevation: 0,
                  indicatorColor: Colors.transparent,
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return IconThemeData(color: accentColor);
                    }
                    return IconThemeData(color: AppColors.mutedOf(context));
                  }),
                  labelTextStyle: WidgetStateProperty.all(
                    Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.inkOf(context),
                    ),
                  ),
                ),
              ),
              child: NavigationBar(
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
                    icon: const Icon(Icons.repeat_outlined),
                    selectedIcon: const Icon(Icons.repeat),
                    label: 'tab.fixed'.tr(),
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
              ),
            ),
          ],
        );
      },
    );
  }
}
