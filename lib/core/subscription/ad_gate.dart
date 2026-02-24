import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AdGate extends StatelessWidget {
  const AdGate({
    super.key,
    required this.child,
    this.placeholder = const SizedBox.shrink(),
  });

  final Widget child;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.I;
    if (!getIt.isRegistered<SubscriptionService>()) {
      return child;
    }

    final subscription = getIt<SubscriptionService>();
    return AnimatedBuilder(
      animation: subscription,
      builder: (_, __) {
        if (!subscription.currentPolicy.canViewAds) {
          return placeholder;
        }
        return child;
      },
    );
  }
}
