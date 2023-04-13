// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mac_address/mac_address.dart';
import 'package:stepbystep/apis/pick_file_api.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/security_section/authenticate_user_email.dart';
import 'package:stepbystep/screens/security_section/signIn_screen.dart';
import 'package:stepbystep/apis/send_email_api.dart';
import 'package:stepbystep/screens/security_section/signIn_screen2.dert.dart';

final user = FirebaseFirestore.instance;

class RegistrationScreen2 extends StatefulWidget {
  static const String id = 'RegisterScreen';

  const RegistrationScreen2({Key? key}) : super(key: key);

  @override
  _RegistrationScreen2State createState() => _RegistrationScreen2State();
}

class _RegistrationScreen2State extends State<RegistrationScreen2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  var fcmToken;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isValidEmail = false;
  bool _isLoading = false;

  var personName = "";
  var email = "";
  var password = "";
  var confirmPassword = "";
  String imageURL = '';
  String nameInitial = '';
  final personNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    // log("RegisterScreen Build Run");
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'REGISTER',
          style: GoogleFonts.oswald(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.black,
              fontSize: 30,
            ),
          ),
        ),
        leadingWidth: 0.0,
        backgroundColor: AppColor.white,
        leading: Container(),
      ),
      //resizeToAvoidBottomInset: false,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 20.0,
          ),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthenticateUserEmail(email: email),
                    ),
                  );
                },
                child: Text('Press'),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: imageURL.isEmpty
                    ? Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColor.orange,
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: Colors.black),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: nameInitial.isEmpty
                              ? Image.asset(
                                  'logos/user.png',
                                  width: 50,
                                  color: AppColor.white,
                                )
                              : Text(
                                  nameInitial[0],
                                  style: GoogleFonts.bebasNeue(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.white,
                                      fontSize: 50,
                                    ),
                                  ),
                                ),
                        ),
                      )
                    : Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                            image: NetworkImage(imageURL.toString()),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(width: 5, color: Colors.white),
                        ),
                      ),
              ),
              const Text(
                'Full Name',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, right: 20.0, bottom: 20.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  cursorColor: AppColor.orange,
                  style: TextStyle(color: AppColor.black),
                  onChanged: (v) {
                    nameInitial = v;
                    log(nameInitial);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    enabled: _isLoading ? false : true,
                    /*fillColor: AppColor.orange,
                    filled: true,*/
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),
                    hintText: 'Muhammad Ali',
                    prefixIcon: Icon(
                      Icons.person,
                      color: AppColor.black,
                    ),
                    prefixText: '  ',
                  ),
                  controller: personNameController,
                  validator: (String? val) {
                    if (val!.isEmpty) {
                      return "Please enter name";
                    } else if (double.tryParse(val) != null) {
                      return 'numbers not allowed';
                    }
                    return null;
                  },
                ),
              ),
              //Email Address
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, right: 20.0, bottom: 20.0),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: AppColor.black,
                  style: TextStyle(color: AppColor.black),
                  decoration: InputDecoration(
                    isDense: true,
                    enabled: _isLoading ? false : true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),
                    hintText: 'example@gmail.com',
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
                  validator: MultiValidator(
                    [
                      RequiredValidator(errorText: 'Please enter a email'),
                      EmailValidator(errorText: 'Not a Valid Email'),
                    ],
                  ),
                ),
              ),
              //Password
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, right: 20.0, bottom: 20.0),
                child: TextFormField(
                  obscureText: _obscurePassword,
                  cursorColor: AppColor.black,
                  style: TextStyle(color: AppColor.black),
                  decoration: InputDecoration(
                    isDense: true,
                    enabled: _isLoading ? false : true,
                    // fillColor: whiteColor,
                    // filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: 'Enter Password',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),

                    prefixIcon: Icon(
                      Icons.vpn_key,
                      color: AppColor.black,
                    ),
                    prefixText: '  ',
                    suffixIcon: GestureDetector(
                      child: _obscurePassword
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
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  controller: passwordController,
                  validator: validatePassword,
                ),
              ),
              //Confirm Password
              const Text(
                'Confirm Password',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  right: 20.0,
                  bottom: 20.0,
                ),
                child: TextFormField(
                  obscureText: _obscureConfirmPassword,
                  cursorColor: AppColor.black,
                  style: TextStyle(color: AppColor.black),
                  decoration: InputDecoration(
                    isDense: true,
                    enabled: _isLoading ? false : true,
                    // fillColor: whiteColor,
                    // filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: 'Enter Confirm Password',

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),
                    prefixIcon: Icon(
                      Icons.vpn_key,
                      color: AppColor.black,
                    ),
                    prefixText: '  ',
                    suffixIcon: GestureDetector(
                      child: _obscureConfirmPassword
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
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  controller: confirmPasswordController,
                  validator: validatePassword,
                ),
              ),
              //Register Button
              Padding(
                padding: const EdgeInsets.only(
                  right: 20.0,
                ),
                child: Material(
                  color: AppColor.orange,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(10.0),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      if (_isLoading) {
                      } else {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isValidEmail = true;
                            personName = personNameController.text.trim();
                            email = emailController.text.trim();
                            password = passwordController.text.trim();
                            confirmPassword =
                                confirmPasswordController.text.trim();
                          });
                          registerNewUser();
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
                            'Register',
                            style: TextStyle(
                              color: AppColor.white,
                            ),
                          ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an Account? ",
                    style: TextStyle(color: AppColor.black),
                  ),
                  TextButton(
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen2(),
                        ),
                      )
                    },
                    child: const Text('Sign in'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  registerNewUser() async {
    if (password == confirmPassword) {
      try {
        _isLoading = true;

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        log(userCredential.toString());
        String mac = 'UNKNOWN';
        try {
          mac = await GetMac.macAddress;
          log(mac);
        } catch (e) {
          log('Failed To get MAC Address');
        }

        final json = {
          'Verify Account': false,
          'Paid Account': false,
          'MAC': mac,
          'User Name': personName,
          'User Email': emailController.text.trim(),
          'User Password': passwordController.text.trim(),
          'User Current Status': 'Offline',
          'Status Quote': '',
          'Image URL': '',
          'Joined Workspaces': [],
          'Owned Workspaces': [],
          'Created At': DateTime.now(),
        };

        user.collection('User Data').doc(email).set(json);
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
            .doc(email)
            .collection('Token')
            .doc(email)
            .set(jsonToken);

        await storage.write(
            key: 'password', value: passwordController.text.trim());
        await storage.write(key: 'email', value: emailController.text.trim());
        log('------------------------------------');
        log('Email and Password Save Successfully');
        log('------------------------------------');
        await SendEmailAPI().sendEmail(
          name: personName,
          email: emailController.text.trim(),
          subject: 'Thanks for create a account',
          message: 'You have successfully become a part of SBS Team',
        );
        Get.snackbar(
          "Registered Successfully",
          "Now Sign in",
          colorText: Colors.white,
          icon: const Icon(Icons.person, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );
        // Fluttertoast.showToast(
        //   msg: 'Registered Successfully.. Now Sign in', // message
        //   toastLength: Toast.LENGTH_SHORT, // length
        //   gravity: ToastGravity.BOTTOM, // location
        //   backgroundColor: Colors.green,
        // );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AuthenticateUserEmail(email: email),
            ),
          );
        }
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const SignInScreen2(),
        //   ),
        // );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (e.code == 'weak-password') {
          _scaffoldKey.currentState!.showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Password Provided is too Weak!!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            _isLoading = false;
          });
          Get.snackbar(
            "Alert",
            "Account Already Exist !",
            colorText: Colors.white,
            icon: const Icon(Icons.person, color: Colors.white),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
          );
          // _scaffoldKey.currentState!.showSnackBar(
          //   const SnackBar(
          //     backgroundColor: Colors.red,
          //     content: Text(
          //       'Sorry! Account Already Exist !',
          //       style: TextStyle(
          //         fontSize: 15,
          //         color: Colors.white,
          //       ),
          //     ),
          //     duration: Duration(seconds: 1),
          //   ),
          // );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        "Alert",
        "Password and Confirm Password doesn\'t match.",
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );

      // _scaffoldKey.currentState!.showSnackBar(
      //   const SnackBar(
      //     backgroundColor: Colors.red,
      //     content: Text(
      //       'Password and Confirm Password doesn\'t match !',
      //       style: TextStyle(fontSize: 15, color: Colors.white),
      //     ),
      //   ),
      // );
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

  @override
  void dispose() {
    personNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
