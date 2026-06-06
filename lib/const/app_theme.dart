import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:get_it/get_it.dart';

class AppTheme {
  static ThemeData light() {
    return _build(Brightness.light);
  }

  static ThemeData dark() {
    return _build(Brightness.dark);
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final ink = AppColors.inkFor(brightness);
    final muted = AppColors.mutedFor(brightness);
    final outline = AppColors.outlineFor(brightness);
    final surface = AppColors.surfaceFor(brightness);
    final surfaceAlt = AppColors.surfaceAltFor(brightness);
    final canvas = AppColors.canvasFor(brightness);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: surface,
        surfaceContainerHighest: surfaceAlt,
        outline: outline,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: canvas,
    );

    final textTheme = GoogleFonts.ibmPlexSansKrTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.ibmPlexSansKr(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: ink,
      ),
      titleLarge: GoogleFonts.ibmPlexSansKr(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: GoogleFonts.ibmPlexSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: GoogleFonts.ibmPlexSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      bodyMedium: GoogleFonts.ibmPlexSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      labelLarge: GoogleFonts.ibmPlexSansKr(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      labelSmall: GoogleFonts.ibmPlexSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: ink),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 8,
        indicatorColor: AppColors.primary.withValues(alpha: isDark ? 0.24 : 0.12),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelLarge?.copyWith(color: ink),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(color: muted);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: outline),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: ink),
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: outline),
        ),
        // Header — primary color background with white text
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: GoogleFonts.ibmPlexSansKr(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headerHelpStyle: const TextStyle(fontSize: 0, height: 0),
        // Day cells
        dayStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        weekdayStyle: textTheme.labelSmall?.copyWith(
          color: muted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) return muted.withValues(alpha: 0.45);
          return ink;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        dayOverlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.08),
        ),
        // Today marker
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.primary;
        }),
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        todayBorder: const BorderSide(color: AppColors.primary, width: 1.5),
        // Year picker
        yearStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) return muted.withValues(alpha: 0.45);
          return ink;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        yearOverlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.08),
        ),
        // Divider & buttons
        dividerColor: outline,
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: muted,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: AppColors.primary.withValues(alpha: isDark ? 0.24 : 0.15),
        disabledColor: surfaceAlt,
        labelStyle: textTheme.labelLarge!.copyWith(color: ink),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: outline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Future<DateTime?> showDatePickerDialog({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        clipBehavior: Clip.antiAlias,
        child: _AppDatePickerContent(
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        ),
      ),
    );
  }
}

class _AppDatePickerContent extends StatefulWidget {
  const _AppDatePickerContent({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_AppDatePickerContent> createState() => _AppDatePickerContentState();
}

class _AppDatePickerContentState extends State<_AppDatePickerContent> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final pickerTheme = Theme.of(context).datePickerTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: GetIt.I<AppSettings>(),
          builder: (context, _) {
            final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
            final headerColor = AppColors.accentColorForBackground(bgIndex, context);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              color: headerColor,
              child: Text(
                localizations.formatMediumDate(_selected),
                style: GoogleFonts.ibmPlexSansKr(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            );
          },
        ),
        CalendarDatePicker(
          initialDate: _selected,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onDateChanged: (d) => setState(() => _selected = d),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: AppColors.outlineOf(context),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: pickerTheme.cancelButtonStyle,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancelButtonLabel),
              ),
              TextButton(
                style: pickerTheme.confirmButtonStyle,
                onPressed: () => Navigator.of(context).pop(_selected),
                child: Text(localizations.okButtonLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
