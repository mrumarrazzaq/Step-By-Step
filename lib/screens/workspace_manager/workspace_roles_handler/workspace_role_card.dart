import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:readmore/readmore.dart';
import 'package:stepbystep/apis/app_functions.dart';

import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_roles_handler/controls_list.dart';
import 'package:stepbystep/widgets/app_divider.dart';
import 'package:stepbystep/widgets/app_elevated_button.dart';
import 'package:stepbystep/widgets/app_progress_indicator.dart';

class WorkspaceRoleCard extends StatefulWidget {
  WorkspaceRoleCard({
    Key? key,
    required this.id,
    required this.workspaceCode,
    required this.roleName,
    required this.roleDescription,
    required this.roleLevel,
    required this.roleColor,
    required this.controlForOwner,
    required this.control,
    required this.teamControl,
    required this.memberControl,
    required this.roleControl,
    required this.taskControl,
    required this.viewControl,
    required this.addMember,
    required this.removeMember,
    required this.assignRole,
    required this.deAssignRole,
    required this.createRole,
    required this.editRole,
    required this.deleteRole,
    required this.reportControl,
  }) : super(key: key);
  String id;
  String workspaceCode;
  String roleName;
  String roleDescription;
  String roleLevel;
  String roleColor;
  bool controlForOwner;
  bool teamControl;
  bool memberControl;
  bool control;
  bool roleControl;
  bool taskControl;
  bool viewControl;
  bool reportControl;

  bool addMember;
  bool removeMember;
  bool assignRole;
  bool deAssignRole;
  bool createRole;
  bool editRole;
  bool deleteRole;
  @override
  State<WorkspaceRoleCard> createState() => _WorkspaceRoleCardState();
}

