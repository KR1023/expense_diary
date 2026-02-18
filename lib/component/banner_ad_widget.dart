import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BannerAdWidgetState();

}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late final BannerAd banner;

  @override
  void initState() {
    super.initState();

    // 사용할 테스트 광고 ID 설정
    // final adUnitId = Platform.isIOS ?
    //     'ca-app-pub-3940256099942544/2934735716'
    //     : 'ca-app-pub-3940256099942544/6300978111';


    // real ID
    final adUnitId = Platform.isIOS ?
        'ca-app-pub-5444803558030319/5504549409'
        : 'ca-app-pub-3940256099942544/6300978111';

    // 광고 생성
    banner = BannerAd(
      size: AdSize.leaderboard,
      adUnitId: adUnitId,
      // 광고의 생명 주기가 변경될 때마다 실행할 함수들을 설정
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print("banner loaded.");
          print(ad);
        },
        onAdFailedToLoad: (ad, error) {
          print(error);
          ad.dispose();
        }
      ),
      // 광고 요청 정보를 담고 있는 클래스
      request: AdRequest()
    );

    // 광고 로딩
    banner.load();
  }

  @override
  void dispose() {
    banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: AdWidget(ad: banner) // 광고 위젯에 banner  변수 입력
    );
  }
}