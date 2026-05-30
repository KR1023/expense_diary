import 'dart:async';

import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:expense_diary/screen/subscription_screen.dart';
import 'package:expense_diary/core/time/week_key.dart';
import 'package:expense_diary/features/backup/data/backup_metadata_keys.dart';
import 'package:expense_diary/features/backup/data/snapshot_service.dart';
import 'package:expense_diary/screen/snapshot_restore_screen.dart';
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
  bool _isBackingUp = false;
  DateTime? _lastBackupAt;
  String? _lastBackupWeekKey;
  String? _lastRestoreDayKey;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = GetIt.I<AppSettings>().currencyCode;
    _loadLocaleSettings();
    _loadRestoreMetadata();
    final authRepository = GetIt.I<AuthRepository>();
    _authStateSubscription = authRepository.authStateChanges.listen((user) {
      _loadBackupMetadata(user: user);
    });
    _loadBackupMetadata(user: authRepository.currentUser);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
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

  Future<void> _loadRestoreMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = prefs.getString(BackupMetadataKeys.lastRestoreDayKey);
    if (!mounted) return;
    setState(() {
      _lastRestoreDayKey = dayKey;
    });
  }

  Future<void> _loadBackupMetadata({User? user}) async {
    final localMetadata = await _readLocalBackupMetadata();
    var nextLastBackupAt = localMetadata.lastBackupAt;
    var nextLastBackupWeekKey = localMetadata.lastBackupWeekKey;

    final targetUser = user ?? GetIt.I<AuthRepository>().currentUser;
    if (targetUser == null) {
      nextLastBackupAt = null;
      nextLastBackupWeekKey = null;
    } else {
      try {
        final cloudMetadata = await GetIt.I<SnapshotService>()
            .getBackupMetadata(targetUser.uid);
        nextLastBackupAt = cloudMetadata.lastBackupAt;
        nextLastBackupWeekKey = cloudMetadata.lastBackupWeekKey;
        await _writeLocalBackupMetadata(
          lastBackupAt: nextLastBackupAt,
          lastBackupWeekKey: nextLastBackupWeekKey,
        );
      } catch (e) {
        debugPrint('Failed to load cloud backup metadata: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      _lastBackupAt = nextLastBackupAt;
      _lastBackupWeekKey = nextLastBackupWeekKey;
    });
  }

  Future<({DateTime? lastBackupAt, String? lastBackupWeekKey})>
  _readLocalBackupMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackupAtRaw = prefs.getString(BackupMetadataKeys.lastBackupAt);
    final lastBackupWeekKey = prefs.getString(
      BackupMetadataKeys.lastBackupWeekKey,
    );

    final lastBackupAt = _parseDateTime(lastBackupAtRaw);
    return (lastBackupAt: lastBackupAt, lastBackupWeekKey: lastBackupWeekKey);
  }

  Future<void> _writeLocalBackupMetadata({
    required DateTime? lastBackupAt,
    required String? lastBackupWeekKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (lastBackupAt == null) {
      await prefs.remove(BackupMetadataKeys.lastBackupAt);
    } else {
      await prefs.setString(
        BackupMetadataKeys.lastBackupAt,
        lastBackupAt.toUtc().toIso8601String(),
      );
    }

    final normalizedWeekKey = lastBackupWeekKey?.trim();
    if (normalizedWeekKey == null || normalizedWeekKey.isEmpty) {
      await prefs.remove(BackupMetadataKeys.lastBackupWeekKey);
      return;
    }

    await prefs.setString(
      BackupMetadataKeys.lastBackupWeekKey,
      normalizedWeekKey,
    );
  }

  DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
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
    if (!mounted) return;
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

  Future<void> _runBackup(User? user) async {
    if (_isBackingUp) return;

    if (user == null) {
      _showSnackBar('settings.backup.msg.login_required'.tr());
      return;
    }

    final isSubscribed = GetIt.I<SubscriptionService>().isCloudEntitled;
    if (!isSubscribed) {
      final currentWeekKey = KstWeekKey.fromDateTime(DateTime.now().toUtc());
      if (_lastBackupWeekKey == currentWeekKey) {
        _showSnackBar('settings.backup.msg.weekly_limit'.tr());
        return;
      }
    }

    setState(() {
      _isBackingUp = true;
    });

    try {
      final snapshotService = GetIt.I<SnapshotService>();
      final snapshot = await snapshotService.buildLocalSnapshot();
      await snapshotService.uploadSnapshot(user.uid, snapshot);

      final savedAt = snapshot.meta.createdAt.toUtc();
      final savedWeekKey = KstWeekKey.fromDateTime(savedAt);
      await _writeLocalBackupMetadata(
        lastBackupAt: savedAt,
        lastBackupWeekKey: savedWeekKey,
      );

      if (!mounted) return;
      setState(() {
        _lastBackupAt = savedAt;
        _lastBackupWeekKey = savedWeekKey;
      });

      _showSnackBar(
        'settings.backup.msg.success'.tr(
          namedArgs: {
            'bytes': '${snapshot.meta.sizeBytes}',
            'id': snapshot.meta.snapshotId.substring(0, 8),
          },
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _showSnackBar(_backupMessageForFirebaseError(e));
    } on FormatException catch (_) {
      if (!mounted) return;
      _showSnackBar('settings.backup.msg.serialize_failed'.tr());
    } catch (e) {
      if (!mounted) return;
      debugPrint('Backup failed: $e');
      _showSnackBar('settings.backup.msg.failed_retry'.tr());
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  Future<void> _openSnapshotRestore(User? user) async {
    if (user == null) {
      _showSnackBar('settings.backup.msg.restore_login_required'.tr());
      return;
    }

    final isSubscribed = GetIt.I<SubscriptionService>().isCloudEntitled;
    if (!isSubscribed) {
      final todayKey = KstWeekKey.kstDayKey(DateTime.now());
      if (_lastRestoreDayKey == todayKey) {
        _showSnackBar('settings.backup.msg.daily_restore_limit'.tr());
        return;
      }
    }

    final restored = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SnapshotRestoreScreen(user: user)),
    );

    if (restored == true && mounted) {
      final todayKey = KstWeekKey.kstDayKey(DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(BackupMetadataKeys.lastRestoreDayKey, todayKey);
      setState(() {
        _lastRestoreDayKey = todayKey;
      });
      _showSnackBar('settings.backup.msg.restore_done'.tr());
      await _loadLocaleSettings();
    }
  }

  String _backupMessageForFirebaseError(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' =>
        'settings.backup.msg.firebase.permission_denied'.tr(),
      'unauthenticated' => 'settings.backup.msg.firebase.unauthenticated'.tr(),
      'unavailable' => 'settings.backup.msg.firebase.unavailable'.tr(),
      'resource-exhausted' =>
        'settings.backup.msg.firebase.resource_exhausted'.tr(),
      'invalid-argument' =>
        'settings.backup.msg.firebase.invalid_argument'.tr(),
      _ => 'settings.backup.msg.firebase.unknown'.tr(
        namedArgs: {'code': e.code},
      ),
    };
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                            leading: Icon(
                              Icons.language,
                              color: AppColors.primary,
                            ),
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
                                final loggedIn =
                                    await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                                if (loggedIn == true && mounted) {
                                  _showSnackBar('auth.success'.tr());
                                }
                                return;
                              }
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(
                                    'settings.account.logout_confirm_title'
                                        .tr(),
                                  ),
                                  content: Text(
                                    'settings.account.logout_confirm_content'
                                        .tr(),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text('common.cancel'.tr()),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: Text('common.confirm'.tr()),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await GetIt.I<AuthRepository>().signOut();
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: GetIt.I<SubscriptionService>(),
                      builder: (context, _) {
                        final plan =
                            GetIt.I<SubscriptionService>().currentPlan;
                        final planLabel = switch (plan) {
                          SubscriptionPlan.free =>
                            'subscription.plan_free'.tr(),
                          SubscriptionPlan.cloud =>
                            'subscription.plan_cloud'.tr(),
                          SubscriptionPlan.report =>
                            'subscription.plan_report'.tr(),
                        };
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: Icon(
                              Icons.workspace_premium_outlined,
                              color: AppColors.primary,
                            ),
                            title: Text('subscription.settings_nav'.tr()),
                            subtitle: Text(planLabel),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SubscriptionScreen(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<User?>(
                      stream: GetIt.I<AuthRepository>().authStateChanges,
                      builder: (context, authSnapshot) {
                        final user = authSnapshot.data;
                        final lastBackupText =
                            _lastBackupAt == null
                                ? 'settings.backup.last_backup_none'.tr()
                                : 'settings.backup.last_backup_at'.tr(
                                  namedArgs: {
                                    'date': DateFormat(
                                      'yyyy.MM.dd HH:mm',
                                    ).format(_lastBackupAt!.toLocal()),
                                  },
                                );

                        final isSubscribed =
                            GetIt.I<SubscriptionService>().isCloudEntitled;
                        final now = DateTime.now();
                        final currentWeekKey =
                            KstWeekKey.fromDateTime(now.toUtc());
                        final showBackupLimitHint = !isSubscribed &&
                            _lastBackupWeekKey == currentWeekKey;
                        final todayKey = KstWeekKey.kstDayKey(now);
                        final showRestoreLimitHint =
                            !isSubscribed && _lastRestoreDayKey == todayKey;

                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.backup_outlined,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'settings.backup.title'.tr(),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user == null
                                      ? 'settings.backup.subtitle_login_required'
                                          .tr()
                                      : 'settings.backup.subtitle'.tr(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mutedOf(context),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.history_toggle_off_rounded,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(lastBackupText)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            _isBackingUp
                                                ? null
                                                : () => _loadBackupMetadata(
                                                  user: user,
                                                ),
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: Text(
                                          'settings.backup.refresh'.tr(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed:
                                            _isBackingUp
                                                ? null
                                                : () => _runBackup(user),
                                        icon:
                                            _isBackingUp
                                                ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.cloud_upload_outlined,
                                                ),
                                        label: Text(
                                          _isBackingUp
                                              ? 'settings.backup.in_progress'
                                                  .tr()
                                              : 'settings.backup.backup_now'
                                                  .tr(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (showBackupLimitHint) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: AppColors.mutedOf(context),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'settings.backup.next_backup_available'
                                            .tr(
                                          namedArgs: {
                                            'date': DateFormat(
                                              'yyyy.MM.dd HH:mm',
                                            ).format(
                                              KstWeekKey.startOfNextWeekKst(
                                                now,
                                              ),
                                            ),
                                          },
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: AppColors.mutedOf(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (user != null) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          _isBackingUp
                                              ? null
                                              : () =>
                                                  _openSnapshotRestore(user),
                                      icon: const Icon(Icons.restore_page),
                                      label: Text(
                                        'settings.backup.restore_button'.tr(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'settings.backup.restore_hint'.tr(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: AppColors.mutedOf(context),
                                    ),
                                  ),
                                  if (showRestoreLimitHint) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 14,
                                          color: AppColors.mutedOf(context),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'settings.backup.next_restore_available'
                                              .tr(
                                            namedArgs: {
                                              'date': DateFormat(
                                                'yyyy.MM.dd HH:mm',
                                              ).format(
                                                KstWeekKey.tomorrowKst(now),
                                              ),
                                            },
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: AppColors.mutedOf(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ],
                            ),
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
                if (!context.mounted) return;
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
