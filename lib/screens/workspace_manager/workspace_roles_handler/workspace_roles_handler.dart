import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stepbystep/ads/ad_mob_service.dart';
import 'package:stepbystep/apis/app_functions.dart';

import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/apis/get_apis.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_roles_handler/role_selector.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_roles_handler/workspace_role_card.dart';

import 'package:stepbystep/widgets/app_elevated_button.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stepbystep/widgets/app_progress_indicator.dart';

class WorkspaceRolesHandler extends StatefulWidget {
  WorkspaceRolesHandler({
    Key? key,
    required this.workspaceCode,
    required this.docId,
    required this.workspaceName,
    required this.controlForUser,
    required this.controlForOwner,
    required this.control,
    required this.createRole,
    required this.editRole,
    required this.deleteRole,
    required this.fromTaskAssignment,
    required this.fromTaskHolder,
  }) : super(key: key);
  String workspaceCode;
  String docId;
  String workspaceName;
  bool controlForUser;
  bool controlForOwner;
  bool control;
  bool createRole;
  bool editRole;
  bool deleteRole;
  bool fromTaskAssignment;
  bool fromTaskHolder;
  @override
  State<WorkspaceRolesHandler> createState() => _WorkspaceRolesHandlerState();
}

class _WorkspaceRolesHandlerState extends State<WorkspaceRolesHandler> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  InterstitialAd? _interstitialAd;

  int roleLevel = 1;
  final roleController = TextEditingController();
  final descriptionController = TextEditingController();
  late final Stream<QuerySnapshot> rolesRecords;
  bool createRoleLoading = false;
  bool createRoleForDecision = false;
  Color roleColor = Colors.white;
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
  Future<void> getSpecificRoleData() async {
    try {
      String assignedRole = await AppFunctions.getRoleByEmail(
          email: currentUserEmail.toString(),
          workspaceCode: widget.workspaceCode);
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Roles')
          .doc(assignedRole)
          .get()
          .then((ds) {
        createRoleForDecision = ds['Create Role'];
      });
      setState(() {});
    } catch (e) {
      log('Failed to get edit role and delete role.');
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          _interstitialAd = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  void initState() {
    hexColorCode = '0x${roleColor.value.toRadixString(16)}';
    log('fromTaskHolder ${widget.fromTaskHolder}');
    log('fromTaskAssignment ${widget.fromTaskAssignment}');
    rolesRecords = FirebaseFirestore.instance
        .collection('${widget.workspaceCode} Roles')
        .orderBy('Role Level', descending: false)
        .snapshots();
    // if (!widget.controlForOwner) {
    //   getSpecificRoleData();
    // }
    _loadInterstitialAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: widget.createRole && !widget.fromTaskAssignment,
          child: MaterialButton(
            onPressed: () async {
              bool isTrue = await GetApi.isPaidAccount();
              if (!isTrue) {
                _showInterstitialAd();
              }
              String workspaceType = await AppFunctions.getWorkspaceType(
                  workspaceCode: widget.workspaceCode);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoleSelector(
                      workspaceCode: widget.workspaceCode,
                      workspaceType: workspaceType,
                    ),
                  ),
                );
              }
            },
            height: 40,
            minWidth: double.infinity,
            color: AppColor.orange,
            textColor: AppColor.white,
            elevation: 0.0,
            child: Text(
              'Get role from template',
              style: GoogleFonts.titilliumWeb(fontSize: 15),
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: rolesRecords,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              log('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: AppColor.orange,
                strokeWidth: 2.0,
              ));
            }
            if (snapshot.hasData) {
              List storedRolesData = [];

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map id = document.data() as Map<String, dynamic>;
                storedRolesData.add(id);
                id['id'] = document.id;
              }).toList();
              return Column(
                children: [
                  for (int i = 0; i < storedRolesData.length; i++) ...[
                    /**/
                    if (widget.controlForOwner &&
                        widget.fromTaskAssignment) ...[
                      if (storedRolesData[i]['Assigned By'] !=
                          currentUserEmail) ...[
                        WorkspaceRoleCard(
                          id: storedRolesData[i]['id'],
                          workspaceCode: widget.workspaceCode,
                          roleName: storedRolesData[i]['Role'],
                          roleDescription: storedRolesData[i]
                              ['Role Description'],
                          roleLevel:
                              storedRolesData[i]['Role Level'].toString(),
                          roleColor: storedRolesData[i]['Role Color'],
                          teamControl: storedRolesData[i]['Team Control'],
                          memberControl: storedRolesData[i]['Member Control'],
                          controlForOwner: widget.controlForOwner,
                          control: storedRolesData[i]['Control'],
                          roleControl: storedRolesData[i]['Role Control'],
                          taskControl: storedRolesData[i]['Task Control'],
                          viewControl: storedRolesData[i]['View Control'],
                          reportControl: storedRolesData[i]['Report Control'],
                          addMember: storedRolesData[i]['Add Member'],
                          removeMember: storedRolesData[i]['Remove Member'],
                          assignRole: storedRolesData[i]['Assign Role'],
                          deAssignRole: storedRolesData[i]['DeAssign Role'],
                          createRole: storedRolesData[i]['Create Role'],
                          editRole: storedRolesData[i]['Edit Role'],
                          deleteRole: storedRolesData[i]['Delete Role'],
                        ),
                      ],
                    ] else if (widget.controlForOwner &&
                        widget.fromTaskAssignment) ...[
                      WorkspaceRoleCard(
                        id: storedRolesData[i]['id'],
                        workspaceCode: widget.workspaceCode,
                        roleName: storedRolesData[i]['Role'],
                        roleDescription: storedRolesData[i]['Role Description'],
                        roleLevel: storedRolesData[i]['Role Level'].toString(),
                        roleColor: storedRolesData[i]['Role Color'],
                        teamControl: storedRolesData[i]['Team Control'],
                        memberControl: storedRolesData[i]['Member Control'],
                        controlForOwner: widget.controlForOwner,
                        control: storedRolesData[i]['Control'],
                        roleControl: storedRolesData[i]['Role Control'],
                        taskControl: storedRolesData[i]['Task Control'],
                        viewControl: storedRolesData[i]['View Control'],
                        reportControl: storedRolesData[i]['Report Control'],
                        addMember: storedRolesData[i]['Add Member'],
                        removeMember: storedRolesData[i]['Remove Member'],
                        assignRole: storedRolesData[i]['Assign Role'],
                        deAssignRole: storedRolesData[i]['DeAssign Role'],
                        createRole: storedRolesData[i]['Create Role'],
                        editRole: storedRolesData[i]['Edit Role'],
                        deleteRole: storedRolesData[i]['Delete Role'],
                      ),
                    ] else ...[
                      WorkspaceRoleCard(
                        id: storedRolesData[i]['id'],
                        workspaceCode: widget.workspaceCode,
                        roleName: storedRolesData[i]['Role'],
                        roleDescription: storedRolesData[i]['Role Description'],
                        roleLevel: storedRolesData[i]['Role Level'].toString(),
                        roleColor: storedRolesData[i]['Role Color'],
                        teamControl: storedRolesData[i]['Team Control'],
                        memberControl: storedRolesData[i]['Member Control'],
                        controlForOwner: widget.controlForOwner,
                        control: storedRolesData[i]['Control'],
                        roleControl: storedRolesData[i]['Role Control'],
                        taskControl: storedRolesData[i]['Task Control'],
                        viewControl: storedRolesData[i]['View Control'],
                        reportControl: storedRolesData[i]['Report Control'],
                        addMember: storedRolesData[i]['Add Member'],
                        removeMember: storedRolesData[i]['Remove Member'],
                        assignRole: storedRolesData[i]['Assign Role'],
                        deAssignRole: storedRolesData[i]['DeAssign Role'],
                        createRole: storedRolesData[i]['Create Role'],
                        editRole: storedRolesData[i]['Edit Role'],
                        deleteRole: storedRolesData[i]['Delete Role'],
                      ),
                    ],
                  ],
                ],
              );
            }
            return Center(
                child: CircularProgressIndicator(
              color: AppColor.orange,
              strokeWidth: 2.0,
            ));
          },
        ),
        Visibility(
          // createRoleForDecision || !widget.fromTaskAssignment
          visible: widget.createRole && !widget.fromTaskAssignment,
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: AppElevatedButton(
              text: 'Create Role',
              fontSize: 12,
              backgroundColor: AppColor.orange,
              foregroundColor: AppColor.orange,
              textColor: AppColor.white,
              function: () {
                createRoleDialog();
              },
            ),
          ),
        ),
      ],
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
                                print(hexColorCode);
                              },
                              availableColors: colorList,
                              useInShowDialog: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      createRoleLoading
                          ? AppProgressIndicator(
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
