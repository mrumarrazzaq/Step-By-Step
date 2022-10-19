import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/apis/notification_api.dart';
import 'package:stepbystep/screens/step_by_step.dart';
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
    checkLoginStatus();
    NotificationAPI.init(initScheduled: true);
    listenNotifications();
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
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'Step By Step',
        debugShowCheckedModeBanner: false,
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
                ? const SignInScreen()
                : const StepByStep(),
      ),
    );
  }
}
