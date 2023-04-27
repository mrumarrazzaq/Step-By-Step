import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stepbystep/screens/security_section/signIn_screen2.dart';

class AuthenticateUserEmail extends StatefulWidget {
  const AuthenticateUserEmail({Key? key, required this.email})
      : super(key: key);
  final String email;

  @override
  State<AuthenticateUserEmail> createState() => _AuthenticateUserEmailState();
}

class _AuthenticateUserEmailState extends State<AuthenticateUserEmail> {
  bool isEmailVerified = false;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      log('Email send Successfully for Verification Email');
    } catch (e) {
      log(e.toString());
      log('Email not send Successfully for Verification Email');
    }
  }

  void updateUserAccountDetails() {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('User Data').doc(widget.email);

      docRef.update({
        'Verify Account': true,
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) {
      timer?.cancel();
      updateUserAccountDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // isEmail Not Verified
            Visibility(
              visible: !isEmailVerified,
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Lottie.asset('animations/login-verification.json'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        widget.email,
                        style: GoogleFonts.oswald(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10,
                      ),
                      child: Text(
                        'We have sent an Email. Please check your Email to verify this account.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.aBeeZee(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // isEmailVerified
            Visibility(
              visible: isEmailVerified,
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  children: [
                    Text(
                      'Email Verified',
                      style: GoogleFonts.oswald(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Lottie.asset('animations/verified.json'),
                    ),
                  ],
                ),
              ),
            ),
            // isEmail Not Verified
            Visibility(
              visible: !isEmailVerified,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ListTile(
                  title: const Text(
                    "Already have an Account? ",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  dense: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen2(),
                      ),
                    );
                  },
                ),
              ),
            ),
            // isEmailVerified
            Visibility(
              visible: isEmailVerified,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: ListTile(
                  title: const Text(
                    "Login Now",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  dense: true,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen2(),
                        ),
                        (route) => false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
