import 'dart:async';

import 'package:expense_diary/core/subscription/plan_type.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:expense_diary/screen/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

typedef GuardAllowedCallback = FutureOr<void> Function();

class PlanGuard {
  const PlanGuard._();

  static Future<bool> requireCloud(
    BuildContext context, {
    GuardAllowedCallback? onAllowed,
  }) {
    return _require(context, minimumPlan: PlanType.cloud, onAllowed: onAllowed);
  }

  static Future<bool> requireReport(
    BuildContext context, {
    GuardAllowedCallback? onAllowed,
  }) {
    return _require(
      context,
      minimumPlan: PlanType.report,
      onAllowed: onAllowed,
    );
  }

  static Future<bool> _require(
    BuildContext context, {
    required PlanType minimumPlan,
    GuardAllowedCallback? onAllowed,
  }) async {
    if (_meetsRequirement(_currentPlan, minimumPlan)) {
      if (onAllowed != null) {
        await onAllowed();
      }
      return true;
    }

    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const PaywallScreen()));

    final refreshedPlan = _currentPlan;
    if (_meetsRequirement(refreshedPlan, minimumPlan)) {
      if (onAllowed != null) {
        await onAllowed();
      }
      return true;
    }

    return false;
  }

  static PlanType get _currentPlan {
    final getIt = GetIt.I;
    if (!getIt.isRegistered<SubscriptionService>()) {
      return PlanType.free;
    }
    return getIt<SubscriptionService>().currentPlan;
  }

  static bool _meetsRequirement(PlanType current, PlanType minimum) {
    return switch (minimum) {
      PlanType.free => true,
      PlanType.cloud => current == PlanType.cloud || current == PlanType.report,
      PlanType.report => current == PlanType.report,
    };
  }
}
