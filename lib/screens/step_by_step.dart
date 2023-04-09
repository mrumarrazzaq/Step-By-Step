import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/ads/ad_mob_service.dart';
import 'package:stepbystep/apis/get_apis.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/listeners/firebase_listener.dart';

import 'package:stepbystep/screens/drawer.dart';
import 'package:stepbystep/screens/home.dart';
import 'package:stepbystep/screens/inbox_section/recent_workspackes.dart';
import 'package:stepbystep/screens/motivational_quotes.dart';
import 'package:stepbystep/screens/ai_bot.dart';
import 'package:stepbystep/screens/user_profile_section/user_profile.dart';

String sbsName = '';
String sbsEmail = '';
String sbsImageURL = '';

class StepByStep extends StatefulWidget {
  const StepByStep({Key? key}) : super(key: key);

  @override
  State<StepByStep> createState() => _StepByStepState();
}

class _StepByStepState extends State<StepByStep> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isPaidAccount = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  final List<Widget> screens = [
    const HomeScreen(),
    const MotivationalQuotes(),
    // RecentInboxes(),
    RecentWorkspaces(),
    BotUI(),
    UserProfile()
  ];

  getData() async {
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(currentUserEmail)
          .get()
          .then((ds) {
        sbsName = ds['User Name'];
        sbsEmail = ds['User Email'];
        sbsImageURL = ds['Image URL'];
        log(sbsName);
        log(sbsEmail);
        log(sbsImageURL);
      });
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  isUserPaidAccount() async {
    log('Checking for user account is paid ?');
    _isPaidAccount = await GetApi.isPaidAccount();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    isUserPaidAccount();
    _loadBannerAd();
    _loadInterstitialAd();
    _showInterstitialAd();
    WidgetsBinding.instance.addObserver(this);
    setUserStatus(status: 'Online');
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId!,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: AdMobService.bannerAdListener,
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          _interstitialAd = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      //User Status online
      setUserStatus(status: 'Online');
    } else {
      //User Status offLine
      setUserStatus(status: 'Offline');
    }
  }

  void setUserStatus({required String status}) async {
    await FirebaseFirestore.instance
        .collection('User Data')
        .doc('$currentUserEmail')
        .update({
      'User Current Status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('logos/StepByStep(text).png', height: 22),
        actions: [
          GestureDetector(
            onTap: () async {},
            child: Lottie.asset(
                repeat: false, height: 30, width: 30, 'animations/Info.json'),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ElevatedButton(
          //   onPressed: () {
          //   },
          //   child: Text('Press'),
          // ),
          Visibility(
            visible: _bannerAd != null && !_isPaidAccount,
            child: SizedBox(
              height: 52,
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  IconData(0xf0a9, fontFamily: 'MaterialIcons'),
                ),
                label: 'Quotes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none_outlined),
                label: 'Inbox',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.adb),
                label: 'Bot',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
