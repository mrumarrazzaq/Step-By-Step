import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/notificationservice/local_notification_service.dart';
import 'package:stepbystep/screens/404_error.dart';
import 'package:stepbystep/screens/onboarding_screen/onboading_screen.dart';
import 'package:stepbystep/screens/step_by_step.dart';
import 'package:stepbystep/apis/notification_api.dart';
import 'package:stepbystep/screens/security_section/signIn_screen.dart';
import 'package:stepbystep/authentication/authentication_with_google.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // FlutterLocalNotificationsPlugin fltNotification =
  //     FlutterLocalNotificationsPlugin();
  final _storage = const FlutterSecureStorage();
  bool _isLogin = false;
  bool _isWaiting = true;

  bool _internetConnectionStatus = false;

  Future<void> checkLoginStatus() async {
    String? value = await _storage.read(key: 'uid');
    if (value == null) {
      setState(() {
        _isLogin = false;
        _isWaiting = false;
      });
      log('---------------');
      log('User is logIN $_isLogin');
    } else {
      setState(() {
        _isLogin = true;
        _isWaiting = false;
      });
      log('---------------');
      log('User is logIN $_isLogin');
    }
  }

  void pushFCMToken() async {
    String? token = await messaging.getToken();
    log(token.toString());
  }

  @override
  void initState() {
    log('MY APP INIT RUNNING');
    pushFCMToken();
    // initMessaging();
    checkLoginStatus();
    NotificationAPI.init(initScheduled: true);
    listenNotifications();
    InternetConnectionChecker().onStatusChange.listen(
      (status) {
        final hasInternet = status == InternetConnectionStatus.connected;
        final text = hasInternet ? 'Internet' : 'No internet connection';
        final color = hasInternet ? Colors.green : Colors.red;
        final icon = hasInternet ? Icons.wifi : Icons.wifi_off;
        setState(
          () {
            _internetConnectionStatus = hasInternet;
            if (!_internetConnectionStatus) {
              showSimpleNotification(
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                leading: Icon(icon),
                background: color,
              );
            }
          },
        );
      },
    );

    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        log("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          LocalNotificationService.createAndDisplayNotification(message);
          log("New Notification");
          if (message.data['_id'] != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    !_isLogin ? const SignInScreen() : const StepByStep(),
              ),
            );
          }
        }
      },
    );

    // 2. This method only call when App in foreground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        log("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          log(message.notification!.title.toString());
          log(message.notification!.body.toString());
          log("message.data11 ${message.data}");
          LocalNotificationService.createAndDisplayNotification(message);
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        log("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          log(message.notification!.title.toString());
          log(message.notification!.body.toString());
          log("message.data22 ${message.data['_id']}");
          LocalNotificationService.createAndDisplayNotification(message);
        }
      },
    );

    super.initState();
  }

  void listenNotifications() =>
      NotificationAPI.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) =>
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const StepByStep(),
        ),
      );
  @override
  Widget build(BuildContext context) {
    log('MY APP BUILD RUNNING');
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: OverlaySupport.global(
        child: GetMaterialApp(
          title: 'Step By Step',
          debugShowCheckedModeBanner: false,
          builder: BotToastInit(), //1. call BotToastInit
          navigatorObservers: [BotToastNavigatorObserver()],
          theme: ThemeData(
            primaryColor: AppColor.orange,
            splashColor: AppColor.orange.withOpacity(0.1),
            accentColor: AppColor.orange,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColor.white,
              actionsIconTheme: IconThemeData(color: AppColor.black),
              iconTheme: IconThemeData(color: AppColor.black),
              foregroundColor: AppColor.black,
              centerTitle: true,
              elevation: 0.0,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: AppColor.black,
              selectedItemColor: AppColor.white,
              unselectedItemColor: AppColor.grey,
              elevation: 0.0,
              enableFeedback: false,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              selectedLabelStyle: const TextStyle(fontSize: 10),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
            ),
          ),
          home: _isWaiting
              ? Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.orange,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : !_isLogin
                  ? const OnBoardingScreen()
                  // const SignInScreen()
                  : const StepByStep(),
          // : Intro(
          //     padding: const EdgeInsets.all(8),
          //     borderRadius: const BorderRadius.all(
          //       Radius.circular(4),
          //     ),
          //     maskColor: const Color.fromRGBO(0, 0, 0, .6),
          //     noAnimation: true,
          //     maskClosable: false,
          //     buttonTextBuilder: (order) =>
          //         order == 3 ? 'Custom Button Text' : 'Next',
          //     child: const StepByStep(),
          //   ),

          // !_isLogin
          //     ? !_internetConnectionStatus
          //     ? const Error404()
          //     : const SignInScreen()
          //     : !_internetConnectionStatus
          //     ? const Error404()
          //     : const StepByStep(),
        ),
      ),
    );
  }

  // void initMessaging() {
  //   var androidInit =
  //       const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var iosInit = const IOSInitializationSettings();
  //   var initSetting =
  //       InitializationSettings(android: androidInit, iOS: iosInit);
  //   fltNotification = FlutterLocalNotificationsPlugin();
  //   fltNotification.initialize(initSetting);
  //   var androidDetails = const AndroidNotificationDetails('1', 'channelName');
  //   var iosDetails = const IOSNotificationDetails();
  //   var generalNotificationDetails =
  //       NotificationDetails(android: androidDetails, iOS: iosDetails);
  //   FirebaseMessaging.onMessage.listen(
  //     (RemoteMessage message) {
  //       RemoteNotification? notification = message.notification;
  //       AndroidNotification? android = message.notification?.android;
  //       if (notification != null && android != null) {
  //         fltNotification.show(notification.hashCode, notification.title,
  //             notification.body, generalNotificationDetails);
  //       }
  //     },
  //   );
  // }
}
