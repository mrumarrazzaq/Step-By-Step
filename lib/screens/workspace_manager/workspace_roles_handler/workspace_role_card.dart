import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:readmore/readmore.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
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
    required this.teamControl,
    required this.roleControl,
    required this.taskControl,
    required this.viewControl,
  }) : super(key: key);
  String id;
  String workspaceCode;
  String roleName;
  String roleDescription;
  String roleLevel;
  bool teamControl;
  bool roleControl;
  bool taskControl;
  bool viewControl;
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

  List<bool> values = [false, false, false, false];
  Offset _tapPosition = const Offset(0, 0);
  @override
  void initState() {
    setValues();
    super.initState();
  }

  void setValues() {
    setState(() {
      values[0] = widget.teamControl;
      values[1] = widget.roleControl;
      values[2] = widget.taskControl;
      values[3] = widget.viewControl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log(widget.id);
        log('@umar');
      },
      onTapDown: (details) {
        _tapPosition = details.globalPosition;
        log(_tapPosition.toString());
      },
      onLongPress: () {
        showOptionMenu(
          context: context,
          position: _tapPosition,
          id: widget.id,
          roleName: widget.roleName,
          roleDescription: widget.roleDescription,
          roleLevel: widget.roleLevel,
        );
      },
      child: Card(
        elevation: 2,
        shadowColor: AppColor.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: ExpansionTile(
          title: Text(
            widget.roleName,
            style: TextStyle(
              color: AppColor.orange,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
            AppDivider(text: 'Controls', color: AppColor.black),
            ListTile(
              minLeadingWidth: 0,
              leading: Checkbox(
                value: values[0],
                onChanged: (value) async {
                  setState(() {
                    values[0] = value!;
                  });
                  await updateRoleControls(
                      widget.id, values[0], 'Team Control');
                },
              ),
              title: Text(
                'Expand Team Authority',
                style: TextStyle(
                  color: AppColor.black,
                  fontWeight: values[0] ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: Image.asset(
                'assets/group.png',
                height: 13,
                color: values[0] ? AppColor.black : AppColor.grey,
              ),
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Checkbox(
                value: values[1],
                onChanged: (value) async {
                  setState(() {
                    values[1] = value!;
                  });
                  await updateRoleControls(
                      widget.id, values[1], 'Role Control');
                },
              ),
              title: Text(
                'Create Roles Authority',
                style: TextStyle(
                  color: AppColor.black,
                  fontWeight: values[1] ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: Image.asset(
                'assets/hat.png',
                height: 15,
                color: values[1] ? AppColor.black : AppColor.grey,
              ),
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Checkbox(
                value: values[2],
                onChanged: (value) async {
                  setState(() {
                    values[2] = value!;
                  });
                  await updateRoleControls(
                      widget.id, values[2], 'Task Control');
                },
              ),
              title: Text(
                'Assign Tasks Authority',
                style: TextStyle(
                  color: AppColor.black,
                  fontWeight: values[2] ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: Image.asset(
                'assets/planning.png',
                height: 15,
                color: values[2] ? AppColor.black : AppColor.grey,
              ),
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Checkbox(
                value: values[3],
                onChanged: (value) async {
                  setState(() {
                    values[3] = value!;
                  });
                  await updateRoleControls(
                      widget.id, values[3], 'View Control');
                },
              ),
              title: Text(
                'View Authority',
                style: TextStyle(
                  color: AppColor.black,
                  fontWeight: values[3] ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: Image.asset(
                'assets/planning.png',
                height: 15,
                color: values[2] ? AppColor.black : AppColor.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateRoleControls(
      String id, bool val, String controlName) async {
    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Roles')
          .doc(id)
          .update({
        controlName: val,
      });
      log('Role control update successfully');
    } catch (e) {
      log(e.toString());
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
                  title: '$roleName,Level $roleLevel',
                  warning: 'Deleted Roles can not be recovered'),
            );
          },
          child: const Center(
            child: Text('Delete'),
          ),
        ),
      ],
    );
  }

  openDeleteDialog({
    required String id,
    required String title,
    required String warning,
  }) =>
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            var width = MediaQuery.of(context).size.width;
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              title: const Center(child: Text('Delete Role')),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: width,
                  height: 40.0,
                  child: Center(
                      child: Column(
                    children: [
                      Text(title),
                      Text(
                        warning,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: AppColor.red),
                      ),
                    ],
                  )),
                ),
              ),
              actions: [
                //CANCEL Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
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
                              'Workspace Roles': FieldValue.arrayRemove([id]),
                            });

                            await FirebaseFirestore.instance
                                .collection('Workspaces')
                                .doc(widget.workspaceCode)
                                .update({
                              'Workspace Roles': FieldValue.arrayRemove([id]),
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
                                    'Workspace Roles': FieldValue.arrayUnion(
                                        ['${roleController.text} $roleLevel']),
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('Workspaces')
                                      .doc(widget.workspaceCode)
                                      .update({
                                    'Workspace Roles':
                                        FieldValue.arrayRemove([id]),
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
                                    'Team Control': widget.teamControl,
                                    'Role Control': widget.roleControl,
                                    'Task Control': widget.taskControl,
                                    'View Control': widget.viewControl,
                                    'Assigned By': currentUserEmail,
                                    'Created At': DateTime.now(),
                                  };

                                  await FireBaseApi.saveDataIntoFireStore(
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
