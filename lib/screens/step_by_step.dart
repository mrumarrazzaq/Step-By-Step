import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:stepbystep/authentication/authentication_with_google.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/home.dart';
import 'package:stepbystep/screens/security_section/signIn_screen.dart';

import 'package:stepbystep/visualization/visualization.dart';

class StepByStep extends StatefulWidget {
  const StepByStep({Key? key}) : super(key: key);

  @override
  State<StepByStep> createState() => _StepByStepState();
}

class _StepByStepState extends State<StepByStep> {
  int _currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    Container(),
    Container(),
    Container(),
    Container()
  ];

  final storage = const FlutterSecureStorage();

  delay() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  String signInWith = 'NULL';

  isGoogleLogin() async {
    String? value = await storage.read(key: 'signInWith') ?? 'NULL';
    setState(() {
      signInWith = value;
    });
    log('isGoogleLogin value is reading: $signInWith');
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    await storage.delete(key: 'uid');
  }

  googleSignOut() async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    provider.logOut();
    await storage.delete(key: 'uid');
  }

  @override
  void initState() {
    super.initState();
    isGoogleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('logos/StepByStep(text).png', height: 22),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Visualization(),
                  ));
            },
            icon: const Icon(Icons.mobile_friendly),
          ),
        ],
      ),
      drawer: Drawer(
        child: IconButton(
          icon: Icon(Icons.logout, color: AppColor.black),
          onPressed: () async {
            signInWith == 'GOOGLE' ? googleSignOut() : signOut();
            log('SignOut called');
            await Fluttertoast.showToast(
              msg: 'User Logout Successfully', // message
              toastLength: Toast.LENGTH_SHORT, // length
              gravity: ToastGravity.BOTTOM, // location
              backgroundColor: Colors.green,
            );
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
                (route) => false);
          },
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline_sharp),
            label: 'My Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
