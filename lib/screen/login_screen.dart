import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/screen/signup_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(
    Future<void> Function() action, {
    bool validateForm = true,
  }) async {
    if (_isLoading) return;
    if (validateForm && !(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await action();
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('auth.success'.tr())));
      }
    } on AuthCancelledException {
      // User canceled provider sign-in; no error UI.
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      debugPrint(
        'GoogleSignInException(code: ${e.code}, description: ${e.description})',
      );
      _showError('${'auth.error.google_sign_in_failed'.tr()} (${e.code.name})');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final code = e.code;
      debugPrint(
        'FirebaseAuthException(code: ${e.code}, message: ${e.message})',
      );
      final messageKey = switch (code) {
        'invalid-email' => 'auth.error.invalid_email',
        'user-not-found' => 'auth.error.user_not_found',
        'wrong-password' => 'auth.error.wrong_password',
        'email-already-in-use' => 'auth.error.email_already_in_use',
        'weak-password' => 'auth.error.weak_password',
        'invalid-credential' => 'auth.error.invalid_credential',
        'operation-not-allowed' => 'auth.error.email_password_not_enabled',
        'account-exists-with-different-credential' =>
          'auth.error.account_exists_different_credential',
        'missing-google-id-token' => 'auth.error.google_token_missing',
        'web-context-cancelled' => 'auth.error.provider_cancelled',
        'canceled' => 'auth.error.provider_cancelled',
        _ => 'auth.error.generic',
      };
      final message =
          messageKey == 'auth.error.generic'
              ? '${messageKey.tr()} (${e.code})'
              : messageKey.tr();
      _showError(message);
    } catch (_) {
      if (!mounted) return;
      _showError('auth.error.generic'.tr());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = GetIt.I<AuthRepository>();
    final showAppleSignIn =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed:
                                _isLoading || !Navigator.of(context).canPop()
                                    ? null
                                    : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            tooltip:
                                MaterialLocalizations.of(
                                  context,
                                ).backButtonTooltip,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'auth.title'.tr(),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'auth.subtitle'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedOf(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'auth.email'.tr(),
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return 'auth.error.enter_email'.tr();
                          }
                          if (!text.contains('@')) {
                            return 'auth.error.invalid_email'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'auth.password'.tr(),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          final text = value ?? '';
                          if (text.isEmpty) {
                            return 'auth.error.enter_password'.tr();
                          }
                          if (text.length < 6) {
                            return 'auth.error.password_min'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => _submit(() async {
                                    await authRepository.signIn(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );
                                  }),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text('auth.sign_in'.tr()),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => _submit(() async {
                                    await authRepository.signInWithGoogle();
                                  }, validateForm: false),
                          icon: const Icon(Icons.account_circle_outlined),
                          label: Text('auth.sign_in_google'.tr()),
                        ),
                      ),
                      if (showAppleSignIn) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => _submit(() async {
                                      await authRepository.signInWithApple();
                                    }, validateForm: false),
                            icon: const Icon(Icons.apple),
                            label: Text('auth.sign_in_apple'.tr()),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.no_account'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () async {
                                      final navigator = Navigator.of(context);
                                      final created = await navigator
                                          .push<bool>(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => const SignupScreen(),
                                            ),
                                          );
                                      if (created == true && mounted) {
                                        navigator.pop(true);
                                      }
                                    },
                            child: Text('auth.go_to_sign_up'.tr()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
