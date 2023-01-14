import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:readmore/readmore.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/inbox_section/inbox_screen.dart';
import 'package:stepbystep/screens/inbox_section/recent_inboxes.dart';

class RecentWorkspaces extends StatefulWidget {
  RecentWorkspaces({Key? key}) : super(key: key);

  @override
  _RecentWorkspacesState createState() => _RecentWorkspacesState();
}

class _RecentWorkspacesState extends State<RecentWorkspaces> {
  final Stream<QuerySnapshot> _workspaces = FirebaseFirestore.instance
      .collection('Workspaces')
      .orderBy('Created At', descending: true)
      .snapshots();

  double _height = 0;
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _height = 70;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log('-------------------------------------------------------------');
    log('Recent Workspace Screen Build is Called ');
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: AppColor.orange,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Recent Workspaces',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColor.white, fontSize: 20),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 45.0),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                ),
                child: SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _workspaces,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          log('Something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColor.orange,
                                strokeWidth: 3.0,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasData) {
                          final List storedWorkspaces = [];
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map id = document.data() as Map<String, dynamic>;
                            storedWorkspaces.add(id);
                            id['id'] = document.id;
                          }).toList();
                          return storedWorkspaces.isEmpty
                              ? Container(
                                  height: 500,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      scale: 1.3,
                                      image:
                                          AssetImage('assets/group_chat.png'),
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    for (int i = 0;
                                        i < storedWorkspaces.length;
                                        i++) ...[
                                      if (storedWorkspaces[i]
                                              ['Workspace Owner Email'] ==
                                          currentUserEmail) ...[
                                        WorkspaceCard(
                                          isOwned: true,
                                          workspaceName: storedWorkspaces[i]
                                              ['Workspace Name'],
                                          workspaceType: storedWorkspaces[i]
                                              ['Workspace Type'],
                                          height: _height,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RecentInboxes(
                                                  workspaceCode:
                                                      storedWorkspaces[i]
                                                          ['Workspace Code'],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ] else if (storedWorkspaces[i]
                                              ['Workspace Members']
                                          .contains(currentUserEmail)) ...[
                                        WorkspaceCard(
                                          isOwned: false,
                                          workspaceName: storedWorkspaces[i]
                                              ['Workspace Name'],
                                          workspaceType: storedWorkspaces[i]
                                              ['Workspace Type'],
                                          height: _height,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RecentInboxes(
                                                  workspaceCode:
                                                      storedWorkspaces[i]
                                                          ['Workspace Code'],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ] else ...[
                                        Container(
                                          height: 500,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              scale: 1.3,
                                              image: AssetImage(
                                                  'assets/group_chat.png'),
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
                            strokeWidth: 2.0,
                          ),
                        );
                      }),
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
  CustomRecentChatsTile({
    Key? key,
    required this.name,
    required this.email,
    required this.imagePath,
    required this.currentStatus,
  }) : super(key: key);

  String name;
  String email;
  String imagePath;
  String currentStatus;
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
            ));
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
                  child: Text('0', style: TextStyle(color: AppColor.white))),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkspaceCard extends StatelessWidget {
  WorkspaceCard({
    Key? key,
    required this.isOwned,
    required this.workspaceName,
    required this.workspaceType,
    required this.height,
    required this.onTap,
  }) : super(key: key);
  bool isOwned;
  String workspaceName;
  String workspaceType;
  double height;
  Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastOutSlowIn,
          height: height,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColor.orange, width: 10),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  title: ReadMoreText(
                    workspaceName,
                    trimLength: 2,
                    trimLines: 2,
                    colorClickableText: AppColor.orange,
                    textAlign: TextAlign.justify,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '  more',
                    trimExpandedText: '      less',
                    style: TextStyle(
                      color: AppColor.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
                  subtitle: Text(workspaceType),
                  trailing: isOwned
                      ? Lottie.asset(
                          repeat: false, height: 30, 'animations/star.json')
                      : Container(
                          width: 0, height: 0, color: AppColor.transparent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
