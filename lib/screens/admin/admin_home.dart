import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/admin/admin_Dashboard.dart';
import 'package:stepbystep/screens/admin/admin_configuration_panel.dart';
import 'package:stepbystep/screens/security_section/signIn_screen2.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final storage = const FlutterSecureStorage();

  int _currentIndex = 0;
  final List<Widget> screens = [
    const AdminDashboard(),
    const AdminConfigurationPanel()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome SBS Admin',
          style: GoogleFonts.kanit(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout,
                        color: AppColor.black,
                      ),
                      const Text(' Logout'),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 'logout') {
                logoutConfirmationDialog();
              }
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Config Panel',
          ),
        ],
      ),
    );
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
                  signOut();
                  log('SignOut called');
                  Get.snackbar(
                    "Logout",
                    "You logout successfully",
                    colorText: Colors.white,
                    icon: const Icon(Icons.person, color: Colors.white),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                  );
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

  signOut() async {
    await FirebaseAuth.instance.signOut();
    await storage.delete(key: 'isAdmin');
  }
}
