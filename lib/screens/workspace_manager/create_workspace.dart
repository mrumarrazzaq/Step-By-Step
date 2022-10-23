import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';

class CreateWorkspace extends StatefulWidget {
  const CreateWorkspace({Key? key}) : super(key: key);

  @override
  State<CreateWorkspace> createState() => _CreateWorkspaceState();
}

class _CreateWorkspaceState extends State<CreateWorkspace> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> workspaceTypes = <String>[
    'School',
    'University',
    'Software House',
    'Government Organization',
    'Private Organization',
    'Multinational Organization',
    'Local Organization',
    'Other'
  ];
  String dropdownValue = '';
  final workspaceNameController = TextEditingController();

  String userName = '';
  String userEmail = '';

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
    dropdownValue = workspaceTypes.first;
    fetchData();

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
              Material(
                color: AppColor.black,
                borderRadius: BorderRadius.circular(30.0),
                clipBehavior: Clip.antiAlias,
                child: MaterialButton(
                  minWidth: 160.0,
                  elevation: 3.0,
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  onPressed: () async {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');

                    if (_formKey.currentState!.validate()) {
                      final jsonLog = {
                        'Workspace Name': workspaceNameController.text,
                        'Workspace Type': dropdownValue,
                        'Workspace Owner Name': userName,
                        'Workspace Owner Email': userEmail,
                        'Workspace Members': [],
                        'Workspace Code':
                            '$userEmail ${workspaceNameController.text}',
                        'Created At': DateTime.now(),
                      };
                      await FireBaseApi.saveDataIntoFireStore(
                        collection:
                            '$userEmail ${workspaceNameController.text}',
                        document: 'Log',
                        jsonData: jsonLog,
                      );

                      await FireBaseApi.createCollectionAutoDoc(
                        collection: 'Workspaces',
                        jsonData: jsonLog,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(
                    'Create Workspace',
                    style: TextStyle(
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
