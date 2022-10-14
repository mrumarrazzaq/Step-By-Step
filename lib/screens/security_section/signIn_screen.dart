import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:stepbystep/authentication/authentication_with_google.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/home.dart';
import 'package:stepbystep/screens/step_by_step.dart';
import 'forgot_password.dart';
import 'registration_screen.dart';

class SignInScreen extends StatefulWidget {
  static const String id = 'SignInScreen';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _obscureText = true;
  bool isValidEmail = false;
  bool _isLoading = false;
  bool _isGoogleSignIn = false;

  var email = "";
  var password = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  String getUserEmail = '';
  String getUserPassword = '';

  @override
  void initState() {
    super.initState();
    readEmailAndPassword();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("SignInScreen Build Run");

    return _isGoogleSignIn
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOGIN',
                      style: GoogleFonts.oswald(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.black,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, bottom: 20.0, top: 20.0),
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
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide:
                                BorderSide(color: AppColor.black, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide:
                                BorderSide(color: AppColor.black, width: 1.0),
                          ),

                          hintText: 'Enter Email Id',
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
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Please enter email'),
                          EmailValidator(errorText: 'Not a Valid Email'),
                        ]),
                      ),
                    ),
                    //Password Text Field
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, bottom: 20.0),
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
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          hintText: 'Enter Password',
                          label: Text('Password',
                              style: TextStyle(color: AppColor.black)),
                          // hintStyle: TextStyle(color: purpleColor),
//                        labelText: 'Password',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide:
                                BorderSide(color: AppColor.black, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide:
                                BorderSide(color: AppColor.black, width: 1.0),
                          ),
//                        labelStyle: TextStyle(color: defaultUIColor),
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
                    Material(
                      color: AppColor.orange,
                      borderRadius: BorderRadius.circular(30.0),
                      clipBehavior: Clip.antiAlias,
                      child: MaterialButton(
                        minWidth: _isLoading ? 50.0 : 160.0,
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
                              signInRegisteredUser();
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
                                'Login',
                                style: TextStyle(
                                  color: AppColor.white,
                                ),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        )
                      },
                      child: const Text(
                        'Forgot Password ?',
                        style: TextStyle(fontSize: 14.0, color: Colors.blue),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have account? ",
                            style: TextStyle(color: AppColor.black)),
                        TextButton(
                            onPressed: () => {
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide'),
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen(),
                                    ),
                                  )
                                },
                            child: const Text('Register'))
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isGoogleSignIn = true;
                        });
                        final provider = Provider.of<GoogleSignInProvider>(
                            context,
                            listen: false);
                        await provider.googleLogIn();
                        await storage.write(key: 'uid', value: 'abc...xyz');
                        await storage.write(key: 'signInWith', value: 'GOOGLE');

                        await Fluttertoast.showToast(
                          msg: 'User Login Successfully', // message
                          toastLength: Toast.LENGTH_SHORT, // length
                          gravity: ToastGravity.BOTTOM, // location
                          backgroundColor: Colors.green,
                        );

                        setState(() {
                          _isGoogleSignIn = true;
                        });

                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StepByStep(),
                            ),
                            (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppColor.white,
                        onPrimary: AppColor.black,
                        minimumSize: const Size(200, 50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/google-logo.png', height: 30.0),
                          const SizedBox(
                            width: 5.0,
                          ),
                          const Text('SignIn with Google'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  signInRegisteredUser() async {
    try {
      _isLoading = true;
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
//______________________________________________________________________//
      log('user credential email : ${userCredential.user?.email}');
      await storage.write(key: 'uid', value: userCredential.user?.uid);
      await storage.write(
          key: 'signInWith',
          value:
              'OTHER'); //______________________________________________________________________//
      Fluttertoast.showToast(
        msg: 'User Login Successfully', // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.BOTTOM, // location
        backgroundColor: Colors.green,
      );
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const StepByStep(),
          ),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'user-not-found') {
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        );
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
