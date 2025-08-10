import 'package:flutter/material.dart';
import 'package:expense_diary/screen/root_screen.dart';
import 'package:expense_diary/screen/home_screen.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();

  await initializeDateFormatting();

  final database = LocalDatabase();
  GetIt.I.registerSingleton<LocalDatabase>(database);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          labelSmall: TextStyle(
            color: Color(0xFFDCDCDC),
            fontSize: 14
          ),
          bodyMedium: TextStyle(
            fontSize: 18
          )
        )
      ),
      home: RootScreen(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
        const Locale('en', 'US'),
      ],
    )
  );
}