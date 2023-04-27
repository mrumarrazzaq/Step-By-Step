// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/dataset/roles_dataset.dart';
import 'package:stepbystep/widgets/app_elevated_button.dart';
import 'package:stepbystep/widgets/app_progress_indicator.dart';

class RoleSelector extends StatefulWidget {
  final String workspaceCode;
  String workspaceType;
  RoleSelector(
      {Key? key, required this.workspaceCode, required this.workspaceType})
      : super(key: key);

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int roleLevel = 1;
  Color roleColor = Colors.white;
  bool createRoleLoading = false;
  final roleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<Color> colorList = [
    Colors.white,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    const Color(0xffff0000),
    Colors.deepOrange,
    Colors.pink,
    Colors.orange,
    Colors.yellow,
    Colors.purple,
    Colors.purpleAccent,
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lime,
    Colors.lightGreen,
  ];
  late String hexColorCode;

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

  late dynamic roles;

  @override
  void initState() {
    super.initState();
    roles = json.decode(jsonRoles)[widget.workspaceType];
    dropdownValue = widget.workspaceType;
    hexColorCode = '0x${roleColor.value.toRadixString(16)}';
  }

  String search = '';

  @override
  Widget build(BuildContext context) {
    roles = json.decode(jsonRoles)[widget.workspaceType];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.workspaceType} Roles',
          style: GoogleFonts.kanit(
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size(200, 100),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 25.0, right: 25.0, bottom: 10.0, top: 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace Type',
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                  isDense: true,
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                      widget.workspaceType = dropdownValue;
                    });
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                right: 25.0,
                bottom: 20.0,
                top: 10.0,
              ),
              child: TextFormField(
                onChanged: (v) {
                  setState(() {
                    search = v;
                  });
                },
                keyboardType: TextInputType.text,
                cursorColor: AppColor.black,
                style: TextStyle(color: AppColor.black),
                decoration: InputDecoration(
                  isDense: true,
                  // fillColor: tealColor,
                  // filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: AppColor.black, width: 1.5),
                  ),

                  hintText: 'Search Role',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.black,
                  ),
                  prefixText: '  ',
                ),
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: roles.length,
              itemBuilder: (BuildContext context, int index) {
                final role = roles[index];

                return role['title'].toLowerCase().contains(search)
                    ? ListTile(
                        title: Text(
                          role['title'],
                          style: GoogleFonts.kanit(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Text(
                          role['description'],
                          style: GoogleFonts.titilliumWeb(fontSize: 15),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          roleController.text = role['title'];
                          descriptionController.text = role['description'];
                          createRoleDialog();
                        },
                      )
                    : Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  void createRoleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColor.white),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Define Role',
                        style: TextStyle(
                            color: AppColor.darkGrey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Role Name',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  cursorColor: AppColor.black,
                                  maxLength: 30,
                                  style: TextStyle(color: AppColor.black),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: AppColor.black, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: AppColor.grey, width: 1.0),
                                    ),
                                    hintText: 'Chief executive officer',
                                  ),
                                  controller: roleController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter task title';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Role Description',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  cursorColor: AppColor.black,
                                  maxLength: 300,
                                  style: TextStyle(color: AppColor.black),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: AppColor.black, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: AppColor.grey, width: 1.0),
                                    ),
                                    hintText: 'Description [Optional]',
                                  ),
                                  controller: descriptionController,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Role Level',
                            style: GoogleFonts.robotoMono(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          NumberPicker(
                            value: roleLevel,
                            minValue: 1,
                            maxValue: 10,
                            axis: Axis.horizontal,
                            itemCount: 3,
                            itemWidth: 50,
                            itemHeight: 30,
                            onChanged: (value) =>
                                setState(() => roleLevel = value),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: Text(
                          'Select Role Color',
                          style: TextStyle(color: AppColor.black),
                        ),
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: BlockPicker(
                              pickerColor: roleColor,
                              onColorChanged: (color) {
                                hexColorCode =
                                    '0x${color.value.toRadixString(16)}';
                                log(hexColorCode);
                              },
                              availableColors: colorList,
                              useInShowDialog: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      createRoleLoading
                          ? const AppProgressIndicator(
                              radius: 25,
                              size: 30,
                            )
                          : AppElevatedButton(
                              text: 'Create',
                              width: 100,
                              fontSize: 12,
                              textColor: AppColor.white,
                              backgroundColor: AppColor.orange,
                              function: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    createRoleLoading = true;
                                  });
                                  final roleJson = {
                                    'Role': roleController.text.trim(),
                                    'Role Description':
                                        descriptionController.text.isEmpty
                                            ? ''
                                            : descriptionController.text.trim(),
                                    'Role Level': roleLevel,
                                    'Role Color': hexColorCode,
                                    'Control': false,
                                    'Team Control': false,
                                    'Member Control': false,
                                    'Add Member': false,
                                    'Remove Member': false,
                                    'Assign Role': false,
                                    'DeAssign Role': false,
                                    'Role Control': false,
                                    'Create Role': false,
                                    'Edit Role': false,
                                    'Delete Role': false,
                                    'Task Control': false,
                                    'View Control': false,
                                    'Report Control': false,
                                    'Assigned By': currentUserEmail,
                                    'Created At': DateTime.now(),
                                  };

                                  // await FireBaseApi
                                  //     .saveDataIntoDoubleCollectionFireStore(
                                  //   mainCollection: 'Workspace Roles',
                                  //   mainDocument: widget.workspaceCode,
                                  //   subCollection: 'Log',
                                  //   subDocument: '${roleController.text} $roleLevel',
                                  //   jsonData: roleJson,
                                  // );

                                  await FireBaseApi.saveDataIntoFireStore(
                                      workspaceCode: widget.workspaceCode,
                                      collection:
                                          '${widget.workspaceCode} Roles',
                                      document:
                                          '${roleController.text} $roleLevel',
                                      jsonData: roleJson);

                                  await addRolesInFirebase();
                                  if (mounted) {
                                    Get.snackbar(
                                      "Role",
                                      "Create successfully",
                                      colorText: Colors.white,
                                      icon: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                    );
                                    roleController.clear();
                                    descriptionController.clear();
                                    Navigator.pop(context);
                                    setState(() {
                                      createRoleLoading = false;
                                    });
                                  }
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> addRolesInFirebase() async {
    await FirebaseFirestore.instance
        .collection('Workspaces')
        .doc(widget.workspaceCode)
        .update({
      'Workspace Roles':
          FieldValue.arrayUnion(['${roleController.text} $roleLevel']),
    });
    log('Role added in Workspaces');

    await FirebaseFirestore.instance
        .collection(widget.workspaceCode)
        .doc('Log')
        .update({
      'Workspace Roles':
          FieldValue.arrayUnion(['${roleController.text} $roleLevel']),
    });
    log('Role added in Workspaces');
  }
}
