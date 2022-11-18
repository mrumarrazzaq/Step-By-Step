import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stepbystep/authentication/authentication_with_google.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/privacy_policy.dart';
import 'package:stepbystep/screens/security_section/signIn_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final storage = const FlutterSecureStorage();
  String signInWith = 'NULL';
  String name = '';
  String email = '';
  String imageURL = '';

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

  getData() async {
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(currentUserEmail)
          .get()
          .then((ds) {
        name = ds['User Name'];
        email = ds['User Email'];
        imageURL = ds['Image URL'];
        log(name);
        log(email);
        log(imageURL);
      });
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    getData();
    isGoogleLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _userAccountsDrawerHeader(),
            FlatButton(
              child: const ListTile(
                leading: Icon(Icons.privacy_tip),
                title: Text('Privacy Policy'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicy(),
                  ),
                );
              },
            ),
            FlatButton(
              onPressed: () async {
                signInWith == 'GOOGLE' ? googleSignOut() : signOut();
                log('SignOut called');
                await Fluttertoast.showToast(
                  msg: 'User Logout Successfully', // message
                  toastLength: Toast.LENGTH_SHORT, // length
                  gravity: ToastGravity.BOTTOM, // location
                  backgroundColor: Colors.green,
                );
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                      (route) => false);
                }
              },
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: AppColor.black,
                ),
                title: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userAccountsDrawerHeader() {
    try {
      return UserAccountsDrawerHeader(
        currentAccountPictureSize: const Size.square(70.0),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/abstract_bg.png'),
          ),
        ),
        currentAccountPicture: GestureDetector(
          onTap: () {},
          child: imageURL.isEmpty
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          backgroundColor: AppColor.orange.withOpacity(0.5),
                          minRadius: 15.0,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          name[0],
                          style: GoogleFonts.righteous(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : CircleAvatar(
                  backgroundColor: AppColor.orange.withOpacity(0.5),
                  minRadius: 15.0,
                  backgroundImage: NetworkImage(imageURL.toString()),
                ),
        ),
        accountName: Text(
          name,
          style: const TextStyle(color: Colors.black),
        ),
        accountEmail: Text(
          email,
          style: const TextStyle(color: Colors.black),
        ),
      );
    } catch (e) {
      log(e.toString());
      return Center(
        child: CircularProgressIndicator(
          color: AppColor.orange,
          strokeWidth: 2.0,
        ),
      );
    }
  }
}
