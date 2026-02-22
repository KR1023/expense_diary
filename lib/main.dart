import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/data/firestore/firestore_transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/screen/root_screen.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/const/firebase_auth_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:expense_diary/const/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:expense_diary/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MobileAds.instance.initialize();

  await initializeDateFormatting();

  final prefs = await SharedPreferences.getInstance();
  final followSystemLocale = prefs.getBool('follow_system_locale') ?? true;
  final userLocale = prefs.getString('user_locale') ?? 'en';
  final userCurrency =
      prefs.getString(AppSettings.currencyPreferenceKey) ??
      AppSettings.defaultCurrency;

  final database = LocalDatabase();
  GetIt.I.registerSingleton<LocalDatabase>(database);
  final authRepository = AuthRepository(
    googleServerClientId: FirebaseAuthConfig.googleServerClientId,
  );
  GetIt.I.registerSingleton<AuthRepository>(authRepository);
  GetIt.I.registerSingleton<FirestoreTransactionRepository>(
    FirestoreTransactionRepository(authRepository: authRepository),
  );
  GetIt.I.registerSingleton<AppSettings>(
    AppSettings(currencyCode: userCurrency),
  );

  runApp(
    EasyLocalization(
      supportedLocales: [const Locale('ko'), const Locale('en')],
      path: 'assets/locales',
      fallbackLocale: const Locale('en'),
      startLocale: followSystemLocale ? null : Locale(userLocale),
      child: const ExpenseDiaryApp(),
    ),
  );
}

class ExpenseDiaryApp extends StatelessWidget {
  const ExpenseDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GetIt.I<AppSettings>(),
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          home: const RootScreen(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }
}
