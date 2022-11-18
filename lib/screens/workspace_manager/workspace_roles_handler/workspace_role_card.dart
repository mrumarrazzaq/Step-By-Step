import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/widgets/app_divider.dart';

class WorkspaceRoleCard extends StatefulWidget {
  WorkspaceRoleCard(
      {Key? key,
      required this.workspaceCode,
      required this.roleName,
      required this.roleLevel,
      required this.controls})
      : super(key: key);
  String workspaceCode;
  String roleName;
  String roleLevel;
  List<dynamic> controls;
  @override
  State<WorkspaceRoleCard> createState() => _WorkspaceRoleCardState();
}

class _WorkspaceRoleCardState extends State<WorkspaceRoleCard> {
  List<bool> values = [false, false, false];
  @override
  void initState() {
    setValues();
    super.initState();
  }

  void setValues() {
    setState(() {
      values[0] = widget.controls[0];
      values[1] = widget.controls[1];
      values[2] = widget.controls[2];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColor.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Column(
        children: [
          ListTile(
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
                /*await UpdateRoleControls(values[0]);*/
              },
            ),
            title: Text(
              'Can Create Team',
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
              onChanged: (value) {
                setState(() {
                  values[1] = value!;
                });
              },
            ),
            title: Text(
              'Can Create Roles',
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
              onChanged: (value) {
                setState(() {
                  values[2] = value!;
                });
              },
            ),
            title: Text(
              'Can Create Tasks',
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
        ],
      ),
    );
  }

  Future<void> UpdateRoleControls(bool val) async {
    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Roles')
          .doc('${widget.roleName} ${widget.roleLevel}')
          .update({
        'Controls': FieldValue.arrayUnion([val]),
      });
      log('Role changed in User Data');
    } catch (e) {
      log(e.toString());
    }
  }
}
