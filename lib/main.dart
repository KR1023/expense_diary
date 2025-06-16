import 'package:flutter/material.dart';
import 'package:expense_diary/screen/home_screen.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final database = LocalDatabase();
  GetIt.I.registerSingleton<LocalDatabase>(database);

  runApp(
    MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          labelSmall: TextStyle(
            color: Color(0xFFDCDCDC),
            fontSize: 14
          )
        )
      ),
      home: HomeScreen(),
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