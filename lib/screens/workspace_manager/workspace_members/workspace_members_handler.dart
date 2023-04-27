import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/ads/ad_mob_service.dart';
import 'package:stepbystep/apis/app_functions.dart';
import 'package:stepbystep/apis/collection_history.dart';

import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/apis/get_apis.dart';
import 'package:stepbystep/apis/messege_notification_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/Task%20Assignment%20Section/task_assignment.dart';
import 'package:stepbystep/visualization/visualization.dart';
import 'package:stepbystep/widgets/app_divider.dart';

class WorkspaceMembersHandler extends StatefulWidget {
  final String docId;
  final String workspaceCode;
  final String workspaceName;
  final String workspaceOwnerEmail;
  final bool assignTaskControl;
  final bool reportControl;
  final bool addMember;
  final bool removeMember;
  final bool assignRole;
  final bool deAssignRole;
  final bool fromTaskAssignment;
  final bool fromTaskHolder;
  final String extraEmail;
  const WorkspaceMembersHandler({
    Key? key,
    required this.workspaceCode,
    required this.docId,
    required this.workspaceName,
    required this.workspaceOwnerEmail,
    required this.assignTaskControl,
    required this.reportControl,
    required this.addMember,
    required this.removeMember,
    required this.assignRole,
    required this.deAssignRole,
    required this.fromTaskAssignment,
    required this.fromTaskHolder,
    this.extraEmail = '',
  }) : super(key: key);

  @override
  State<WorkspaceMembersHandler> createState() =>
      _WorkspaceMembersHandlerState();
}

