import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stepbystep/screens/workspace_manager/create_workspace.dart';
import 'package:stepbystep/screens/workspace_manager/delete_workspace.dart';
import 'package:stepbystep/screens/workspace_manager/task_holder_section/task_holder.dart';

import 'package:stepbystep/screens/workspace_manager/workspace_screen_combiner.dart';
import 'package:stepbystep/apis/send_email_api.dart';
import 'package:stepbystep/widgets/app_input_field.dart';

bool canDeleteWorkspace = false;

class WorkspaceHome extends StatefulWidget {
  const WorkspaceHome({Key? key}) : super(key: key);

  @override
  State<WorkspaceHome> createState() => _WorkspaceHomeState();
}

class _WorkspaceHomeState extends State<WorkspaceHome> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  double _height = 0;
  bool isEmpty = false;
  bool result = false;
  List<dynamic> joinedWorkspaces = [];
  List<dynamic> ownedWorkspaces = [];
  final Stream<QuerySnapshot> _workspaces = FirebaseFirestore.instance
      .collection('Workspaces')
      .orderBy('Created At', descending: true)
      .snapshots();

  getJoinedWorkspaces() async {
    try {
      final value = await FirebaseFirestore.instance
          .collection("User Data")
          .doc(currentUserEmail)
          .get();

      setState(() {
        joinedWorkspaces = value.data()!['Joined Workspaces'];
      });
      log('Joined Workspaces.....');
      log(joinedWorkspaces.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  getOwnedWorkspaces() async {
    try {
      final value = await FirebaseFirestore.instance
          .collection("User Data")
          .doc(currentUserEmail)
          .get();

      setState(() {
        ownedWorkspaces = value.data()!['Owned Workspaces'];
      });
      log('Owned Workspaces.....');
      log(ownedWorkspaces.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  void _onRefresh() async {
    log('-------------------------------------');
    log('On Refresh');
    await getJoinedWorkspaces();
    await getOwnedWorkspaces();
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
    log('-------------------------------------');
  }

  @override
  void initState() {
    getJoinedWorkspaces();
    getOwnedWorkspaces();
    log(currentUserEmail.toString());
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _height = 70;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log(result.toString());
    return Scaffold(
      body: SmartRefresher(
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
              stream: _workspaces,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  log('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              scale: 1.3,
                              image: AssetImage('assets/workspace_bg.png'),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0;
                                i < storedWorkspaces.length;
                                i++) ...[
                              if (storedWorkspaces[i]
                                      ['Workspace Owner Email'] ==
                                  currentUserEmail) ...[
                                WorkspaceCard(
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
                                            WorkspaceScreenCombiner(
                                          workspaceCode:
                                              "${storedWorkspaces[i]['Workspace Code']}",
                                          docId: "${storedWorkspaces[i]['id']}",
                                          workspaceName: storedWorkspaces[i]
                                              ['Workspace Name'],
                                          workspaceOwnerEmail:
                                              storedWorkspaces[i]
                                                  ['Workspace Owner Email'],
                                        ),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    showWorkspaceDeletionDialog(
                                      context: context,
                                      ownerEmail: storedWorkspaces[i]
                                          ['Workspace Owner Email'],
                                      workspaceName: storedWorkspaces[i]
                                          ['Workspace Name'],
                                      workspaceCode: storedWorkspaces[i]
                                          ['Workspace Code'],
                                    );
                                  },
                                ),
                                // GestureDetector(
                                //   onLongPress: () {
                                //     showWorkspaceDeletionDialog(
                                //       context: context,
                                //       ownerEmail: storedWorkspaces[i]
                                //           ['Workspace Owner Email'],
                                //       workspaceName: storedWorkspaces[i]
                                //           ['Workspace Name'],
                                //       workspaceCode: storedWorkspaces[i]
                                //           ['Workspace Code'],
                                //     );
                                //     // WorkspaceDeleteOperation(
                                //     //   ownerEmail: storedWorkspaces[i]
                                //     //       ['Workspace Owner Email'],
                                //     //   workspaceName: storedWorkspaces[i]
                                //     //       ['Workspace Name'],
                                //     //   workspaceCode: storedWorkspaces[i]
                                //     //       ['Workspace Code'],
                                //     // );
                                //   },
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) =>
                                //             WorkspaceScreenCombiner(
                                //           workspaceCode:
                                //               "${storedWorkspaces[i]['Workspace Code']}",
                                //           docId: "${storedWorkspaces[i]['id']}",
                                //           workspaceName: storedWorkspaces[i]
                                //               ['Workspace Name'],
                                //           workspaceOwnerEmail:
                                //               storedWorkspaces[i]
                                //                   ['Workspace Owner Email'],
                                //         ),
                                //       ),
                                //     );
                                //   },
                                //   child: AnimatedContainer(
                                //     duration:
                                //         const Duration(milliseconds: 1000),
                                //     curve: Curves.fastOutSlowIn,
                                //     height: _height,
                                //     child: Card(
                                //       margin: const EdgeInsets.symmetric(
                                //           horizontal: 10),
                                //       shape: const RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.all(
                                //           Radius.circular(10),
                                //         ),
                                //       ),
                                //       child: ClipPath(
                                //         clipper: ShapeBorderClipper(
                                //           shape: RoundedRectangleBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(10),
                                //           ),
                                //         ),
                                //         child: Container(
                                //           decoration: BoxDecoration(
                                //             border: Border(
                                //               left: BorderSide(
                                //                   color: AppColor.orange,
                                //                   width: 10),
                                //             ),
                                //           ),
                                //           child: ListTile(
                                //             dense: true,
                                //             title: ReadMoreText(
                                //               storedWorkspaces[i]
                                //                   ['Workspace Name'],
                                //               trimLength: 2,
                                //               trimLines: 2,
                                //               colorClickableText:
                                //                   AppColor.orange,
                                //               textAlign: TextAlign.justify,
                                //               trimMode: TrimMode.Line,
                                //               trimCollapsedText: '  more',
                                //               trimExpandedText: '      less',
                                //               style: TextStyle(
                                //                 color: AppColor.black,
                                //                 fontWeight: FontWeight.bold,
                                //                 fontSize: 15,
                                //               ),
                                //               moreStyle: TextStyle(
                                //                   fontSize: 12,
                                //                   fontWeight: FontWeight.bold,
                                //                   color: AppColor.black),
                                //               lessStyle: TextStyle(
                                //                   fontSize: 12,
                                //                   fontWeight: FontWeight.bold,
                                //                   color: AppColor.black),
                                //             ),
                                //
                                //             subtitle: Text(storedWorkspaces[i]
                                //                 ['Workspace Type']),
                                //             trailing: Lottie.asset(
                                //                 repeat: false,
                                //                 height: 30,
                                //                 'animations/star.json'),
                                //             // Icon(Icons.star,
                                //             //     color: AppChartColor.yellow),
                                //           ),
                                //         ),
                                //       ),
                                //
                                //       // ListTile(
                                //       //   minLeadingWidth: 0,
                                //       //   leading: CircleAvatar(radius: 30, backgroundColor: AppColor.orange),
                                //       //   title: Text(
                                //       //     'Umar',
                                //       //     style: TextStyle(fontWeight: FontWeight.bold),
                                //       //   ),
                                //       // ),
                                //     ),
                                //
                                //     // Card(
                                //     //   child: ListTile(
                                //     //     dense: true,
                                //     //     title: ReadMoreText(
                                //     //       storedWorkspaces[i]
                                //     //           ['Workspace Name'],
                                //     //       trimLength: 2,
                                //     //       trimLines: 2,
                                //     //       colorClickableText: AppColor.orange,
                                //     //       textAlign: TextAlign.justify,
                                //     //       trimMode: TrimMode.Line,
                                //     //       trimCollapsedText: '  more',
                                //     //       trimExpandedText: '      less',
                                //     //       style: TextStyle(
                                //     //         color: AppColor.black,
                                //     //         fontWeight: FontWeight.bold,
                                //     //         fontSize: 15,
                                //     //       ),
                                //     //       moreStyle: TextStyle(
                                //     //           fontSize: 12,
                                //     //           fontWeight: FontWeight.bold,
                                //     //           color: AppColor.black),
                                //     //       lessStyle: TextStyle(
                                //     //           fontSize: 12,
                                //     //           fontWeight: FontWeight.bold,
                                //     //           color: AppColor.black),
                                //     //     ),
                                //     //
                                //     //     subtitle: Text(storedWorkspaces[i]
                                //     //         ['Workspace Type']),
                                //     //     trailing: Lottie.asset(
                                //     //         repeat: false,
                                //     //         height: 30,
                                //     //         'animations/star.json'),
                                //     //     // Icon(Icons.star,
                                //     //     //     color: AppChartColor.yellow),
                                //     //   ),
                                //     // ),
                                //   ),
                                // ),
                              ],
                              if (joinedWorkspaces.contains(
                                  storedWorkspaces[i]['Workspace Code'])) ...[
                                WorkspaceCard(
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
                                              WorkspaceTaskHolder(
                                            workspaceCode: storedWorkspaces[i]
                                                ['Workspace Code'],
                                            workspaceName: storedWorkspaces[i]
                                                ['Workspace Name'],
                                            docId: storedWorkspaces[i]['id'],
                                            workspaceOwnerName:
                                                storedWorkspaces[i]
                                                    ['Workspace Owner Name'],
                                            workspaceOwnerEmail:
                                                storedWorkspaces[i]
                                                    ['Workspace Owner Email'],
                                          ),
                                        ),
                                      );
                                    },
                                    onLongPress: () {}),
                                // GestureDetector(
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) =>
                                //             WorkspaceTaskHolder(
                                //           workspaceCode: storedWorkspaces[i]
                                //               ['Workspace Code'],
                                //           workspaceName: storedWorkspaces[i]
                                //               ['Workspace Name'],
                                //           docId: storedWorkspaces[i]['id'],
                                //           workspaceOwnerName:
                                //               storedWorkspaces[i]
                                //                   ['Workspace Owner Name'],
                                //           workspaceOwnerEmail:
                                //               storedWorkspaces[i]
                                //                   ['Workspace Owner Email'],
                                //         ),
                                //       ),
                                //     );
                                //   },
                                //   child: AnimatedContainer(
                                //     duration:
                                //         const Duration(milliseconds: 1000),
                                //     curve: Curves.fastOutSlowIn,
                                //     height: _height,
                                //     child: Card(
                                //       child: Container(
                                //         height: 100,
                                //         child: ListTile(
                                //           dense: true,
                                //           title: ReadMoreText(
                                //             storedWorkspaces[i]
                                //                 ['Workspace Name'],
                                //             trimLength: 2,
                                //             trimLines: 2,
                                //             colorClickableText: AppColor.orange,
                                //             textAlign: TextAlign.justify,
                                //             trimMode: TrimMode.Line,
                                //             trimCollapsedText: '  more',
                                //             trimExpandedText: '      less',
                                //             style: TextStyle(
                                //               color: AppColor.black,
                                //               fontWeight: FontWeight.bold,
                                //               fontSize: 15,
                                //             ),
                                //             moreStyle: TextStyle(
                                //                 fontSize: 12,
                                //                 fontWeight: FontWeight.bold,
                                //                 color: AppColor.black),
                                //             lessStyle: TextStyle(
                                //                 fontSize: 12,
                                //                 fontWeight: FontWeight.bold,
                                //                 color: AppColor.black),
                                //           ),
                                //           subtitle: Text(storedWorkspaces[i]
                                //               ['Workspace Type']),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
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
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var value = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateWorkspace(ownedWorkspaces: ownedWorkspaces),
            ),
          );
          setState(() {
            if (value != null) {
              result = value;
            }
          });
          if (result) {
            getOwnedWorkspaces();
          }
        },
        tooltip: 'Add Workspace',
        child: Image.asset(
          'assets/hierarchy.png',
          height: 30,
          color: AppColor.white,
        ),
      ),
    );
  }

  showWorkspaceDeletionDialog(
      {required BuildContext context,
      required String ownerEmail,
      required String workspaceName,
      required String workspaceCode}) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget continueButton = TextButton(
      child: Text(
        'Delete',
        style: TextStyle(color: canDeleteWorkspace ? Colors.red : Colors.grey),
      ),
      onPressed: () async {
        DeleteWorkspace(
          context: context,
          ownerEmail: ownerEmail,
          workspaceName: workspaceName,
          workspaceCode: workspaceCode,
        ).deleteWholeWorkspace();
        pleaseWaitDialog(context);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(workspaceName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(height: 70, 'animations/warning-red.json'),
            // TextFormField(
            //   keyboardType: TextInputType.text,
            //   cursorColor: AppColor.black,
            //   style: TextStyle(color: AppColor.black),
            //   decoration: InputDecoration(
            //     isDense: true,
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(5.0),
            //     ),
            //     focusedBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(5.0),
            //       borderSide: BorderSide(color: AppColor.grey, width: 1.5),
            //     ),
            //     hintText: 'Type Workspace Name',
            //     // hintStyle: TextStyle(color: purpleColor),
            //     label: Text(
            //       'Workspace Name',
            //       style: TextStyle(color: AppColor.black),
            //     ),
            //   ),
            //   onChanged: (v) {
            //     if (v == workspaceName) {
            //       setState(() {
            //         canDeleteWorkspace = true;
            //       });
            //     } else {
            //       setState(() {
            //         canDeleteWorkspace = false;
            //       });
            //     }
            //     log(v);
            //   },
            // ),
            const SizedBox(height: 6),
            const Text("Do you want to delete workspace ?"),
            const Text(
              'Deleted workspace cannot be recovered',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  pleaseWaitDialog(
    BuildContext context,
  ) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CircularProgressIndicator(
                color: AppColor.orange,
              ),
              const SizedBox(width: 20),
              const Text('Please Wait...'),
            ],
          ),
        );
      },
    );
  }
}

class WorkspaceCard extends StatelessWidget {
  WorkspaceCard(
      {Key? key,
      required this.workspaceName,
      required this.workspaceType,
      required this.height,
      required this.onTap,
      required this.onLongPress})
      : super(key: key);
  String workspaceName;
  String workspaceType;
  double height;
  Function() onTap;
  Function() onLongPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
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
                  trailing: Lottie.asset(
                      repeat: false, height: 30, 'animations/star.json'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
