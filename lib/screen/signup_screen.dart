import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms) {
      _showError('auth.signup.terms_required'.tr());
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await GetIt.I<AuthRepository>().signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('auth.signup.success'.tr())));
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final messageKey =
          switch (e.code) {
            'invalid-email' => 'auth.error.invalid_email',
            'email-already-in-use' => 'auth.error.email_already_in_use',
            'weak-password' => 'auth.error.weak_password',
            'operation-not-allowed' => 'auth.error.email_password_not_enabled',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showTermsDialog({
    required String title,
    required String content,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
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
                                _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'auth.signup.title'.tr(),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          'auth.signup.subtitle'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedOf(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.newUsername],
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'auth.email'.tr(),
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return 'auth.error.enter_email'.tr();
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
                        autofillHints: const [AutofillHints.newPassword],
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'auth.signup.confirm_password'.tr(),
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                        ),
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'auth.signup.confirm_password_required'.tr();
                          }
                          if (value != _passwordController.text) {
                            return 'auth.signup.password_mismatch'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAltOf(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineOf(context)),
                        ),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: _agreedToTerms,
                              onChanged:
                                  _isLoading
                                      ? null
                                      : (value) {
                                        setState(() {
                                          _agreedToTerms = value ?? false;
                                        });
                                      },
                              title: Text(
                                'auth.signup.agree_terms'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () => _showTermsDialog(
                                            title: 'auth.signup.terms_title'.tr(),
                                            content:
                                                'auth.signup.terms_content'.tr(),
                                          ),
                                  child: Text('auth.signup.view_terms'.tr()),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () => _showTermsDialog(
                                            title:
                                                'auth.signup.privacy_title'.tr(),
                                            content:
                                                'auth.signup.privacy_content'
                                                    .tr(),
                                          ),
                                  child: Text('auth.signup.view_privacy'.tr()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _signUp,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text('auth.sign_up'.tr()),
                        ),
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