class _WorkspaceMembersHandlerState extends State<WorkspaceMembersHandler>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  InterstitialAd? _interstitialAd;

  bool memberAddingWait = false;
  bool memberRemovingWait = false;
  String searchValue = '';
  String userName = '';
  final searchController = TextEditingController();
  List<dynamic> membersList = [];
  List<dynamic> rolesList = [];
  String selectedRoleValue = 'Assign Role';
  bool toggle = true;
  String assignedBy = '';
  List<String> assignedByList = [];
  List<String> assignedRoleList = [];
  List<String> roleColors = [];
  List<dynamic> specificMembersList = [];
  String assignedRole = 'No Role Assign';
  bool tA = false, tH = false;
  int selected = -1;
  bool wait = true;

  String filter = 'Filter By Role';
  String roleFilterValue = '';

  final Stream<QuerySnapshot> userRecords = FirebaseFirestore.instance
      .collection('User Data')
      // .orderBy('Created At', descending: true)
      .snapshots();
  final Stream<QuerySnapshot> workspaces = FirebaseFirestore.instance
      .collection('Workspaces')
      // .orderBy('Created At', descending: true)
      .snapshots();

  late final Stream<QuerySnapshot> members;

  getAddedMembers({required bool tH, required bool tA}) async {
    try {
      setState(() {
        wait = true;
      });
      if (widget.fromTaskHolder || tH) {
        log('From Task Holder');
        final value = await FirebaseFirestore.instance
            .collection('$currentUserEmail ${widget.workspaceCode} Team')
            .doc(widget.docId)
            .get();
        setState(() {
          membersList = value.data()!['Workspace Members'];
        });
        for (var member in membersList) {
          await getAssignedRole(member);
        }
      } else if (widget.fromTaskAssignment || tA) {
        log('From Task Assignment');
        final value = await FirebaseFirestore.instance
            .collection('${widget.extraEmail} ${widget.workspaceCode} Team')
            .doc(widget.docId)
            .get();

        setState(() {
          membersList = value.data()!['Workspace Members'];
        });
        // for (var member in membersList) {
        //   await getAssignedRole(member);
        // }
      } else {
        log('From Home Screen');
        final value = await FirebaseFirestore.instance
            .collection("Workspaces")
            .doc(widget.docId)
            .get();

        setState(() {
          membersList = value.data()!['Workspace Members'];
        });
        // for (var member in membersList) {
        //   log(member);
        //   await getAssignedRole(member);
        // }
      }
      log(membersList.toString());
      setState(() {
        wait = false;
      });
    } catch (e) {
      setState(() {
        wait = false;
      });
      log(e.toString());
    }
  }

  getAddedRoles() async {
    try {
      final value = await FirebaseFirestore.instance
          .collection("Workspaces")
          .doc(widget.docId)
          .get();

      setState(() {
        rolesList = value.data()!['Workspace Roles'];
      });
      log(rolesList.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  getRolesColor(String id) async {
    try {
      final value = await FirebaseFirestore.instance
          .collection("${widget.workspaceCode} Roles")
          .doc(id)
          .get()
          .then((value) {
        roleColors.add(value['Role Color']);
      });

      setState(() {});
      log(roleColors.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  getUserData(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection("User Data")
          .doc(docId)
          .get()
          .then((ds) {
        userName = ds['User Name'];
      });
      setState(() {
        //log(userName);
      });
    } catch (e) {
      log(e.toString());
    }
  }

  getAssignedRole(String email) async {
    try {
      log('Getting Assigned Roles................');
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Assigned Roles')
          .doc(email)
          .get()
          .then((ds) {
        assignedByList.add(ds['Assigned By']);
        assignedRoleList.add(ds['Assigned Role']);
        getRolesColor(ds['Assigned Role']);
      });
      setState(() {
        log(email);
        log(assignedRoleList.toString());
      });
    } catch (e) {
      //save index mode
      for (int i = 0; i < 100; i++) {
        assignedByList.add('');
        assignedRoleList.add('No Role Assign');
      }
      log(e.toString());
    }
  }

  getSpecificTeam(String email) async {
    try {
      final value = await FirebaseFirestore.instance
          .collection('$email ${widget.workspaceCode} Team')
          .doc(widget.workspaceCode)
          .get();

      setState(() {
        specificMembersList = value.data()!['Workspace Members'];
      });
      log(specificMembersList.toString());
    } catch (e) {
      log(e.toString());
      log('ERROR IN FETCH SPECIFIC MEMBERS LIST');
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
    log('WORKSPACE MEMBER HANDLER INIT CALLED');
    if (widget.fromTaskAssignment && !widget.fromTaskHolder) {
      log('FROM TASK ASSIGNMENT');
      getSpecificTeam(widget.extraEmail);
    } else {
      log('FROM TASK HOLDER');
      getSpecificTeam(currentUserEmail.toString());
    }
    setValues();
    getAddedMembers(tH: tH, tA: tA);
    getAddedRoles();

    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController.forward();
    members = FirebaseFirestore.instance
        .collection('${widget.workspaceCode} Members')
        .orderBy('Created At', descending: true)
        .snapshots();

    _loadInterstitialAd();
  }

  setValues() {
    setState(() {
      tA = widget.fromTaskAssignment;
      tH = widget.fromTaskHolder;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('WORKSPACE MEMBER HANDLER BUILD CALLED');
    return Column(
      children: [
        //Search Bar
        Visibility(
          visible: !widget.fromTaskAssignment && widget.addMember,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search User',
                  style: GoogleFonts.robotoMono(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: AppColor.black,
                  style: TextStyle(color: AppColor.black),
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      borderSide: BorderSide(color: AppColor.black, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      borderSide: BorderSide(color: AppColor.grey, width: 1.0),
                    ),
                    hintText: 'Search by email id',
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          searchController.clear();
                          searchValue = '';
                          toggle = !toggle;
                          if (toggle) {
                            _animationController.reverse();
                          } else {
                            _animationController.forward();
                          }
                        });
                      },
                      child: Lottie.asset(
                          controller: _animationController,
                          repeat: false,
                          'animations/search.json'),
                    ),
                    // suffixIcon: MaterialButton(
                    //   onPressed: () {
                    //     setState(() {
                    //       searchController.text;
                    //     });
                    //   },
                    //   textColor: AppColor.white,
                    //   color: AppColor.black,
                    //   height: 50,
                    //   child: const Icon(Icons.search, size: 30),
                    // ),
                  ),
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchValue = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter workspace name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: userRecords,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              log('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            if (snapshot.hasData) {
              List storedUserData = [];

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map id = document.data() as Map<String, dynamic>;
                storedUserData.add(id);
                id['id'] = document.id;
              }).toList();
              return Column(
                children: [
                  for (int i = 0; i < storedUserData.length; i++) ...[
                    if (searchValue == storedUserData[i]['User Email'] &&
                        storedUserData[i]['User Email'] != currentUserEmail &&
                        storedUserData[i]['User Email'] !=
                            widget.workspaceOwnerEmail &&
                        storedUserData[i]['Verify Account'] == true) ...[
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            backgroundColor: AppColor.orange,
                            radius: 30,
                            foregroundImage: storedUserData[i]['Image URL']
                                    .isEmpty
                                ? null
                                : NetworkImage(storedUserData[i]['Image URL']),
                            child: Center(
                              child: Text(
                                storedUserData[i]['User Name'][0],
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColor.white),
                              ),
                            ),
                          ),
                          title: Text(storedUserData[i]['User Name']),
                          subtitle: Text(storedUserData[i]['User Email']),
                          trailing: Visibility(
                            visible: widget.addMember,
                            child: memberAddingWait || memberRemovingWait
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColor.orange,
                                      strokeWidth: 1,
                                    ),
                                  )
                                : MaterialButton(
                                    onPressed: () async {
                                      if (!membersList.contains(searchValue)) {
                                        log('add members in workspace');
                                        setState(() {
                                          memberAddingWait = true;
                                        });
                                        await addMemberInWorkspaces(
                                            memberEmail: storedUserData[i]
                                                ['User Email']);
                                        await getAddedMembers(tH: tH, tA: tA);
                                        setState(() {
                                          memberAddingWait = false;
                                        });
                                      } else if (membersList
                                          .contains(searchValue)) {
                                        if (widget.removeMember) {
                                          log('remove members in workspace');
                                          setState(() {
                                            memberRemovingWait = true;
                                          });
                                          await removeMemberFromWorkspaces(
                                              memberEmail: storedUserData[i]
                                                  ['User Email']);
                                          await getAddedMembers(tH: tH, tA: tA);
                                          setState(() {
                                            memberRemovingWait = false;
                                          });
                                        }
                                      }
                                    },
                                    // textColor: AppColor.white,
                                    // color:
                                    //     membersList.contains(searchController.text)
                                    //         ? AppColor.black
                                    //         : AppColor.orange,
                                    child: membersList
                                            .contains(searchController.text)
                                        ? Lottie.asset(
                                            'animations/remove_member.json')

                                        // const Text('Added')
                                        : Lottie.asset(
                                            'animations/add_member.json'),
                                    // const Text('Add'),
                                  ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ],
              );
            }
            return Center(
              child: CircularProgressIndicator(
                color: AppColor.orange,
                strokeWidth: 1.0,
              ),
            );
          },
        ),
        AppDivider(text: 'Workspace Members', color: AppColor.black),
        ExpansionTile(
          title: Row(
            children: [
              Text(
                roleFilterValue.isEmpty ? 'Filter By Role' : roleFilterValue,
              ),
              Visibility(
                visible: roleFilterValue.isNotEmpty,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      roleFilterValue = '';
                    });
                  },
                  iconSize: 18,
                  splashRadius: 15,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.filter_alt_outlined),
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  roleFilterValue = 'No Role Assign';
                });
              },
              title: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Filter with '),
                    TextSpan(
                      text: ' No Role Assign',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DropdownButton<dynamic>(
                hint: const Text('Select Role'),
                isDense: true,
                items:
                    rolesList.map<DropdownMenuItem<dynamic>>((dynamic value) {
                  return DropdownMenuItem<dynamic>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: selectedRoleValue.isEmpty ? assignedRoleList : null,
                onChanged: (value) async {
                  setState(() {
                    roleFilterValue = value!;
                  });
                },
              ),
            ),
          ],
        ),

        // Display Members
        StreamBuilder<QuerySnapshot>(
          stream: members,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              log('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: CircularProgressIndicator(
                    color: AppColor.orange,
                    strokeWidth: 2.0,
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              List storedMembersData = [];

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map id = document.data() as Map<String, dynamic>;
                storedMembersData.add(id);
                id['id'] = document.id;
              }).toList();
              return Column(
                children: [
                  for (int i = 0; i < storedMembersData.length; i++) ...[
                    if (storedMembersData[i]['Workspace Member'] !=
                            currentUserEmail &&
                        storedMembersData[i]['Workspace Member'] !=
                            widget.extraEmail &&
                        (specificMembersList.contains(
                                storedMembersData[i]['Workspace Member']) ||
                            (!widget.fromTaskAssignment) &&
                                !widget.fromTaskHolder)) ...[
                      if (storedMembersData[i]['Assigned Role'] ==
                          roleFilterValue) ...[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: ClipPath(
                            clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                      color: Color(
                                        int.parse(
                                            storedMembersData[i]['Color Code']),
                                      ),
                                      width: 10),
                                ),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  storedMembersData[i]['Workspace Member'],
                                  style: TextStyle(color: AppColor.black),
                                ),
                                iconColor: AppColor.black,
                                subtitle: Row(
                                  children: [
                                    Lottie.asset(
                                        repeat: false,
                                        'animations/blue-bar.json'),
                                    Lottie.asset(
                                        repeat: false,
                                        'animations/yellow-bar.json'),
                                    Lottie.asset(
                                        repeat: false,
                                        'animations/grey-bar.json'),
                                  ],
                                ),
                                onExpansionChanged: (v) async {
                                  // await getAssignedRole(membersList[i]);
                                },
                                children: [
                                  Lottie.asset(
                                      reverse: true,
                                      repeat: false,
                                      'animations/grey-divider.json'),
                                  //Assign Task
                                  Visibility(
                                    visible: widget.assignTaskControl,
                                    child: ListTile(
                                      onTap: () async {
                                        String userName =
                                            await AppFunctions.getNameByEmail(
                                                email: storedMembersData[i]
                                                    ['Workspace Member']);
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TaskTeamAssignment(
                                                name: userName,
                                                email: storedMembersData[i]
                                                    ['Workspace Member'],
                                                workspaceCode:
                                                    widget.workspaceCode,
                                                docId: widget.docId,
                                                workspaceName:
                                                    widget.workspaceName,
                                                workspaceOwnerEmail:
                                                    widget.workspaceOwnerEmail,
                                                assignedRole:
                                                    storedMembersData[i]
                                                        ['Assigned Role'],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      dense: true,
                                      title: const Text('Assign Task'),
                                      trailing: Lottie.asset(
                                          repeat: false,
                                          height: 40,
                                          'animations/add-to-box.json'),

                                      // Image.asset('assets/right-arrow3.png',
                                      //     height: 30),
                                    ),
                                  ),
                                  //Check Report
                                  Visibility(
                                    visible: widget.reportControl,
                                    child: ListTile(
                                      onTap: () async {
                                        log('CARD NO 1');
                                        bool isTrue =
                                            await GetApi.isPaidAccount();
                                        if (!isTrue) {
                                          _showInterstitialAd();
                                        }
                                        String userName =
                                            await AppFunctions.getNameByEmail(
                                                email: storedMembersData[i]
                                                    ['Workspace Member']);
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Visualization(
                                                workspaceCode:
                                                    widget.workspaceCode,
                                                workspaceName:
                                                    widget.workspaceName,
                                                userEmail: storedMembersData[i]
                                                    ['Workspace Member'],
                                                userName: userName,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      dense: true,
                                      title: const Text('Check Report'),
                                      trailing: Lottie.asset(
                                          repeat: false,
                                          height: 35,
                                          'animations/graph.json'),
                                      // Image.asset('assets/bar-graph.png', height: 30),
                                    ),
                                  ),
                                  ListTile(
                                    dense: true,
                                    title: const Text('Assigned Role'),
                                    subtitle: Text(
                                        'By: ${storedMembersData[i]['Assigned By']}'),
                                    trailing: Text(
                                      storedMembersData[i]['Assigned Role'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // safeDisplay(assignedRoleList[i]),
                                  ),
                                  Lottie.asset(
                                      reverse: true,
                                      repeat: false,
                                      'animations/grey-divider.json'),
                                  ExpansionTile(
                                    title: Text(
                                      'Role For Member',
                                      style: TextStyle(color: AppColor.black),
                                    ),
                                    iconColor: AppColor.black,
                                    children: [
                                      //Assign Role
                                      Visibility(
                                        visible: widget.assignRole,
                                        child: Visibility(
                                          visible: rolesList.isNotEmpty,
                                          child: ListTile(
                                            dense: true,
                                            title: const Text('Assign Role'),
                                            subtitle: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DropdownButton<dynamic>(
                                                  hint: const Text('Roles'),
                                                  isDense: true,
                                                  items: rolesList.map<
                                                          DropdownMenuItem<
                                                              dynamic>>(
                                                      (dynamic value) {
                                                    return DropdownMenuItem<
                                                        dynamic>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  value:
                                                      selectedRoleValue.isEmpty
                                                          ? assignedRoleList
                                                          : null,
                                                  onChanged: (value) async {
                                                    assignedRole = value!;
                                                    selectedRoleValue = value!;

                                                    assignRole(
                                                        storedMembersData[i]
                                                            ['id'],
                                                        storedMembersData[i][
                                                            'Workspace Member'],
                                                        selectedRoleValue);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      //DeAssign Role
                                      Visibility(
                                        visible: widget.deAssignRole,
                                        child: Visibility(
                                          visible: storedMembersData[i]
                                                  ['Assigned Role'] !=
                                              'No Role Assign',
                                          child: ListTile(
                                            onTap: () async {
                                              await deAssignRole(
                                                  storedMembersData[i]['id'],
                                                  storedMembersData[i]
                                                      ['Workspace Member']);
                                            },
                                            dense: true,
                                            title: const Text('De-Assign Role'),
                                            trailing: Lottie.asset(
                                                repeat: false,
                                                height: 30,
                                                'animations/crossbutton.json'),
                                            // const Icon(Icons.close),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else if (roleFilterValue.isEmpty) ...[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: ClipPath(
                            clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                      color: Color(
                                        int.parse(
                                            storedMembersData[i]['Color Code']),
                                      ),
                                      width: 10),
                                ),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  storedMembersData[i]['Workspace Member'],
                                  style: TextStyle(color: AppColor.black),
                                ),
                                iconColor: AppColor.black,
                                subtitle: Row(
                                  children: [
                                    Lottie.asset(
                                        repeat: false,
                                        'animations/blue-bar.json'),
                                    Lottie.asset(
                                        repeat: false,
                                        'animations/yellow-bar.json'),
                                    Lottie.asset(
                                        repeat: false,
                                        'animations/grey-bar.json'),
                                  ],
                                ),
                                onExpansionChanged: (v) async {
                                  // await getAssignedRole(membersList[i]);
                                },
                                children: [
                                  Lottie.asset(
                                      reverse: true,
                                      repeat: false,
                                      'animations/grey-divider.json'),
                                  //Assign Task
                                  Visibility(
                                    visible: widget.assignTaskControl,
                                    child: ListTile(
                                      onTap: () async {
                                        String userName =
                                            await AppFunctions.getNameByEmail(
                                                email: storedMembersData[i]
                                                    ['Workspace Member']);
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TaskTeamAssignment(
                                                name: userName,
                                                email: storedMembersData[i]
                                                    ['Workspace Member'],
                                                workspaceCode:
                                                    widget.workspaceCode,
                                                docId: widget.docId,
                                                workspaceName:
                                                    widget.workspaceName,
                                                workspaceOwnerEmail:
                                                    widget.workspaceOwnerEmail,
                                                assignedRole:
                                                    storedMembersData[i]
                                                        ['Assigned Role'],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      dense: true,
                                      title: const Text('Assign Task'),
                                      trailing: Lottie.asset(
                                          repeat: false,
                                          height: 40,
                                          'animations/add-to-box.json'),

                                      // Image.asset('assets/right-arrow3.png',
                                      //     height: 30),
                                    ),
                                  ),
                                  //Check Report
                                  Visibility(
                                    visible: widget.reportControl,
                                    child: ListTile(
                                      onTap: () async {
                                        log('CARD NO 2');
                                        bool isTrue =
                                            await GetApi.isPaidAccount();
                                        if (!isTrue) {
                                          _showInterstitialAd();
                                        }
                                        String userName =
                                            await AppFunctions.getNameByEmail(
                                                email: storedMembersData[i]
                                                    ['Workspace Member']);
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Visualization(
                                                workspaceCode:
                                                    widget.workspaceCode,
                                                workspaceName:
                                                    widget.workspaceName,
                                                userName: userName,
                                                userEmail: storedMembersData[i]
                                                    ['Workspace Member'],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      dense: true,
                                      title: const Text('Check Report'),
                                      trailing: Lottie.asset(
                                          repeat: false,
                                          height: 35,
                                          'animations/graph.json'),
                                      // Image.asset('assets/bar-graph.png', height: 30),
                                    ),
                                  ),
                                  ListTile(
                                    dense: true,
                                    title: const Text('Assigned Role'),
                                    subtitle: Text(
                                        'By: ${storedMembersData[i]['Assigned By']}'),
                                    trailing: Text(
                                      storedMembersData[i]['Assigned Role'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // safeDisplay(assignedRoleList[i]),
                                  ),
                                  Lottie.asset(
                                      reverse: true,
                                      repeat: false,
                                      'animations/grey-divider.json'),
                                  ExpansionTile(
                                    title: Text(
                                      'Role For Member',
                                      style: TextStyle(color: AppColor.black),
                                    ),
                                    iconColor: AppColor.black,
                                    children: [
                                      //Assign Role
                                      Visibility(
                                        visible: widget.assignRole,
                                        child: Visibility(
                                          visible: rolesList.isNotEmpty,
                                          child: ListTile(
                                            dense: true,
                                            title: const Text('Assign Role'),
                                            subtitle: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DropdownButton<dynamic>(
                                                  hint: const Text('Roles'),
                                                  isDense: true,
                                                  items: rolesList.map<
                                                          DropdownMenuItem<
                                                              dynamic>>(
                                                      (dynamic value) {
                                                    return DropdownMenuItem<
                                                        dynamic>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  value:
                                                      selectedRoleValue.isEmpty
                                                          ? assignedRoleList
                                                          : null,
                                                  onChanged: (value) async {
                                                    assignedRole = value!;
                                                    selectedRoleValue = value!;

                                                    assignRole(
                                                        storedMembersData[i]
                                                            ['id'],
                                                        storedMembersData[i][
                                                            'Workspace Member'],
                                                        selectedRoleValue);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      //DeAssign Role
                                      Visibility(
                                        visible: widget.deAssignRole,
                                        child: Visibility(
                                          visible: storedMembersData[i]
                                                  ['Assigned Role'] !=
                                              'No Role Assign',
                                          child: ListTile(
                                            onTap: () async {
                                              await deAssignRole(
                                                  storedMembersData[i]['id'],
                                                  storedMembersData[i]
                                                      ['Workspace Member']);
                                            },
                                            dense: true,
                                            title: const Text('De-Assign Role'),
                                            trailing: Lottie.asset(
                                                repeat: false,
                                                height: 30,
                                                'animations/crossbutton.json'),
                                            // const Icon(Icons.close),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]
                  ],
                ],
              );
            }
            return Center(
              child: Container(),
            );
          },
        ),

        // Column(
        //   children: [
        //     AppDivider(text: 'Workspace Members', color: AppColor.black),
        //     if (!wait) ...[
        //       for (int i = 0; i < membersList.length; i++) ...[
        //         if (membersList[i] != currentUserEmail) ...[
        //           Card(
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(10.0),
        //             ),
        //             margin:
        //                 const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        //             child: ClipPath(
        //               clipper: ShapeBorderClipper(
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(10),
        //                 ),
        //               ),
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                   border: Border(
        //                     left: BorderSide(
        //                         // color: Color(
        //                         //     safeColorDisplay(int.parse(roleColors[i]),),
        //                         //     ),
        //                         width: 10),
        //                   ),
        //                 ),
        //                 child: ExpansionTile(
        //                   title: Text(
        //                     membersList[i],
        //                     style: TextStyle(color: AppColor.black),
        //                   ),
        //                   iconColor: AppColor.black,
        //                   subtitle: Row(
        //                     children: [
        //                       Lottie.asset(
        //                           repeat: false, 'animations/blue-bar.json'),
        //                       Lottie.asset(
        //                           repeat: false, 'animations/yellow-bar.json'),
        //                       Lottie.asset(
        //                           repeat: false, 'animations/grey-bar.json'),
        //                       // Container(
        //                       //   width: 50,
        //                       //   height: 10,
        //                       //   color: AppChartColor.blue,
        //                       //   child:
        //                       // ),
        //                       // Container(
        //                       //   margin: const EdgeInsets.symmetric(horizontal: 10),
        //                       //   width: 50,
        //                       //   height: 10,
        //                       //   color: AppChartColor.yellow,
        //                       // ),
        //                       // Container(
        //                       //   width: 50,
        //                       //   height: 10,
        //                       //   color: AppChartColor.grey,
        //                       // ),
        //                     ],
        //                   ),
        //                   onExpansionChanged: (v) async {
        //                     // await getAssignedRole(membersList[i]);
        //                   },
        //                   children: [
        //                     Lottie.asset(
        //                         reverse: true,
        //                         repeat: false,
        //                         'animations/grey-divider.json'),
        //                     // const Divider(
        //                     //   thickness: 2,
        //                     //   indent: 20,
        //                     //   endIndent: 20,
        //                     // ),
        //                     Visibility(
        //                       visible: widget.assignTaskControl,
        //                       child: ListTile(
        //                         onTap: () async {
        //                           await getUserData(membersList[i]);
        //                           if (mounted) {
        //                             Navigator.push(
        //                               context,
        //                               MaterialPageRoute(
        //                                 builder: (context) =>
        //                                     TaskTeamAssignment(
        //                                   name: userName,
        //                                   email: membersList[i],
        //                                   workspaceCode: widget.workspaceCode,
        //                                   docId: widget.docId,
        //                                   workspaceName: widget.workspaceName,
        //                                   workspaceOwnerEmail:
        //                                       widget.workspaceOwnerEmail,
        //                                   assignedRole: assignedRoleList[i],
        //                                 ),
        //                               ),
        //                             );
        //                           }
        //                         },
        //                         dense: true,
        //                         title: const Text('Assign Task'),
        //                         trailing: Lottie.asset(
        //                             repeat: false,
        //                             height: 40,
        //                             'animations/add-to-box.json'),
        //
        //                         // Image.asset('assets/right-arrow3.png',
        //                         //     height: 30),
        //                       ),
        //                     ),
        //                     Visibility(
        //                       visible: widget.reportControl,
        //                       child: ListTile(
        //                         onTap: () async {
        //                           await getUserData(membersList[i]);
        //                           log(userName);
        //                           if (mounted) {
        //                             Navigator.push(
        //                               context,
        //                               MaterialPageRoute(
        //                                 builder: (context) => Visualization(
        //                                   workspaceName: widget.workspaceName,
        //                                   userName: userName,
        //                                 ),
        //                               ),
        //                             );
        //                           }
        //                         },
        //                         dense: true,
        //                         title: const Text('Check Report'),
        //                         trailing: Lottie.asset(
        //                             repeat: false,
        //                             height: 35,
        //                             'animations/graph.json'),
        //                         // Image.asset('assets/bar-graph.png', height: 30),
        //                       ),
        //                     ),
        //                     ListTile(
        //                       dense: true,
        //                       title: const Text('Assigned Role'),
        //                       subtitle: Text('By: ${assignedByList[i]}'),
        //                       trailing: safeDisplay(assignedRoleList[i]),
        //                     ),
        //                     Lottie.asset(
        //                         reverse: true,
        //                         repeat: false,
        //                         'animations/grey-divider.json'),
        //                     ExpansionTile(
        //                       title: Text(
        //                         'Role For Member',
        //                         style: TextStyle(color: AppColor.black),
        //                       ),
        //                       iconColor: AppColor.black,
        //                       children: [
        //                         // const Divider(
        //                         //   thickness: 2,
        //                         //   indent: 20,
        //                         //   endIndent: 20,
        //                         // ),
        //                         Visibility(
        //                           visible: widget.assignRole,
        //                           child: Visibility(
        //                             visible: rolesList.isNotEmpty,
        //                             child: ListTile(
        //                               dense: true,
        //                               title: const Text('Assign Role'),
        //                               subtitle: Container(
        //                                 margin: const EdgeInsets.symmetric(
        //                                     horizontal: 20),
        //                                 child: SingleChildScrollView(
        //                                   scrollDirection: Axis.horizontal,
        //                                   child: DropdownButton<dynamic>(
        //                                     hint: const Text('Roles'),
        //                                     isDense: true,
        //                                     items: rolesList
        //                                         .map<DropdownMenuItem<dynamic>>(
        //                                             (dynamic value) {
        //                                       return DropdownMenuItem<dynamic>(
        //                                         value: value,
        //                                         child: Text(value),
        //                                       );
        //                                     }).toList(),
        //                                     value: selectedRoleValue.isEmpty
        //                                         ? assignedRoleList
        //                                         : null,
        //                                     onChanged: (value) async {
        //                                       setState(() {
        //                                         assignedRole = value!;
        //                                         assignedRoleList[i] =
        //                                             assignedRole;
        //                                         assignedByList[i] =
        //                                             currentUserEmail.toString();
        //                                         selectedRoleValue = value!;
        //                                       });
        //
        //                                       final assignRoleJson = {
        //                                         'Assigned Role':
        //                                             selectedRoleValue,
        //                                         'Assigned By': currentUserEmail,
        //                                         'Assigned At': DateTime.now(),
        //                                       };
        //
        //                                       try {
        //                                         await FireBaseApi
        //                                             .saveDataIntoFireStore(
        //                                                 workspaceCode: widget
        //                                                     .workspaceCode,
        //                                                 collection:
        //                                                     '${widget.workspaceCode} Assigned Roles',
        //                                                 document:
        //                                                     membersList[i],
        //                                                 jsonData:
        //                                                     assignRoleJson);
        //
        //                                         await FirebaseFirestore.instance
        //                                             .collection('User Data')
        //                                             .doc(membersList[i])
        //                                             .collection(
        //                                                 'Workspace Roles')
        //                                             .doc(widget.workspaceCode)
        //                                             .set({
        //                                           'Role': AppFunctions
        //                                               .getStringOnly(
        //                                                   text:
        //                                                       selectedRoleValue),
        //                                           'Level': AppFunctions
        //                                               .getNumberFromString(
        //                                                   text:
        //                                                       selectedRoleValue),
        //                                           'Created At': DateTime.now(),
        //                                         });
        //
        //                                         log('Role Assign Successfully');
        //                                         String name = await AppFunctions
        //                                             .getNameByEmail(
        //                                                 email: widget
        //                                                     .workspaceOwnerEmail);
        //                                         String token =
        //                                             await AppFunctions
        //                                                 .getTokenByEmail(
        //                                                     email:
        //                                                         membersList[i]);
        //                                         MessageNotificationApi.send(
        //                                             token: token,
        //                                             title: 'Congratulations ☺',
        //                                             body:
        //                                                 '$name assign you ${AppFunctions.getStringOnly(text: selectedRoleValue)} role of Level ${AppFunctions.getNumberFromString(text: selectedRoleValue)} in ${widget.workspaceName} workspace.');
        //                                       } catch (e) {
        //                                         log('Role Assign Failed');
        //                                       }
        //                                     },
        //                                   ),
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //                         ),
        //                         Visibility(
        //                           visible: widget.deAssignRole,
        //                           child: Visibility(
        //                             visible:
        //                                 assignedRoleList[i] != 'No Role Assign',
        //                             child: ListTile(
        //                               onTap: () async {
        //                                 await FirebaseFirestore.instance
        //                                     .collection(
        //                                         '${widget.workspaceCode} Assigned Roles')
        //                                     .doc(membersList[i])
        //                                     .update({
        //                                   'Assigned By': '',
        //                                   'Assigned Role': 'No Role Assign',
        //                                 });
        //
        //                                 await FirebaseFirestore.instance
        //                                     .collection('User Data')
        //                                     .doc(membersList[i])
        //                                     .collection('Workspace Roles')
        //                                     .doc(widget.workspaceCode)
        //                                     .delete();
        //
        //                                 log('Role De-Assign successfully');
        //
        //                                 String name =
        //                                     await AppFunctions.getNameByEmail(
        //                                         email:
        //                                             widget.workspaceOwnerEmail);
        //                                 String token =
        //                                     await AppFunctions.getTokenByEmail(
        //                                         email: membersList[i]);
        //                                 MessageNotificationApi.send(
        //                                     token: token,
        //                                     title: 'Oh No 😟',
        //                                     body:
        //                                         '$name de-assign your role from ${widget.workspaceName} workspace.');
        //                                 setState(() {
        //                                   assignedRoleList[i] =
        //                                       'No Role Assign';
        //                                   assignedByList[i] = '';
        //                                 });
        //                               },
        //                               dense: true,
        //                               title: const Text('De-Assign Role'),
        //                               trailing: Lottie.asset(
        //                                   repeat: false,
        //                                   height: 30,
        //                                   'animations/crossbutton.json'),
        //                               // const Icon(Icons.close),
        //                             ),
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //             // ListTile(
        //             //   onTap: () async {
        //             //     await getUserData(membersList[i]);
        //             //     if (mounted) {
        //             //       Navigator.push(
        //             //         context,
        //             //         MaterialPageRoute(
        //             //           builder: (context) => TaskAssignment(
        //             //             name: userName,
        //             //             email: membersList[i],
        //             //             workspaceCode: widget.workspaceCode,
        //             //             docId: widget.docId,
        //             //             workspaceName: widget.workspaceName,
        //             //           ),
        //             //         ),
        //             //       );
        //             //     }
        //             //   },
        //             //   dense: true,
        //             //   title: Text(membersList[i]),
        //             //   subtitle: Row(children: [
        //             //     Container(
        //             //       width: 50,
        //             //       height: 10,
        //             //       color: AppChartColor.blue,
        //             //     ),
        //             //     Container(
        //             //       margin: const EdgeInsets.symmetric(horizontal: 10),
        //             //       width: 50,
        //             //       height: 10,
        //             //       color: AppChartColor.yellow,
        //             //     ),
        //             //     Container(
        //             //       width: 50,
        //             //       height: 10,
        //             //       color: AppChartColor.grey,
        //             //     ),
        //             //   ]),
        //             // ),
        //           ),
        //         ]
        //       ],
        //     ] else ...[
        //       CircularProgressIndicator(
        //         color: AppColor.orange,
        //       ),
        //     ],
        //   ],
        // ),
      ],
    );
  }

  addMemberInWorkspaces({required String memberEmail}) async {
    log('------------------------------------');
    log('Member in adding in to workspace');
    log(widget.workspaceOwnerEmail);
    try {
      await FirebaseFirestore.instance
          .collection('Workspaces')
          .doc(widget.docId)
          .update({
        'Workspace Members': FieldValue.arrayUnion([memberEmail]),
      });
      log('Member is added in Common Workspaces');
      await CollectionDocHistory.saveCollectionHistory(
        workspaceCode: widget.workspaceCode,
        collectionName: 'Workspaces',
        docName: widget.docId,
      );
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection(widget.workspaceCode)
          .doc('Log')
          .update({
        'Workspace Members': FieldValue.arrayUnion([memberEmail]),
      });
      log('Member is added in Secrete Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Members')
          .doc(memberEmail)
          .set({
        'Workspace Member': memberEmail,
        'Add By': currentUserEmail,
        'Assigned Role': 'No Role Assign',
        'Assigned By': '',
        'Color Code': '0xffffffff',
        'Created At': DateTime.now(),
      });
      log('Member is added in Members Workspaces');
      await CollectionDocHistory.saveCollectionHistory(
        workspaceCode: widget.workspaceCode,
        collectionName: '${widget.workspaceCode} Members',
        docName: memberEmail,
      );
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(memberEmail)
          .update({
        'Joined Workspaces': FieldValue.arrayUnion([widget.workspaceCode]),
      });
      log('Workspaces added in User Data');
      String name =
          await AppFunctions.getNameByEmail(email: widget.workspaceOwnerEmail);
      String token = await AppFunctions.getTokenByEmail(email: memberEmail);
      MessageNotificationApi.send(
          token: token,
          title: 'Awesome ☺',
          body: '$name added you in ${widget.workspaceName} workspace.');
    } catch (e) {
      log(e.toString());
    }
    try {
      await FirebaseFirestore.instance
          .collection('$currentUserEmail ${widget.workspaceCode} Team')
          .doc(widget.workspaceCode)
          .update({
        'Workspace Members': FieldValue.arrayUnion([memberEmail]),
      });
      log('------------------------------------');
    } catch (e) {
      log(e.toString());

      await FireBaseApi.saveDataIntoFireStore(
          workspaceCode: widget.workspaceCode,
          collection: '$currentUserEmail ${widget.workspaceCode} Team',
          document: widget.workspaceCode,
          jsonData: {
            'Workspace Members': [],
          });
      // await FirebaseFirestore.instance
      //     .collection('$currentUserEmail ${widget.workspaceCode} Team')
      //     .doc(widget.workspaceCode)
      //     .set({
      //   'Workspace Members': [],
      // });
      await FirebaseFirestore.instance
          .collection('$currentUserEmail ${widget.workspaceCode} Team')
          .doc(widget.workspaceCode)
          .update({
        'Workspace Members': FieldValue.arrayUnion([memberEmail]),
      });
      log('------------------------------------');
    }

    getSpecificTeam(currentUserEmail.toString());
  }

  removeMemberFromWorkspaces({required String memberEmail}) async {
    log('------------------------------------');
    log('Member in removing from workspace');

    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Members')
          .doc(memberEmail)
          .delete();
      log('Member is deleted from Members Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection('Workspaces')
          .doc(widget.docId)
          .update({
        'Workspace Members': FieldValue.arrayRemove([memberEmail]),
      });
      log('Member is removed in Common Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection(widget.workspaceCode)
          .doc('Log')
          .update({
        'Workspace Members': FieldValue.arrayRemove([memberEmail]),
      });
      log('Member is removed in Secrete Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(memberEmail)
          .update({
        'Joined Workspaces': FieldValue.arrayRemove([widget.workspaceCode]),
      });
      log('Workspaces removed in User Data');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection('$currentUserEmail ${widget.workspaceCode} Team')
          .doc(widget.workspaceCode)
          .update({
        'Workspace Members': FieldValue.arrayRemove([memberEmail]),
      });
      String name =
          await AppFunctions.getNameByEmail(email: widget.workspaceOwnerEmail);
      String token = await AppFunctions.getTokenByEmail(email: memberEmail);
      MessageNotificationApi.send(
          token: token,
          title: 'Oh No 😟',
          body: '$name removed you from ${widget.workspaceName} workspace.');
      log('------------------------------------');
    } catch (e) {
      log(e.toString());
    }
    getSpecificTeam(currentUserEmail.toString());
  }

  safeDisplay(String text) {
    try {
      return Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } catch (e) {
      log(e.toString());
      return const CircularProgressIndicator(
        strokeWidth: 1,
      );
    }
  }

  assignRole(String id, String member, String selectedRoleValue) async {
    final assignRoleJson = {
      'Assigned Role': selectedRoleValue,
      'Assigned By': currentUserEmail,
      'Assigned At': DateTime.now(),
    };

    String colorCode = await AppFunctions.getColorCodeByRole(
      workspaceCode: '${widget.workspaceCode} Roles',
      role: selectedRoleValue,
    );

    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Members')
          .doc(id)
          .update({
        'Assigned Role': selectedRoleValue,
        'Assigned By': currentUserEmail,
        'Color Code': colorCode,
      });
      log('Role is assign to member is added in Members Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FireBaseApi.saveDataIntoFireStore(
        workspaceCode: widget.workspaceCode,
        collection: '${widget.workspaceCode} Assigned Roles',
        document: member,
        jsonData: assignRoleJson,
      );
      // List<String> temp = selectedRoleValue.split(' ');

      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(member)
          .collection('Workspace Roles')
          .doc(widget.workspaceCode)
          .set(
        {
          'Role': AppFunctions.getStringOnly(text: selectedRoleValue),
          'Level': AppFunctions.getNumberFromString(text: selectedRoleValue),
          'Created At': DateTime.now(),
        },
      );

      log('Role Assign Successfully');
      String name =
          await AppFunctions.getNameByEmail(email: widget.workspaceOwnerEmail);
      String token = await AppFunctions.getTokenByEmail(email: member);
      MessageNotificationApi.send(
          token: token,
          title: 'Congratulations ☺',
          body:
              '$name assign you ${AppFunctions.getStringOnly(text: selectedRoleValue)} role of Level ${AppFunctions.getNumberFromString(text: selectedRoleValue)} in ${widget.workspaceName} workspace.');
    } catch (e) {
      log('Role Assign Failed');
    }
  }

  deAssignRole(String id, String member) async {
    await FirebaseFirestore.instance
        .collection('${widget.workspaceCode} Members')
        .doc(id)
        .update({
      'Assigned Role': 'No Role Assign',
      'Assigned By': '',
      'Color Code': '0xffffffff',
    });

    await FirebaseFirestore.instance
        .collection('${widget.workspaceCode} Assigned Roles')
        .doc(member)
        .update({
      'Assigned By': '',
      'Assigned Role': 'No Role Assign',
    });

    await FirebaseFirestore.instance
        .collection('User Data')
        .doc(member)
        .collection('Workspace Roles')
        .doc(widget.workspaceCode)
        .delete();

    log('Role De-Assign successfully');

    String name =
        await AppFunctions.getNameByEmail(email: widget.workspaceOwnerEmail);
    String token = await AppFunctions.getTokenByEmail(email: member);
    MessageNotificationApi.send(
        token: token,
        title: 'Oh No 😟',
        body:
            '$name de-assign your role from ${widget.workspaceName} workspace.');
  }
}
