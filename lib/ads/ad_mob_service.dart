import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4162681381158025/1144851620';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return null;
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4162681381158025/6289081682';
      //'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    return null;
  }

  static String? get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    return null;
  }

  static BannerAdListener bannerAdListener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (ad) {
      debugPrint('$ad loaded.');
    },

    onAdClosed: (e) => debugPrint('$e opened.'),
    onAdOpened: (e) => debugPrint('$e closed.'),
    onAdClicked: (e) => debugPrint('$e clicked.'),
    onAdFailedToLoad: (ad, err) {
      debugPrint('BannerAd failed to load: $err');
      // Dispose the ad here to free resources.
      ad.dispose();
    },
  );
}