class _WorkspaceRoleCardState extends State<WorkspaceRoleCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final roleController = TextEditingController();
  final descriptionController = TextEditingController();

  int roleLevel = 1;

  bool deleteRoleLoading = false;
  bool updateRoleLoading = false;

  bool control = false;
  bool editRoleForDecision = false;
  bool deleteRoleForDecision = false;

  bool teamAuthority = false;
  bool memberAuthority = false;
  bool roleAuthority = false;
  bool roleControlAuthority = false;
  bool viewAuthority = false;
  List<bool> membersSubAuth = [false, false, false, false, false, false];
  List<bool> roleSubAuth = [false, false, false];
  Offset _tapPosition = const Offset(0, 0);
  String assignedRole = '';
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
  @override
  void initState() {
    roleColor = Color(int.parse(widget.roleColor));
    hexColorCode = '0x${roleColor.value.toRadixString(16)}';
    hexColorCode = widget.roleColor;
    setValues();
    super.initState();
  }

  Future<void> getSpecificRoleData(String assignedRoleToUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Roles')
          .doc(assignedRoleToUser)
          .get()
          .then((ds) {
        control = ds['Control'];
        editRoleForDecision = ds['Edit Role'];
        deleteRoleForDecision = ds['Delete Role'];
      });
      setState(() {});
    } catch (e) {
      log('Failed to get edit role and delete role.');
    }
  }

  void setValues() async {
    if (!widget.controlForOwner) {
      assignedRole = await AppFunctions.getRoleByEmail(
          email: currentUserEmail.toString(),
          workspaceCode: widget.workspaceCode);
      await getSpecificRoleData(assignedRole);
    }

    setState(() {
      teamAuthority = widget.teamControl;
      memberAuthority = widget.memberControl;
      roleAuthority = widget.roleControl;
      viewAuthority = widget.viewControl;
      roleControlAuthority = widget.control;

      membersSubAuth[0] = widget.addMember;
      membersSubAuth[1] = widget.removeMember;
      membersSubAuth[2] = widget.taskControl;
      membersSubAuth[3] = widget.assignRole;
      membersSubAuth[4] = widget.deAssignRole;
      membersSubAuth[5] = widget.reportControl;

      roleSubAuth[0] = widget.createRole;
      roleSubAuth[1] = widget.editRole;
      roleSubAuth[2] = widget.deleteRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        log(widget.id);
        log('@umar');
      },
      onTapDown: (details) async {
        _tapPosition = details.globalPosition;
        if (!widget.controlForOwner) {
          assignedRole = await AppFunctions.getRoleByEmail(
              email: currentUserEmail.toString(),
              workspaceCode: widget.workspaceCode);
          await getSpecificRoleData(assignedRole);
        }
        setState(() {});
        log(_tapPosition.toString());
      },
      onLongPress: () async {
        if (assignedRole != '${widget.roleName} ${widget.roleLevel}') {
          if (!widget.controlForOwner) {
            await getSpecificRoleData(assignedRole);
          }
          showOptionMenu(
            context: context,
            position: _tapPosition,
            id: widget.id,
            roleName: widget.roleName,
            roleDescription: widget.roleDescription,
            roleLevel: widget.roleLevel,
          );
        }
      },
      child: Card(
        elevation: 2,
        shadowColor: AppColor.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: ExpansionTile(
          title: ReadMoreText(
            widget.roleName,
            trimLength: 2,
            trimLines: 1,
            colorClickableText: AppColor.orange,
            textAlign: TextAlign.justify,
            trimMode: TrimMode.Line,
            trimCollapsedText: '  more',
            trimExpandedText: '      less',
            style: TextStyle(
              color: AppColor.orange,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            moreStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColor.black),
            lessStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColor.black),
          ),

          // Text(
          //   widget.roleName,
          //   style: TextStyle(
          //     color: AppColor.orange,
          //     fontWeight: FontWeight.bold,
          //     fontSize: 20,
          //   ),
          // ),
          trailing: Text(
            'Level ${widget.roleLevel}',
            style: TextStyle(
              color: AppColor.black,
              fontSize: 18,
            ),
          ),
          children: [
            Visibility(
              visible: widget.roleDescription.isNotEmpty,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3),
                child: ReadMoreText(
                  '" ${widget.roleDescription} "',
                  trimLines: 2,
                  colorClickableText: AppColor.orange,
                  textAlign: TextAlign.justify,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Show more',
                  trimExpandedText: 'Show less',
                  style: const TextStyle(
                    color: Colors.blue,
                    overflow: TextOverflow.fade,
                  ),
                  moreStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.black),
                  lessStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.black),
                ),
              ),
            ),
            Visibility(
              visible: widget.controlForOwner ||
                  (assignedRole != '${widget.roleName} ${widget.roleLevel}' &&
                      control),
              child: AppDivider(text: 'Controls', color: AppColor.black),
            ),
            Visibility(
              visible: widget.controlForOwner ||
                  (assignedRole != '${widget.roleName} ${widget.roleLevel}' &&
                      control),
              child: Column(
                children: [
                  //Team Control
                  Visibility(
                    child: ExpansionTile(
                      iconColor: AppColor.black,
                      collapsedIconColor: AppColor.black,
                      leading: Checkbox(
                        value: teamAuthority,
                        onChanged: (value) async {
                          setState(() {
                            teamAuthority = value!;
                          });
                          await updateRoleControls(
                              id: widget.id,
                              boolean: teamAuthority,
                              controlName: 'Team Control',
                              list: teamControlsList);
                        },
                      ),
                      title: Text(
                        'Team Authority',
                        style: TextStyle(
                          color: AppColor.black,
                          fontWeight: teamAuthority
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      childrenPadding:
                          const EdgeInsets.symmetric(horizontal: 30),
                      children: [
                        //Members Authority
                        Visibility(
                          visible: teamAuthority,
                          child: ExpansionTile(
                            iconColor: AppColor.black,
                            collapsedIconColor: AppColor.black,
                            leading: Checkbox(
                              value: memberAuthority,
                              onChanged: (value) async {
                                setState(() {
                                  memberAuthority = value!;
                                });
                                await updateRoleControls(
                                    id: widget.id,
                                    boolean: memberAuthority,
                                    controlName: 'Member Control',
                                    list: membersControlsList);
                              },
                            ),
                            title: Text(
                              'Members Authority',
                              style: TextStyle(
                                color: AppColor.black,
                                fontWeight: memberAuthority
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            childrenPadding:
                                const EdgeInsets.symmetric(horizontal: 30),
                            children: [
                              //Add Members
                              Visibility(
                                visible: memberAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      activeColor: AppColor.black,
                                      value: membersSubAuth[0],
                                      onChanged: (value) async {
                                        setState(() {
                                          membersSubAuth[0] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: membersSubAuth[0],
                                            controlName: 'Add Member',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'Add Members',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: membersSubAuth[0]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              //Remove Members
                              Visibility(
                                visible: memberAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      activeColor: AppColor.black,
                                      value: membersSubAuth[1],
                                      onChanged: (value) async {
                                        setState(() {
                                          membersSubAuth[1] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: membersSubAuth[1],
                                            controlName: 'Remove Member',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'Remove Members',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: membersSubAuth[1]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              //Assign Task
                              Visibility(
                                visible: memberAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      activeColor: AppColor.black,
                                      value: membersSubAuth[2],
                                      onChanged: (value) async {
                                        setState(() {
                                          membersSubAuth[2] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: membersSubAuth[2],
                                            controlName: 'Task Control',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'Assign Task',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: membersSubAuth[2]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),

                              // Assign Roles To Members
                              Visibility(
                                visible: memberAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      activeColor: AppColor.black,
                                      value: membersSubAuth[3],
                                      onChanged: (value) async {
                                        setState(() {
                                          membersSubAuth[3] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: membersSubAuth[3],
                                            controlName: 'Assign Role',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'Assign Roles To Members',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: membersSubAuth[3]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              //De-Assign Roles To Members
                              Visibility(
                                visible: memberAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      activeColor: AppColor.black,
                                      value: membersSubAuth[4],
                                      onChanged: (value) async {
                                        setState(() {
                                          membersSubAuth[4] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: membersSubAuth[4],
                                            controlName: 'DeAssign Role',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'De-Assign Roles To Members',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: membersSubAuth[4]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              //Report Generate
                              Visibility(
                                visible: memberAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      value: membersSubAuth[5],
                                      activeColor: AppColor.black,
                                      onChanged: (value) async {
                                        setState(() {
                                          membersSubAuth[5] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: membersSubAuth[5],
                                            controlName: 'Report Control',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'Report Generate',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: membersSubAuth[5]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Role Control
                        Visibility(
                          visible: teamAuthority,
                          child: ExpansionTile(
                            iconColor: AppColor.black,
                            collapsedIconColor: AppColor.black,
                            leading: Checkbox(
                              value: roleAuthority,
                              onChanged: (value) async {
                                setState(() {
                                  roleAuthority = value!;
                                });
                                await updateRoleControls(
                                    id: widget.id,
                                    boolean: roleAuthority,
                                    controlName: 'Role Control',
                                    list: rolesControlsList);
                              },
                            ),
                            title: Text(
                              'Roles Authority',
                              style: TextStyle(
                                color: AppColor.black,
                                fontWeight: roleAuthority
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            childrenPadding:
                                const EdgeInsets.symmetric(horizontal: 30),
                            children: [
                              Visibility(
                                visible: roleAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      activeColor: AppColor.black,
                                      value: roleSubAuth[0],
                                      onChanged: (value) async {
                                        setState(() {
                                          roleSubAuth[0] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: roleSubAuth[0],
                                            controlName: 'Create Role',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'Create Role',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: roleSubAuth[0]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: roleAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      activeColor: AppColor.black,
                                      value: roleSubAuth[1],
                                      onChanged: (value) async {
                                        setState(() {
                                          roleSubAuth[1] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: roleSubAuth[1],
                                            controlName: 'Edit Role',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'Edit Roles',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: roleSubAuth[1]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: roleAuthority,
                                child: ListTile(
                                  dense: true,
                                  minLeadingWidth: 0,
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Checkbox(
                                      activeColor: AppColor.black,
                                      value: roleSubAuth[2],
                                      onChanged: (value) async {
                                        setState(() {
                                          roleSubAuth[2] = value!;
                                        });
                                        await updateRoleControls(
                                            id: widget.id,
                                            boolean: roleSubAuth[2],
                                            controlName: 'Delete Role',
                                            list: []);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    'Delete Roles',
                                    style: TextStyle(
                                      color: AppColor.black,
                                      fontStyle: roleSubAuth[2]
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Roles Control Authority
                        Visibility(
                          visible: teamAuthority,
                          child: ListTile(
                            minLeadingWidth: 0,
                            leading: Checkbox(
                              value: roleControlAuthority,
                              onChanged: (value) async {
                                setState(() {
                                  roleControlAuthority = value!;
                                });
                                await updateRoleControls(
                                    id: widget.id,
                                    boolean: roleControlAuthority,
                                    controlName: 'Control',
                                    list: []);
                              },
                            ),
                            title: Text(
                              'Role Control Authority',
                              style: TextStyle(
                                color: AppColor.black,
                                fontWeight: roleControlAuthority
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        //View Authority
                        Visibility(
                          visible: teamAuthority,
                          child: ListTile(
                            minLeadingWidth: 0,
                            leading: Checkbox(
                              value: viewAuthority,
                              onChanged: (value) async {
                                setState(() {
                                  viewAuthority = value!;
                                });
                                await updateRoleControls(
                                    id: widget.id,
                                    boolean: viewAuthority,
                                    controlName: 'View Control',
                                    list: []);
                              },
                            ),
                            title: Text(
                              'Org View Authority',
                              style: TextStyle(
                                color: AppColor.black,
                                fontWeight: viewAuthority
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateRoleControls(
      {required String id,
      required bool boolean,
      required String controlName,
      required List<String> list}) async {
    try {
      if (controlName == 'Team Control' && boolean == false) {
        for (var name in list) {
          await FirebaseFirestore.instance
              .collection('${widget.workspaceCode} Roles')
              .doc(id)
              .update({
            name: boolean,
          });
        }
      } else if (controlName == 'Member Control' && boolean == false) {
        for (var name in list) {
          await FirebaseFirestore.instance
              .collection('${widget.workspaceCode} Roles')
              .doc(id)
              .update({
            name: boolean,
          });
        }
      } else if (controlName == 'Role Control' && boolean == false) {
        for (var name in list) {
          await FirebaseFirestore.instance
              .collection('${widget.workspaceCode} Roles')
              .doc(id)
              .update({
            name: boolean,
          });
        }
      } else {
        await FirebaseFirestore.instance
            .collection('${widget.workspaceCode} Roles')
            .doc(id)
            .update({
          controlName: boolean,
        });
        log('Role control update successfully');
      }
      setValues();
    } catch (e) {
      log(e.toString());
      log('Role control update failed');
    }
  }

  Future<void> showOptionMenu({
    required BuildContext context,
    required Offset position,
    required String id,
    required String roleName,
    required String roleDescription,
    required String roleLevel,
  }) async {
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: 80,
      ),
      items: [
        if (widget.controlForOwner || editRoleForDecision) ...[
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 'value',
            height: 30,
            textStyle: TextStyle(color: AppColor.black),
            onTap: () {
              setState(() {
                roleController.text = roleName;
                descriptionController.text = roleDescription;
                this.roleLevel = int.parse(roleLevel);
              });
              Future.delayed(
                Duration.zero,
                () => roleUpdateDialog(id: id),
              );
            },
            child: const Center(
              child: Text('Edit'),
            ),
          ),
        ],
        if (widget.controlForOwner || deleteRoleForDecision) ...[
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 'value',
            height: 30,
            textStyle: TextStyle(color: AppColor.black),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () => openDeleteDialog(
                    id: id,
                    title: roleName,
                    subTitle: 'Level $roleLevel',
                    warning: 'Deleted Roles can not be recovered'),
              );
            },
            child: const Center(
              child: Text('Delete'),
            ),
          ),
        ],
      ],
    );
  }

  openDeleteDialog({
    required String id,
    required String title,
    required String subTitle,
    required String warning,
  }) =>
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            var width = MediaQuery.of(context).size.width;
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  titlePadding: const EdgeInsets.only(top: 50.0),
                  title: const Center(child: Text('Delete Role')),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: width,
                      height: 55.0,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title),
                            Text(
                              subTitle,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              warning,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                  color: AppColor.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    //CANCEL Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    //CREATE Button
                    deleteRoleLoading
                        ? AppProgressIndicator(
                            radius: 25,
                            size: 20,
                          )
                        : TextButton(
                            onPressed: () async {
                              if (id.isNotEmpty) {
                                setState(() {
                                  deleteRoleLoading = true;
                                });

                                try {
                                  await FirebaseFirestore.instance
                                      .collection(
                                          '${widget.workspaceCode} Assigned Roles')
                                      .doc(id)
                                      .delete();
                                } catch (e) {
                                  log(e.toString());
                                }
                                await FirebaseFirestore.instance
                                    .collection('${widget.workspaceCode} Roles')
                                    .doc(id)
                                    .delete();

                                await FirebaseFirestore.instance
                                    .collection(widget.workspaceCode)
                                    .doc('Log')
                                    .update({
                                  'Workspace Roles':
                                      FieldValue.arrayRemove([id]),
                                });

                                await FirebaseFirestore.instance
                                    .collection('Workspaces')
                                    .doc(widget.workspaceCode)
                                    .update({
                                  'Workspace Roles':
                                      FieldValue.arrayRemove([id]),
                                });

                                log('Role Deleted Successfully');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Role Deleted Successfully'),
                                  ),
                                );
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                setState(() {
                                  deleteRoleLoading = false;
                                });
                              }
                            },
                            child: const Text(
                              'DELETE',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                  ],
                ),
                Positioned(
                  top: 202,
                  child: CircleAvatar(
                    backgroundColor: AppColor.white,
                    radius: 50,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Lottie.asset('animations/delete-files-loop.json'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

  void roleUpdateDialog({required String id}) {
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
                        'Redefine Role',
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
                                  maxLength: 80,
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
                      updateRoleLoading
                          ? AppProgressIndicator(
                              radius: 25,
                              size: 30,
                            )
                          : AppElevatedButton(
                              text: 'Update',
                              width: 100,
                              fontSize: 12,
                              textColor: AppColor.white,
                              backgroundColor: AppColor.orange,
                              function: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    updateRoleLoading = true;
                                  });
                                  // Add and Remove From Workspace Collection
                                  await FirebaseFirestore.instance
                                      .collection('Workspaces')
                                      .doc(widget.workspaceCode)
                                      .update({
                                    'Workspace Roles':
                                        FieldValue.arrayRemove([id]),
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('Workspaces')
                                      .doc(widget.workspaceCode)
                                      .update({
                                    'Workspace Roles': FieldValue.arrayUnion(
                                        ['${roleController.text} $roleLevel']),
                                  });
                                  // Add and Remove From Workspace Code Collection
                                  await FirebaseFirestore.instance
                                      .collection(widget.workspaceCode)
                                      .doc('Log')
                                      .update({
                                    'Workspace Roles': FieldValue.arrayUnion(
                                        ['${roleController.text} $roleLevel']),
                                  });
                                  await FirebaseFirestore.instance
                                      .collection(widget.workspaceCode)
                                      .doc('Log')
                                      .update({
                                    'Workspace Roles':
                                        FieldValue.arrayRemove([id])
                                  });

                                  // Delete Workspace Code Role Document
                                  await FirebaseFirestore.instance
                                      .collection(
                                          '${widget.workspaceCode} Roles')
                                      .doc(id)
                                      .delete();
                                  //Create a new One
                                  final roleJson = {
                                    'Role': roleController.text.trim(),
                                    'Role Description':
                                        descriptionController.text.isEmpty
                                            ? ''
                                            : descriptionController.text.trim(),
                                    'Role Level': roleLevel,
                                    'Role Color': hexColorCode,
                                    'Control': widget.control,
                                    'Team Control': widget.teamControl,
                                    'Member Control': widget.memberControl,
                                    'Add Member': widget.addMember,
                                    'Remove Member': widget.removeMember,
                                    'Assign Role': widget.assignRole,
                                    'DeAssign Role': widget.deAssignRole,
                                    'Role Control': widget.roleControl,
                                    'Create Role': widget.createRole,
                                    'Edit Role': widget.editRole,
                                    'Delete Role': widget.deleteRole,
                                    'Task Control': widget.taskControl,
                                    'View Control': widget.viewControl,
                                    'Report Control': widget.reportControl,
                                    'Assigned By': currentUserEmail,
                                    'Created At': DateTime.now(),
                                  };

                                  await FireBaseApi.saveDataIntoFireStore(
                                      workspaceCode: widget.workspaceCode,
                                      collection:
                                          '${widget.workspaceCode} Roles',
                                      document:
                                          '${roleController.text} $roleLevel',
                                      jsonData: roleJson);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Role Updated Successfully'),
                                    ),
                                  );

                                  roleController.clear();
                                  descriptionController.clear();
                                  Navigator.pop(context);
                                  setState(() {
                                    updateRoleLoading = false;
                                  });
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
}
