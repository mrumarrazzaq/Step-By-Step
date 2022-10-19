// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/security_section/signIn_screen.dart';

final user = FirebaseFirestore.instance;

class RegistrationScreen extends StatefulWidget {
  static const String id = 'RegisterScreen';

  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isValidEmail = false;
  bool _isLoading = false;

  var personName = "";
  var email = "";
  var password = "";
  var confirmPassword = "";

  final personNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    log("RegisterScreen Build Run");
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'REGISTER',
                  style: GoogleFonts.oswald(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.black,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              //Name
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 20.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  cursorColor: AppColor.orange,
                  style: TextStyle(color: AppColor.black),
                  decoration: InputDecoration(
                    isDense: true,
                    enabled: _isLoading ? false : true,
                    /*fillColor: AppColor.orange,
                    filled: true,*/
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.0),
                    ),
                    hintText: 'Enter Name',
                    // hintStyle: TextStyle(color: purpleColor),
                    label:
                        Text('Name', style: TextStyle(color: AppColor.black)),
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
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 20.0),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: AppColor.black,
                  style: TextStyle(color: AppColor.black),
                  decoration: InputDecoration(
                    isDense: true,
                    enabled: _isLoading ? false : true,
                    // fillColor: whiteColor,
                    // filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.0),
                    ),
                    hintText: 'Enter Email Id',
                    // hintStyle: TextStyle(color: purpleColor),
                    label: Text('Email Id',
                        style: TextStyle(color: AppColor.black)),
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
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 20.0),
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
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    hintText: 'Enter Password',
                    // hintStyle: TextStyle(color: purpleColor),
                    label: Text('Password',
                        style: TextStyle(color: AppColor.black)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.0),
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
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
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
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    hintText: 'Enter Confirm Password',
                    // hintStyle: TextStyle(color: purpleColor),
                    label: Text('Confirm Password',
                        style: TextStyle(color: AppColor.black)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.0),
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
              Material(
                color: AppColor.orange,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  minWidth: _isLoading ? 50.0 : 160.0,
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  onPressed: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    if (_isLoading) {
                    } else {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isValidEmail = true;
                          personName = personNameController.text;
                          email = emailController.text;
                          password = passwordController.text;
                          confirmPassword = confirmPasswordController.text;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an Account? ",
                      style: TextStyle(color: AppColor.black)),
                  TextButton(
                      onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            )
                          },
                      child: const Text('SignIn'))
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

        final json = {
          'User Name': personName,
          'User Email': emailController.text.trim(),
          'User Password': passwordController.text.trim(),
        };

        user.collection('User Data').doc(email).set(json);
        await storage.write(
            key: 'password', value: passwordController.text.trim());
        await storage.write(key: 'email', value: emailController.text.trim());
        log('------------------------------------');
        log('Email and Password Save Successfully');
        log('------------------------------------');

        Fluttertoast.showToast(
          msg: 'Registered Successfully.. Now Login', // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
          backgroundColor: Colors.green,
        );

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
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

          _scaffoldKey.currentState!.showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Sorry! Account Already Exist !',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });

      _scaffoldKey.currentState!.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Password and Confirm Password doesn\'t match !',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      );
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
