// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stepbystep/apis/launch_url_api.dart';
import 'package:stepbystep/authentication/authentication_with_google.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/privacy_policy.dart';
import 'package:stepbystep/screens/security_section/signIn_screen2.dart';
import 'package:stepbystep/screens/user_profile_section/user_profile.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final storage = const FlutterSecureStorage();
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

  void setUserStatus({required String status}) async {
    await FirebaseFirestore.instance
        .collection('User Data')
        .doc('$currentUserEmail')
        .update({
      'User Current Status': status,
    });
  }

  @override
  void initState() {
    isGoogleLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.orange,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // _userAccountsDrawerHeader(
            //     widget.name, widget.email, widget.imageUrl),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User Data')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  log('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  log('Waiting for know user online status');
                }

                final List data = [];
                if (snapshot.hasData) {
                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map id = document.data() as Map<String, dynamic>;
                    if (currentUserEmail.toString() == document.id) {
                      data.add(id);
                      id['id'] = document.id;
                    }
                  }).toList();
                }
                return _userAccountsDrawerHeader(
                  snapshot.hasData ? data[0]['User Name'] : '',
                  snapshot.hasData ? data[0]['User Email'] : '',
                  snapshot.hasData ? data[0]['Image URL'] : '',
                );
              },
            ),
            Divider(
              color: AppColor.white,
              thickness: 1,
            ),
            FlatButton(
              child: const ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text('Your Profile'),
                textColor: Colors.white,
                trailing: Icon(Icons.arrow_forward, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfile(),
                  ),
                );
              },
            ),
            Divider(color: AppColor.white, indent: 15, endIndent: 15),
            FlatButton(
              child: const ListTile(
                leading: Icon(Icons.privacy_tip, color: Colors.white),
                title: Text('Privacy Policy'),
                textColor: Colors.white,
                trailing: Icon(Icons.arrow_forward, color: Colors.white),
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
            Divider(color: AppColor.white, indent: 15, endIndent: 15),
            FlatButton(
              child: ListTile(
                leading: Image.asset(
                  'assets/remove-ads-icon.png',
                  color: Colors.white,
                  height: 25,
                ),
                title: const Text('Remove Ads'),
                textColor: Colors.white,
                trailing: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
              onPressed: () {},
            ),
            Divider(color: AppColor.white, indent: 15, endIndent: 15),
            FlatButton(
              child: const ListTile(
                leading: Icon(Icons.help, color: Colors.white),
                title: Text('Get Help'),
                textColor: Colors.white,
                trailing: Icon(Icons.arrow_forward, color: Colors.white),
              ),
              onPressed: () {
                LaunchURLAPI.launchMyUrl(Uri.parse('https://flutter.dev'));
              },
            ),
            Divider(color: AppColor.white, indent: 15, endIndent: 15),
            FlatButton(
              onPressed: () async {
                logoutConfirmationDialog();
              },
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: AppColor.white,
                ),
                title: const Text('Logout'),
                textColor: Colors.white,
                trailing: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userAccountsDrawerHeader(String name, String email, String imageURL) {
    try {
      return UserAccountsDrawerHeader(
        currentAccountPictureSize: const Size.square(80.0),
        // decoration: BoxDecoration(
        //   color: AppColor.orange,
        // image: DecorationImage(
        //   fit: BoxFit.cover,
        //   image: AssetImage('assets/abstract_bg.png'),
        // ),
        // ),
        currentAccountPicture: ClipRRect(
          borderRadius: BorderRadius.circular(10000.0),
          child: CachedNetworkImage(
              imageUrl: imageURL,
              // maxWidthDiskCache: 500,
              // maxHeightDiskCache: 500,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                    height: 200,
                    width: 200,
                    color: AppColor.white,
                  ),
              errorWidget: (context, url, error) => Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColor.orange,
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.white),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'logos/user.png',
                        width: 50,
                        color: AppColor.white,
                      ),
                    ),
                  )),
        ),
        accountName: Text(
          name,
          style: TextStyle(color: AppColor.white, fontSize: 20),
        ),
        accountEmail: Text(
          email,
          style: TextStyle(color: AppColor.white, fontSize: 15),
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

  logoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        alignment: Alignment.center,
        backgroundColor: AppColor.lightOrange,
        title: Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColor.white,
            child: Image.asset('assets/logout.png', width: 50),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Want to logout?',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            Text(
              'Click on the logout button if you really want to logout?',
              textAlign: TextAlign.center,
              style: GoogleFonts.titilliumWeb(),
            ),
            const SizedBox(height: 12.0),
            Material(
              color: AppColor.orange,
              borderRadius: BorderRadius.circular(10.0),
              clipBehavior: Clip.antiAlias,
              child: MaterialButton(
                onPressed: () {
                  signInWith == 'GOOGLE' ? googleSignOut() : signOut();
                  log('SignOut called');
                  Get.snackbar(
                    "Logout",
                    "You logout successfully",
                    colorText: Colors.white,
                    icon: const Icon(Icons.person, color: Colors.white),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                  );
                  // await Fluttertoast.showToast(
                  //   msg: 'User Logout Successfully', // message
                  //   toastLength: Toast.LENGTH_SHORT, // length
                  //   gravity: ToastGravity.BOTTOM, // location
                  //   backgroundColor: Colors.green,
                  // );
                  setUserStatus(status: 'Offline');
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen2(),
                        ),
                        (route) => false);
                  }
                },
                height: 40,
                minWidth: double.infinity,
                color: AppColor.orange,
                elevation: 0.0,
                child: Text(
                  'Logout',
                  style: TextStyle(color: AppColor.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
