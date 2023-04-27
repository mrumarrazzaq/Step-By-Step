// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/inbox_section/inbox_screen.dart';

class RecentInboxes extends StatefulWidget {
  RecentInboxes({Key? key, required this.workspaceCode}) : super(key: key);
  String workspaceCode;
  @override
  _RecentInboxesState createState() => _RecentInboxesState();
}

class _RecentInboxesState extends State<RecentInboxes> {
  List<dynamic> joinedWorkspaceMembers = [];
  getJoinedWorkspaceMembers() async {
    try {
      final value = await FirebaseFirestore.instance
          .collection("Workspaces")
          .doc(widget.workspaceCode)
          .get();

      setState(() {
        joinedWorkspaceMembers = value.data()!['Workspace Members'];
        joinedWorkspaceMembers.add(value.data()!['Workspace Owner Email']);
      });
      log('Joined Workspaces Members.....');
      log(joinedWorkspaceMembers.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    getJoinedWorkspaceMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log('-------------------------------------------------------------');
    log('Recent Inbox Screen Build is Called ');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recent Inbox',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.black,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: AppColor.orange,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('User Data')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            log('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.orange,
                                  strokeWidth: 2.0,
                                ),
                              ),
                            );
                          }
                          final List recentInboxes = [];

                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map id = document.data() as Map<String, dynamic>;
                            recentInboxes.add(id);
//                  print('==============================================');
//                  print(storeRequests);
//                  print('Document id : ${document.id}');
                            id['id'] = document.id;
//                            storedMassages.sort((a, b) => b.value["Created At"]
//                                .compareTo(a.value["Created At"]));
                          }).toList();
                          return Column(
//                            shrinkWrap: true,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              recentInboxes.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 50.0),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            const Text(
                                              'No Recent Inbox',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Image.asset('assets/chat.png'),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              for (int i = 0;
                                  i < recentInboxes.length;
                                  i++) ...[
                                joinedWorkspaceMembers.contains(
                                            recentInboxes[i]['User Email']) &&
                                        recentInboxes[i]['User Email'] !=
                                            currentUserEmail
                                    ? CustomRecentChatsTile(
                                        name: recentInboxes[i]['User Name'],
                                        email: recentInboxes[i]['User Email'],
                                        imagePath: recentInboxes[i]
                                            ['Image URL'],
                                        currentStatus: recentInboxes[i]
                                            ['User Current Status'],
                                      )
                                    : Container(),
                              ],
                            ],
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRecentChatsTile extends StatelessWidget {
  const CustomRecentChatsTile({
    Key? key,
    required this.name,
    required this.email,
    required this.imagePath,
    required this.currentStatus,
  }) : super(key: key);

  final String name;
  final String email;
  final String imagePath;
  final String currentStatus;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InboxScreen(
              name: name,
              currentStatus: currentStatus,
              imageURL: imagePath,
              receiverEmail: email,
              internetConnectionStatus: false,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: imagePath.isNotEmpty
                ? Stack(
                    children: [
                      CircleAvatar(
                        radius: 20.0,
                        backgroundImage: NetworkImage(imagePath),
                      ),
                      Positioned(
                        top: 28,
                        left: 28,
                        child: CircleAvatar(
                          backgroundColor: currentStatus == 'Online'
                              ? Colors.green
                              : Colors.grey[600],
                          radius: 5,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      CircleAvatar(
                        radius: 20.0,
                        backgroundColor: AppColor.orange.withOpacity(0.4),
                        child: Text(
                          name[0],
                          style: GoogleFonts.righteous(
                            fontSize: 20,
                            color: AppColor.black,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 28,
                        left: 28,
                        child: CircleAvatar(
                          backgroundColor: currentStatus == 'Online'
                              ? Colors.green
                              : Colors.grey[600],
                          radius: 5,
                        ),
                      ),
                    ],
                  ),
            title:
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              email,
              style: GoogleFonts.arimaMadurai(
                fontSize: 12,
                color: AppColor.black,
              ),
            ),
            trailing: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: 0 == 0 ? Colors.white : Colors.green.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Center(
                child: Text(
                  '0',
                  style: TextStyle(color: AppColor.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
