import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/404_error.dart';
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

  @override
  void initState() {
    log('MY APP INIT RUNNING');
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
        child: MaterialApp(
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
                  ? !_internetConnectionStatus
                      ? const Error404()
                      : const SignInScreen()
                  : !_internetConnectionStatus
                      ? const Error404()
                      : const StepByStep(),
        ),
      ),
    );
  }
}
