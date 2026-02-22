import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/screen/cloud_transaction_screen.dart';
import 'package:expense_diary/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_diary/service/app_settings.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool _followSystemLocale = true;
  String _selectedLanguage = 'en';
  String _selectedCurrency = AppSettings.defaultCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = GetIt.I<AppSettings>().currencyCode;
    _loadLocaleSettings();
  }

  Future<void> _loadLocaleSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final follow = prefs.getBool('follow_system_locale') ?? true;
    final userLocale = prefs.getString('user_locale') ?? 'en';

    if (!mounted) return;
    setState(() {
      _followSystemLocale = follow;
      _selectedLanguage = userLocale;
    });
  }

  Locale _resolveSystemLocale() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    const supported = ['ko', 'en'];
    if (supported.contains(deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }
    return const Locale('en');
  }

  Future<void> _setFollowSystemLocale(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('follow_system_locale', value);
    if (!mounted) return;

    if (value) {
      final targetLocale = _resolveSystemLocale();
      await context.setLocale(targetLocale);
      if (!mounted) return;
      setState(() {
        _followSystemLocale = true;
        _selectedLanguage = targetLocale.languageCode;
      });
      return;
    }

    await prefs.setString('user_locale', _selectedLanguage);
    await context.setLocale(Locale(_selectedLanguage));
    if (!mounted) return;
    setState(() {
      _followSystemLocale = false;
    });
  }

  Future<void> _setManualLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('follow_system_locale', false);
    await prefs.setString('user_locale', languageCode);
    if (!mounted) return;
    await context.setLocale(Locale(languageCode));

    if (!mounted) return;
    setState(() {
      _followSystemLocale = false;
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _setCurrency(String currencyCode) async {
    await GetIt.I<AppSettings>().setCurrencyCode(currencyCode);
    if (!mounted) return;
    setState(() {
      _selectedCurrency = currencyCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'tab.settings'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'settings.subtitle'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.language, color: AppColors.primary),
                            title: Text('settings.language.title'.tr()),
                            subtitle: Text('settings.language.subtitle'.tr()),
                          ),
                          SwitchListTile(
                            title: Text('settings.language.follow_system'.tr()),
                            value: _followSystemLocale,
                            onChanged: _setFollowSystemLocale,
                          ),
                          if (!_followSystemLocale)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: DropdownButtonFormField<String>(
                                value: _selectedLanguage,
                                decoration: InputDecoration(
                                  labelText: 'settings.language.select'.tr(),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'ko',
                                    child: Text(
                                      'settings.language.option_ko'.tr(),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text(
                                      'settings.language.option_en'.tr(),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  _setManualLocale(value);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.attach_money,
                              color: AppColors.primary,
                            ),
                            title: Text('settings.currency.title'.tr()),
                            subtitle: Text('settings.currency.subtitle'.tr()),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: const InputDecoration(isDense: true),
                              items: [
                                DropdownMenuItem(
                                  value: 'KRW',
                                  child: Text(
                                    'settings.currency.option_krw'.tr(),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'USD',
                                  child: Text(
                                    'settings.currency.option_usd'.tr(),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                _setCurrency(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_sweep_outlined,
                          color: AppColors.danger,
                        ),
                        title: Text('settings.reset.title'.tr()),
                        subtitle: Text('settings.reset.subtitle'.tr()),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          initConfirmDialog(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<User?>(
                      stream: GetIt.I<AuthRepository>().authStateChanges,
                      builder: (context, snapshot) {
                        final user = snapshot.data;

                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: Icon(
                              user == null
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              user == null
                                  ? 'settings.account.login'.tr()
                                  : 'settings.account.logout'.tr(),
                            ),
                            subtitle: Text(
                              user == null
                                  ? 'settings.account.login_subtitle'.tr()
                                  : (user.email?.isNotEmpty ?? false)
                                  ? user.email!
                                  : 'settings.account.subtitle'.tr(),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              if (user == null) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                                return;
                              }
                              await GetIt.I<AuthRepository>().signOut();
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<User?>(
                      stream: GetIt.I<AuthRepository>().authStateChanges,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            enabled: user != null,
                            leading: Icon(
                              Icons.cloud_sync_outlined,
                              color: AppColors.primary,
                            ),
                            title: Text('settings.cloud_tx.title'.tr()),
                            subtitle: Text(
                              user == null
                                  ? 'settings.cloud_tx.login_required'.tr()
                                  : 'settings.cloud_tx.subtitle'.tr(),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap:
                                user == null
                                    ? null
                                    : () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  const CloudTransactionScreen(),
                                        ),
                                      );
                                    },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Future<void> initConfirmDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              const SizedBox(width: 8),
              Text('settings.reset.dialog_title'.tr()),
            ],
          ),
          content: Text('settings.reset.dialog_content'.tr()),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await GetIt.I<LocalDatabase>().deleteAllData();
                Navigator.of(context).pop();
              },
              child: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );
  }
}
