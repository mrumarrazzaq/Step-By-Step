import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/screens/security_section/registeration_screen2.dart';
import 'package:stepbystep/screens/security_section/signIn_screen2.dert.dart';

import 'signIn_screen.dart';
import 'registration_screen.dart';
import 'package:stepbystep/colors.dart';

class ForgotPassword extends StatefulWidget {
  static const String id = 'ForgotPassword';
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  var email = "";
  bool _isLoading = false;

  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("ForgotPassword Build Run");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: '', // default text style
            children: <TextSpan>[
              TextSpan(
                text: 'Forget Password',
                style: GoogleFonts.kanit(),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              infoDialog();
            },
            splashRadius: 25,
            icon: const Icon(Icons.help_outline_sharp),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  cursorColor: AppColor.black,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    isDense: true,
                    enabled: _isLoading ? false : true,
//                          labelText: 'Email',
                    prefixText: '  ',
                    // label:
                    //     Text('Email', style: TextStyle(color: AppColor.black),),
                    hintText: 'Enter email address',
                    // labelStyle: const TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.5),
                    ),
                    errorStyle: TextStyle(color: AppColor.red, fontSize: 15),
                  ),
                  controller: emailController,
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Please enter email'),
                    EmailValidator(errorText: 'Please enter valid email'),
                  ]),
                ),
              ),
              Material(
                color: AppColor.orange,
                borderRadius: BorderRadius.circular(10.0),
                clipBehavior: Clip.antiAlias,
                child: MaterialButton(
                  minWidth: double.infinity,
                  elevation: 3.0,
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  onPressed: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        email = emailController.text.trim();
                      });
                      resetPassword();
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
                          'Send Email',
                          style: TextStyle(
                            color: AppColor.white,
                          ),
                        ),
                ),
              ),
              // Column(
              //   children: [
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         const Text("Don't have Account? "),
              //         TextButton(
              //           onPressed: () => {
              //             Navigator.pushAndRemoveUntil(
              //                 context,
              //                 PageRouteBuilder(
              //                   pageBuilder: (context, a, b) =>
              //                       const RegistrationScreen2(),
              //                   transitionDuration: const Duration(seconds: 1),
              //                 ),
              //                 (route) => false)
              //           },
              //           child: const Text('Register'),
              //         )
              //       ],
              //     ),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         const Text("Already have an account? "),
              //         TextButton(
              //           onPressed: () => {
              //             Navigator.pushAndRemoveUntil(
              //                 context,
              //                 PageRouteBuilder(
              //                   pageBuilder: (context, a, b) =>
              //                       const SignInScreen2(),
              //                   transitionDuration: const Duration(seconds: 1),
              //                 ),
              //                 (route) => false)
              //           },
              //           child: const Text('Sign in'),
              //         )
              //       ],
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  resetPassword() async {
    try {
      _isLoading = true;
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      await Fluttertoast.showToast(
        msg: 'Email has been sent for Reset Password', // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.BOTTOM, // location
        backgroundColor: AppColor.green,
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColor.red,
            content: const Text(
              'No user found at this email.',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  infoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        alignment: Alignment.center,
        title: Center(
          child: Text(
            'Password Recovery',
            style: GoogleFonts.kanit(),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A Link will be sent to your registered email address. So by clicking that link you have to option to recover your password',
              textAlign: TextAlign.center,
              style: GoogleFonts.titilliumWeb(),
            ),
            const SizedBox(height: 12.0),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              height: 40,
              minWidth: 100,
              color: AppColor.orange,
              child: Text(
                'Dismiss',
                style: TextStyle(color: AppColor.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
