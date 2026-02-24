import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/core/subscription/plan_type.dart';
import 'package:expense_diary/core/subscription/revenuecat_provider.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _loadingOfferings = true;
  bool _purchasing = false;
  bool _restoring = false;
  String? _errorText;
  Offerings? _offerings;

  SubscriptionService get _subscription => GetIt.I<SubscriptionService>();
  AuthRepository get _auth => GetIt.I<AuthRepository>();

  bool get _isLoggedIn => _auth.currentUser != null;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _errorText = null;
    });

    try {
      final offerings = await _subscription.loadOfferings();
      if (!mounted) return;
      setState(() {
        _offerings = offerings;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = '오퍼링을 불러오지 못했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingOfferings = false;
        });
      }
    }
  }

  Future<void> _purchasePackage(Package package) async {
    if (_purchasing) return;
    if (!_isLoggedIn) {
      _showSnackBar('구독 구매를 위해 먼저 로그인하세요.');
      return;
    }

    setState(() {
      _purchasing = true;
    });

    try {
      await _subscription.purchasePackage(package);
      await _subscription.refreshPlan();
      if (!mounted) return;
      _showSnackBar('구매가 완료되었습니다.');
      Navigator.of(context).pop(true);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return;
      }
      _showSnackBar(_messageForPurchasesError(code));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('구매 중 오류가 발생했습니다. 잠시 후 다시 시도하세요.');
    } finally {
      if (mounted) {
        setState(() {
          _purchasing = false;
        });
      }
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    if (!_isLoggedIn) {
      _showSnackBar('복원을 위해 먼저 로그인하세요.');
      return;
    }

    setState(() {
      _restoring = true;
    });

    try {
      await _subscription.restoreAndRefreshPlan();
      if (!mounted) return;
      _showSnackBar('복원 요청이 완료되었습니다.');
      Navigator.of(context).pop(true);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final code = PurchasesErrorHelper.getErrorCode(e);
      _showSnackBar(_messageForPurchasesError(code));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('복원 중 오류가 발생했습니다. 잠시 후 다시 시도하세요.');
    } finally {
      if (mounted) {
        setState(() {
          _restoring = false;
        });
      }
    }
  }

  String _messageForPurchasesError(PurchasesErrorCode code) {
    return '결제 처리 중 오류가 발생했습니다. (${code.name})';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '업그레이드',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                _isLoggedIn
                    ? '결제는 스토어 계정으로 진행되며, 혜택은 현재 로그인한 계정에 적용됩니다.'
                    : '구독 구매/복원을 위해 먼저 로그인하세요. (혜택은 로그인 계정 기준)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _subscription,
              builder:
                  (context, _) => Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_outlined, size: 18),
                        const SizedBox(width: 6),
                        Text('현재 플랜: ${_planLabel(_subscription.currentPlan)}'),
                      ],
                    ),
                  ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadOfferings,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (_errorText != null)
                      _InfoCard(
                        icon: Icons.error_outline,
                        color: AppColors.danger,
                        title: '오퍼링 로드 실패',
                        body: _errorText!,
                        actionLabel: '다시 시도',
                        onTap: _loadingOfferings ? null : _loadOfferings,
                      ),
                    if (_loadingOfferings)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      _buildPlanCard(
                        plan: PlanType.cloud,
                        headline: 'Cloud',
                        benefits: const ['무제한 백업/복원', '광고 제거'],
                        package: _resolvePackageForPlan(PlanType.cloud),
                      ),
                      const SizedBox(height: 12),
                      _buildPlanCard(
                        plan: PlanType.report,
                        headline: 'Report',
                        benefits: const [
                          'Cloud 혜택 포함',
                          '통계 기능',
                          '보고서 다운로드',
                          '광고 제거',
                        ],
                        package: _resolvePackageForPlan(PlanType.report),
                        highlight: true,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.restore_rounded),
                          title: const Text('구독 구매 복원'),
                          subtitle: const Text(
                            '결제 권한(구독 상태)만 복원합니다. 데이터(스냅샷)는 복원되지 않습니다.',
                          ),
                          trailing:
                              _restoring
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.chevron_right),
                          onTap: _restoring || _purchasing ? null : _restore,
                        ),
                      ),
                      if (!_subscription.isRevenueCatEnabled)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _InfoCard(
                            icon: Icons.info_outline,
                            color: AppColors.primary,
                            title: 'RevenueCat 비활성',
                            body:
                                'SDK 키가 설정되지 않아 현재 Free 모드로 동작 중입니다. '
                                '`--dart-define=RC_ANDROID_PUBLIC_SDK_KEY=...` 또는 '
                                '`RC_IOS_PUBLIC_SDK_KEY`를 설정하세요.',
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required PlanType plan,
    required String headline,
    required List<String> benefits,
    required Package? package,
    bool highlight = false,
  }) {
    final product = package?.storeProduct;
    final priceText = product == null ? '상품 미연결' : product.priceString;
    final currentPlan = _subscription.currentPlan;
    final alreadyIncluded =
        currentPlan == PlanType.report ||
        currentPlan == plan ||
        (currentPlan == PlanType.cloud && plan == PlanType.free);

    return Card(
      margin: EdgeInsets.zero,
      color:
          highlight
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  headline,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                if (highlight)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('추천'),
                  ),
                const Spacer(),
                if (alreadyIncluded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('사용 중'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (final benefit in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle_outline, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              priceText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            if (package != null) ...[
              const SizedBox(height: 4),
              Text(
                product?.title ?? package.identifier,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    package == null ||
                            _purchasing ||
                            _restoring ||
                            alreadyIncluded
                        ? null
                        : () => _purchasePackage(package),
                child:
                    _purchasing
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text('$headline 구매'),
              ),
            ),
            if (package == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'RevenueCat Offering/Package 연결 후 표시됩니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Package? _resolvePackageForPlan(PlanType plan) {
    final offerings = _offerings;
    if (offerings == null) return null;

    final targetOfferingId =
        plan == PlanType.report
            ? RevenueCatOfferingIds.report
            : RevenueCatOfferingIds.cloud;

    final exact = offerings.all[targetOfferingId];
    final heuristicOffering =
        exact ?? _findOfferingByIdHint(offerings, targetOfferingId);
    final package = _pickBestPackage(heuristicOffering);
    if (package != null) return package;

    return _findPackageByIdentifierHint(offerings, targetOfferingId);
  }

  Offering? _findOfferingByIdHint(Offerings offerings, String hint) {
    final lowerHint = hint.toLowerCase();
    for (final entry in offerings.all.entries) {
      if (entry.key.toLowerCase().contains(lowerHint)) {
        return entry.value;
      }
    }
    return null;
  }

  Package? _findPackageByIdentifierHint(Offerings offerings, String hint) {
    final lowerHint = hint.toLowerCase();
    for (final offering in offerings.all.values) {
      for (final package in offering.availablePackages) {
        final productId = package.storeProduct.identifier.toLowerCase();
        final packageId = package.identifier.toLowerCase();
        if (productId.contains(lowerHint) || packageId.contains(lowerHint)) {
          return package;
        }
      }
    }
    return null;
  }

  Package? _pickBestPackage(Offering? offering) {
    if (offering == null) return null;
    if (offering.monthly != null) return offering.monthly!;
    if (offering.annual != null) return offering.annual!;
    if (offering.availablePackages.isEmpty) return null;
    return offering.availablePackages.first;
  }

  String _planLabel(PlanType plan) {
    return switch (plan) {
      PlanType.free => 'Free',
      PlanType.cloud => 'Cloud',
      PlanType.report => 'Report',
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body),
            if (actionLabel != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: onTap,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
