import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/widgets/app_elevated_button.dart';
import 'package:stepbystep/widgets/app_toast.dart';

class CreateWorkspace extends StatefulWidget {
  CreateWorkspace({Key? key, required this.ownedWorkspaces}) : super(key: key);
  List<dynamic> ownedWorkspaces = [];
  @override
  State<CreateWorkspace> createState() => _CreateWorkspaceState();
}

class _CreateWorkspaceState extends State<CreateWorkspace> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> workspaceTypes = <String>[
    'School', //D
    'University', //D
    'Software House', //D
    'Government Organization', //D
    'Private Organization', //
    'Multinational Organization', //D
    'Local Organization', //D
    'Other' //
  ];
  String dropdownValue = '';
  late FToast fToast;
  final workspaceNameController = TextEditingController();

  String userName = '';
  String userEmail = '';
  bool inProgress = false;
  fetchData() async {
    log('Data is fetching from Firestore');
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(user!.email)
          .get()
          .then((ds) {
        userName = ds['User Name'];
        userEmail = ds['User Email'];
        setState(() {});
        log(userName);
        log(userEmail);
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    dropdownValue = workspaceTypes.first;
    fetchData();
    log(widget.ownedWorkspaces.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create Workspace',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.darkGrey,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/building.png', height: 180),
              Padding(
                padding: const EdgeInsets.only(
                    left: 25.0, right: 25.0, bottom: 20.0, top: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspace Name',
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        cursorColor: AppColor.black,
                        style: TextStyle(color: AppColor.black),
                        autofillHints: const [AutofillHints.email],
                        maxLength: 50,
                        decoration: InputDecoration(
                          isDense: true,
                          // fillColor: tealColor,
                          // filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                BorderSide(color: AppColor.black, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                BorderSide(color: AppColor.grey, width: 1.0),
                          ),

                          hintText: 'Software Solutions',
                        ),
                        controller: workspaceNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter workspace name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 25.0, right: 25.0, bottom: 20.0, top: 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspace Type',
                      style: GoogleFonts.robotoMono(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField(
                      items: workspaceTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: dropdownValue,
                      onChanged: (String? value) {
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: AppColor.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: AppColor.grey, width: 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              inProgress
                  ? CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColor.black,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColor.white,
                          backgroundColor: AppColor.orange,
                        ),
                      ),
                    )
                  : AppElevatedButton(
                      function: () async {
                        if (_formKey.currentState!.validate()) {
                          bool isOwned = widget.ownedWorkspaces.contains(
                              '$userEmail ${workspaceNameController.text}');
                          if (!isOwned) {
                            setState(() {
                              inProgress = true;
                            });
                            final jsonLog = {
                              'Workspace Name': workspaceNameController.text,
                              'Workspace Type': dropdownValue,
                              'Workspace Owner Name': userName,
                              'Workspace Owner Email': userEmail,
                              'Workspace Members': [],
                              'Workspace Roles': [],
                              'Workspace Code':
                                  '$userEmail ${workspaceNameController.text}',
                              'Created At': DateTime.now(),
                            };

                            await FireBaseApi.saveDataIntoFireStore(
                              workspaceCode:
                                  '$userEmail ${workspaceNameController.text}',
                              collection:
                                  '$userEmail ${workspaceNameController.text}',
                              document: 'Log',
                              jsonData: jsonLog,
                            );

                            await FireBaseApi.saveDataIntoFireStore(
                              workspaceCode:
                                  '$userEmail ${workspaceNameController.text}',
                              collection: 'Workspaces',
                              document:
                                  '$userEmail ${workspaceNameController.text}',
                              jsonData: jsonLog,
                            );

                            await updateUserDateOwnedWorkspaces(
                              email: userEmail,
                              workspaceCode:
                                  '$userEmail ${workspaceNameController.text}',
                            );

                            await FirebaseFirestore.instance
                                .collection('User Data')
                                .doc(currentUserEmail)
                                .collection('Workspace Roles')
                                .doc(
                                    '$userEmail ${workspaceNameController.text}')
                                .set({
                              'Role': 'Owner',
                              'Level': 0,
                              'Created At': DateTime.now(),
                            });
                            if (mounted) {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              Fluttertoast.showToast(
                                msg: 'Workspace create successfully', // message
                                toastLength: Toast.LENGTH_SHORT, // length
                                gravity: ToastGravity.BOTTOM, // location
                                backgroundColor: Colors.green,
                              );
                              setState(() {
                                inProgress = false;
                              });
                              Navigator.pop(context, true);
                            }
                          } else {
                            /* BotToast.showAttachedWidget(
                        attachedBuilder: (_) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 80.0),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColor.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Workspace Already in your use',
                                style: TextStyle(color: AppColor.white),
                              ),
                            ],
                          ),
                        ),
                        preferDirection: PreferDirection.bottomCenter,
                        verticalOffset:
                            MediaQuery.of(context).size.height - 110,
                        duration: const Duration(seconds: 3),
                        target: const Offset(520, 520),
                      );
                      // cancel();*/
                            Fluttertoast.showToast(
                              msg: 'Workspace Already in your use', // message
                              toastLength: Toast.LENGTH_SHORT, // length
                              gravity: ToastGravity.BOTTOM, // location
                              backgroundColor: Colors.black,
                            );
                            setState(() {
                              inProgress = false;
                            });
                            Navigator.pop(context, false);
                          }
                        }
                      },
                      isLoading: inProgress,
                      textColor: AppColor.white,
                      text: 'Create Workspace',
                      backgroundColor: AppColor.black,
                      height: 45,
                      width: 160,
                      fontSize: 15,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  updateUserDateOwnedWorkspaces(
      {required String email, required String workspaceCode}) async {
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(email)
          .update({
        'Owned Workspaces': FieldValue.arrayUnion([workspaceCode]),
      });
      log('Workspace is added in User Data');
    } catch (e) {
      log(e.toString());
    }
  }
}
