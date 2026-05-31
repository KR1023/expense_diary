import 'package:expense_diary/const/admob_config.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GetIt.I<SubscriptionService>(),
      builder: (context, _) {
        if (GetIt.I<SubscriptionService>().isAdsRemoved) {
          return const SizedBox.shrink();
        }
        return const _BannerAdContent();
      },
    );
  }
}

class _BannerAdContent extends StatefulWidget {
  const _BannerAdContent();

  @override
  State<StatefulWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdContent> {
  late final BannerAd banner;

  @override
  void initState() {
    super.initState();

    final adUnitId = AdMobConfig.bannerAdUnitId;
    if (adUnitId == null) {
      debugPrint('BannerAdWidget: AdMob banner ad unit ID is missing.');
      return;
    }

    // 광고 생성
    banner = BannerAd(
      size: AdSize.leaderboard,
      adUnitId: adUnitId,
      // 광고의 생명 주기가 변경될 때마다 실행할 함수들을 설정
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('banner loaded.');
          debugPrint('$ad');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('$error');
          ad.dispose();
        },
      ),
      // 광고 요청 정보를 담고 있는 클래스
      request: AdRequest(),
    );

    // 광고 로딩
    banner.load();
  }

  @override
  void dispose() {
    if (AdMobConfig.bannerAdUnitId != null) banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdMobConfig.bannerAdUnitId == null) return const SizedBox.shrink();

    return SizedBox(
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white),
          child: AdWidget(ad: banner),
        ),
      ),
    );
  }
}
