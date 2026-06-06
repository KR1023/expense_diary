import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/component/expense_card.dart';
import 'package:expense_diary/screen/add_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/const/currency_utils.dart';
import 'package:expense_diary/service/app_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  int _slideDirection = 1;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool get _isToday {
    final today = _dateOnly(DateTime.now());
    return _selectedDate == today;
  }

  String get _formattedSelectedDate {
    return DateFormat('yyyy.MM.dd').format(_selectedDate);
  }

  String get _titleText {
    if (_isToday) return 'home.title'.tr();
    return 'home.date_title'.tr(namedArgs: {'date': _formattedSelectedDate});
  }

  String get _totalLabelText {
    if (_isToday) return 'home.today_total'.tr();
    return 'home.date_total'.tr(namedArgs: {'date': _formattedSelectedDate});
  }

  void _setSelectedDate(DateTime date) {
    final nextDate = _dateOnly(date);
    if (nextDate == _selectedDate) return;

    setState(() {
      _slideDirection = nextDate.isAfter(_selectedDate) ? 1 : -1;
      _selectedDate = nextDate;
    });
  }

  void _moveDate(int days) {
    _setSelectedDate(_selectedDate.add(Duration(days: days)));
  }

  void _goToday() {
    _setSelectedDate(DateTime.now());
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: context.locale,
    );

    if (pickedDate == null || !mounted) return;
    _setSelectedDate(pickedDate);
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 250) return;

    if (velocity < 0) {
      _moveDate(1);
    } else {
      _moveDate(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerAdWidget(),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: _dateSlideTransition,
                  child: _buildDateContent(
                    context,
                    key: ValueKey(_selectedDate),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton floatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'home_fab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddScreen(initialDate: _selectedDate),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: Text('common.add'.tr()),
    );
  }

  Widget _dateSlideTransition(Widget child, Animation<double> animation) {
    final direction = _slideDirection.toDouble();
    final slideAnimation = Tween<Offset>(
      begin: Offset(direction * 0.12, 0),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }

  Widget _buildDateContent(BuildContext context, {required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleText,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    _formattedSelectedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedOf(context),
                    ),
                  ),
                ],
              ),
            ),
            _DateActionButton(
              icon: Icons.calendar_month_rounded,
              label: 'home.calendar_action'.tr(),
              onPressed: _pickDate,
              isPrimary: true,
            ),
            const SizedBox(width: 6),
            _DateActionButton(
              icon: Icons.today_rounded,
              label: 'home.today_action'.tr(),
              onPressed: _isToday ? null : _goToday,
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<int>(
          stream: GetIt.I<LocalDatabase>().selectDayExpense(_selectedDate),
          builder: (context, totalSnapshot) {
            final currencyCode = GetIt.I<AppSettings>().currencyCode;
            final total = totalSnapshot.data ?? 0;
            return AnimatedBuilder(
              animation: GetIt.I<AppSettings>(),
              builder: (context, _) {
                final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
                final heroGradient = AppColors.heroGradientForBackground(bgIndex, context);
                final shadowColor = heroGradient.colors.first.withValues(alpha: 0.28);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: heroGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 18,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _totalLabelText,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              CurrencyUtils.formatAmount(total, currencyCode),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            StreamBuilder<List<Map<String, dynamic>>>(
                              stream: GetIt.I<LocalDatabase>().watchExpense(
                                _selectedDate,
                              ),
                              builder: (context, countSnapshot) {
                                final count = countSnapshot.data?.length ?? 0;
                                return Text(
                                  'home.count_label'.tr(
                                    namedArgs: {'count': '$count'},
                                  ),
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: Colors.white),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 18),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: GetIt.I<LocalDatabase>().watchExpense(_selectedDate),
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return Center(
                  child: Text(
                    'home.empty'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedOf(context),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final expense = data[index]['expenses'];
                  final category = data[index]['category'];
                  final paymentMethod = data[index]['paymentMethod'];

                  return TweenAnimationBuilder<double>(
                    key: ValueKey(
                      '${_selectedDate.toIso8601String()}-${expense.id}',
                    ),
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 240 + (index * 40)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: ExpenseCard(
                      expenseId: expense.id,
                      category: category,
                      paymentMethod: paymentMethod,
                      expenseName: expense.expenseName,
                      expense: expense.expense,
                      expenseDate: expense.expenseDate,
                      expenseDetail: expense.expenseDetail ?? '',
                      isRecurring: expense.recurringExpenseId != null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateActionButton extends StatelessWidget {
  const _DateActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final isDark = AppColors.isDark(context);
    final foreground =
        enabled
            ? (isPrimary ? Colors.white : AppColors.primary)
            : AppColors.mutedOf(context);
    final background =
        enabled
            ? (isPrimary
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10))
            : AppColors.surfaceAltOf(context).withValues(alpha: 0.72);
    final borderColor =
        enabled
            ? AppColors.primary.withValues(alpha: isPrimary ? 0 : 0.18)
            : AppColors.outlineOf(context).withValues(alpha: 0.60);

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
              boxShadow:
                  enabled && isPrimary
                      ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ]
                      : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: foreground),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
