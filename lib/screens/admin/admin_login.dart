// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_address/mac_address.dart';

import 'package:provider/provider.dart';
import 'package:stepbystep/authentication/authentication_with_google.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/home.dart';
import 'package:stepbystep/screens/security_section/forgot_password.dart';
import 'package:stepbystep/screens/security_section/registeration_screen2.dart';
import 'package:stepbystep/screens/step_by_step.dart';

final user = FirebaseFirestore.instance;

class AdminSignInScreen extends StatefulWidget {
  static const String id = 'SignInScreen';

  const AdminSignInScreen({Key? key}) : super(key: key);

  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _obscureText = true;
  bool isValidEmail = false;
  bool _isLoading = false;
  bool _isGoogleSignIn = false;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  var fcmToken;

  var email = "";
  var password = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final adminKeyController = TextEditingController();
  final storage = const FlutterSecureStorage();
  String getUserEmail = '';
  String getUserPassword = '';

  @override
  void initState() {
    log('SIGNIN INIT RUNNING');
    readEmailAndPassword();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('SIGN IN BUILD RUNNING');

    return _isGoogleSignIn
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColor.orange,
              ),
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            // resizeToAvoidBottomInset: false,
            body: Center(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 25.0,
                    top: 50.0,
                  ),
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome!',
                        style: GoogleFonts.oswald(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.black,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Text(
                        'Sign in to continue',
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColor.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        'Email',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 25.0,
                          bottom: 20.0,
                          top: 10.0,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: AppColor.black,
                          style: TextStyle(color: AppColor.black),
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            isDense: true,
                            enabled: _isLoading ? false : true,
                            // fillColor: tealColor,
                            // filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  BorderSide(color: AppColor.black, width: 1.5),
                            ),

                            hintText: 'Enter Email Id',
                            prefixIcon: Icon(
                              Icons.alternate_email,
                              color: AppColor.black,
                            ),
                            prefixText: '  ',
                            suffixIcon: isValidEmail
                                ? const Icon(Icons.check,
                                    color: Colors.green, size: 20.0)
                                : null,
                          ),
                          controller: emailController,
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'Please enter email'),
                            EmailValidator(errorText: 'Not a Valid Email'),
                          ]),
                        ),
                      ),
                      //Password Text Field
                      const Text(
                        'Password',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 25.0,
                          bottom: 20.0,
                          top: 10.0,
                        ),
                        child: TextFormField(
                          onTap: () {},
                          obscureText: _obscureText,
                          cursorColor: AppColor.black,
                          style: TextStyle(color: AppColor.black),
                          decoration: InputDecoration(
                            isDense: true,
                            enabled: _isLoading ? false : true,
                            // fillColor: purpleColor,
                            // filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintText: 'Enter Password',
                            // hintStyle: TextStyle(color: purpleColor),
//                        labelText: 'Password',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  BorderSide(color: AppColor.black, width: 1.5),
                            ),

                            prefixIcon: Icon(
                              Icons.vpn_key,
                              color: AppColor.black,
                            ),
                            prefixText: '  ',
                            suffixIcon: GestureDetector(
                              child: _obscureText
                                  ? Icon(
                                      Icons.visibility,
                                      size: 18.0,
                                      color: AppColor.black,
                                    )
                                  : Icon(
                                      Icons.visibility_off,
                                      size: 18.0,
                                      color: AppColor.black,
                                    ),
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          controller: passwordController,
                          validator: validatePassword,
                        ),
                      ),
                      //Admin Key
                      const Text(
                        'Admin Key',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 25.0,
                          bottom: 0.0,
                          top: 10.0,
                        ),
                        child: TextFormField(
                          onTap: () {},
                          obscureText: _obscureText,
                          cursorColor: AppColor.black,
                          style: TextStyle(color: AppColor.black),
                          decoration: InputDecoration(
                            isDense: true,
                            enabled: _isLoading ? false : true,
                            // fillColor: purpleColor,
                            // filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintText: 'Enter Admin Key',
                            // hintStyle: TextStyle(color: purpleColor),
//                        labelText: 'Password',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  BorderSide(color: AppColor.black, width: 1.5),
                            ),

                            prefixIcon: Icon(
                              Icons.vpn_key,
                              color: AppColor.black,
                            ),
                            prefixText: '  ',
                            suffixIcon: GestureDetector(
                              child: _obscureText
                                  ? Icon(
                                      Icons.visibility,
                                      size: 18.0,
                                      color: AppColor.black,
                                    )
                                  : Icon(
                                      Icons.visibility_off,
                                      size: 18.0,
                                      color: AppColor.black,
                                    ),
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          controller: adminKeyController,
                          validator: validatePassword,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword(),
                                  ),
                                )
                              },
                              child: const Text(
                                'Forget Password?',
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25.0),
                        child: Material(
                          color: AppColor.black,
                          borderRadius: BorderRadius.circular(10.0),
                          clipBehavior: Clip.antiAlias,
                          child: MaterialButton(
                            minWidth: _isLoading ? 50.0 : double.infinity,
                            elevation: 3.0,
                            height: 40.0,
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            onPressed: () {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');

                              if (_isLoading) {
                              } else {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isValidEmail = true;
                                    email = emailController.text;
                                    password = passwordController.text;
                                  });
                                  signInWithEmailAndPassword();
                                }
                              }
                            },
                            child: _isLoading
                                ? SizedBox(
                                    height: 30.0,
                                    width: 30.0,
                                    child: CircularProgressIndicator(
                                      color: AppColor.white,
                                      strokeWidth: 3.0,
                                    ),
                                  )
                                : Text(
                                    'Admin Login',
                                    style: TextStyle(
                                      color: AppColor.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  signInWithGoogle() async {
    log('SIGN IN WITH GOOGLE IS PROCESSING');
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    try {
      log('Try Block is Running');
      await provider.googleLogIn();
      final currentUser = FirebaseAuth.instance.currentUser!;

      log('--------------------------------');
      log(currentUser.email!);
      log(currentUser.displayName!);
      log('--------------------------------');

      try {
        var existingEmail;
        await FirebaseFirestore.instance
            .collection('User Data')
            .doc(currentUser.email)
            .get()
            .then((ds) {
          existingEmail = ds['User Email'];
          log('--------------------------------------');
          log('Google Account Already Exist Saved');
          log('--------------------------------------');
        });
        log(existingEmail);
      } catch (e) {
        log('--------------------------------------');
        log('No Data found This GOOGLE Account is New');
        log('--------------------------------------');

        String mac = 'UNKNOWN';
        try {
          mac = await GetMac.macAddress;
          log(mac);
        } catch (e) {
          log('Failed To get MAC Address');
        }

        final json = {
          'Verify Account': true,
          'MAC': mac,
          'User Name': currentUser.displayName!,
          'User Email': currentUser.email!,
          'User Password': currentUser.uid,
          'User Current Status': 'Offline',
          'Status Quote': '',
          'Image URL': currentUser.photoURL,
          'Joined Workspaces': [],
          'Owned Workspaces': [],
          'Created At': DateTime.now(),
        };
        user.collection('User Data').doc(currentUser.email!).set(json);
        fcmToken = await _fcm.getToken();

        final jsonToken = {
          'token': fcmToken,
          'createdAT': FieldValue.serverTimestamp(),
        };

        log('--------------------------------------------------');
        log('FCM Token : $fcmToken');
        log('--------------------------------------------------');
        user
            .collection('User Data')
            .doc(currentUser.email!)
            .collection('Token')
            .doc(currentUser.email!)
            .set(jsonToken);
        log('--------------------------------------');
        log('Data is save into User Data For GOOGLE');
        log('--------------------------------------');
      }

      await storage.write(key: 'uid', value: 'abc...xyz');
      await storage.write(key: 'signInWith', value: 'GOOGLE');

      setState(() {
        _isGoogleSignIn = false;
      });

      if (mounted) {
        Get.snackbar(
          "Login",
          "You login successfully",
          colorText: Colors.white,
          icon: const Icon(Icons.person, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );
        // await Fluttertoast.showToast(
        //   msg: 'User Login Successfully', // message
        //   toastLength: Toast.LENGTH_SHORT, // length
        //   gravity: ToastGravity.BOTTOM, // location
        //   backgroundColor: Colors.green,
        // );
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const StepByStep(),
            ),
            (route) => false);
      }
      setState(() {
        currentUserId = FirebaseAuth.instance.currentUser!.uid;
        currentUserEmail = FirebaseAuth.instance.currentUser!.email;
        log('---------------------------------');
        log(currentUserEmail.toString());
        log('---------------------------------');
      });
    } catch (e) {
      log('=======================================');
      log(e.toString());
      log('=======================================');
      //   await Fluttertoast.showToast(
      //     msg: 'Failed to Login Try Again', // message
      //     toastLength: Toast.LENGTH_SHORT, // length
      //     gravity: ToastGravity.BOTTOM, // location
      //     backgroundColor: Colors.grey,
      //   );
      //   Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const SignInScreen(),
      //       ),
      //       (route) => false);
    }
  }

  signInWithEmailAndPassword() async {
    log('SIGN IN WITH EMAIL AND PASSWORD IS PROCESSING');
    try {
      _isLoading = true;
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
//______________________________________________________________________//
      log('user credential email : ${userCredential.user?.email}');
      await storage.write(key: 'uid', value: userCredential.user?.uid);
      await storage.write(key: 'signInWith', value: 'OTHER');
//______________________________________________________________________//
      if (mounted) {
        Get.snackbar(
          "Login",
          "You login successfully",
          colorText: Colors.white,
          icon: const Icon(Icons.person, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );
        // Fluttertoast.showToast(
        //   msg: 'User Login Successfully', // message
        //   toastLength: Toast.LENGTH_SHORT, // length
        //   gravity: ToastGravity.BOTTOM, // location
        //   backgroundColor: Colors.green,
        // );
        setState(() {
          currentUserId = FirebaseAuth.instance.currentUser!.uid;
          currentUserEmail = FirebaseAuth.instance.currentUser!.email;
          log('---------------------------------');
          log(currentUserEmail.toString());
          log('---------------------------------');
        });

        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const StepByStep(),
        //     ),
        //     (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'user-not-found') {
        Get.snackbar(
          "Alert",
          "Email is not registered",
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        // _scaffoldKey.currentState!.showSnackBar(
        //   const SnackBar(
        //     backgroundColor: Colors.red,
        //     content: Text(
        //       "No User Found for that Email",
        //       style: TextStyle(fontSize: 15.0, color: Colors.white),
        //     ),
        //   ),
        // );
      } else if (e.code == 'wrong-password') {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          "Alert",
          "Password is not correct",
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        // _scaffoldKey.currentState!.showSnackBar(
        //   const SnackBar(
        //     backgroundColor: Colors.red,
        //     content: Text(
        //       "Wrong Password Provided by User",
        //       style: TextStyle(fontSize: 15.0, color: Colors.white),
        //     ),
        //   ),
        // );
      }
    }
  }

  String? validatePassword(value) {
    if (value.isEmpty) {
      return 'Please enter password';
    } else if (value.length < 8) {
      return 'Should be at least 8 characters';
    } else if (value.length > 25) {
      return 'Should not be more than 25 characters';
    } else {
      return null;
    }
  }

  String? validateAdminKey(value) {
    if (value.isEmpty) {
      return 'Please enter admin key';
    } else if (value.length < 8) {
      return 'Should be at least 8 characters';
    } else if (value.length > 25) {
      return 'Should not be more than 25 characters';
    } else {
      return null;
    }
  }

  void readEmailAndPassword() async {
    log('User Email and password is reading');
    String emailValue = await storage.read(key: 'email') ?? 'NULL';
    String passValue = await storage.read(key: 'password') ?? 'NULL';
    setState(() {
      getUserEmail = emailValue;
      getUserPassword = passValue;
    });
  }
}
