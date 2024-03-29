import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:readmore/readmore.dart';
import 'package:stepbystep/ads/ad_mob_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/apis/get_apis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stepbystep/screens/workspace_manager/create_workspace.dart';
import 'package:stepbystep/screens/workspace_manager/delete_workspace.dart';

import 'package:stepbystep/screens/workspace_manager/workspace_screen_combiner.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_user_section/task_holder.dart';

bool canDeleteWorkspace = false;

class WorkspaceHome extends StatefulWidget {
  const WorkspaceHome({Key? key}) : super(key: key);

  @override
  State<WorkspaceHome> createState() => _WorkspaceHomeState();
}

class _WorkspaceHomeState extends State<WorkspaceHome> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  InterstitialAd? _interstitialAd;

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
    getJoinedWorkspaces();
    getOwnedWorkspaces();
    log(currentUserEmail.toString());
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _height = 70;
      });
    });
    _loadInterstitialAd();
    super.initState();
  }

  bool checkForImage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        // enablePullUp: true,
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
                  final List storedIdByEmail = [];
                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map id = document.data() as Map<String, dynamic>;
                    storedWorkspaces.add(id);
                    id['id'] = document.id;
                    List<String> newId = id['id'].split(' ');
                    storedIdByEmail.add(newId[0]);
                  }).toList();

                  log(storedIdByEmail.toString());
                  return storedWorkspaces.isEmpty
                      ? Container(
                          height: 500,
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
                                  isOwned: true,
                                  workspaceName: storedWorkspaces[i]
                                      ['Workspace Name'],
                                  workspaceType: storedWorkspaces[i]
                                      ['Workspace Type'],
                                  height: _height,
                                  onTap: () async {
                                    bool isTrue = await GetApi.isPaidAccount();
                                    if (!isTrue) {
                                      _showInterstitialAd();
                                    }
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WorkspaceScreenCombiner(
                                            workspaceCode:
                                                "${storedWorkspaces[i]['Workspace Code']}",
                                            docId:
                                                "${storedWorkspaces[i]['id']}",
                                            workspaceName: storedWorkspaces[i]
                                                ['Workspace Name'],
                                            workspaceOwnerEmail:
                                                storedWorkspaces[i]
                                                    ['Workspace Owner Email'],
                                          ),
                                        ),
                                      );
                                    }
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
                                    onTap: () async {
                                      bool isTrue =
                                          await GetApi.isPaidAccount();
                                      if (!isTrue) {
                                        _showInterstitialAd();
                                      }

                                      if (mounted) {
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
                                      }
                                    },
                                    onLongPress: () {}),
                              ] else if (storedWorkspaces.length < 2) ...[
                                Container(
                                  height: 500,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      scale: 1.3,
                                      image:
                                          AssetImage('assets/workspace_bg.png'),
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
      child: const Text(
        'Cancel',
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget continueButton = TextButton(
      child: const Text(
        'Delete',
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        DeleteWorkspace(
          context: context,
          ownerEmail: ownerEmail,
          workspaceName: workspaceName,
          workspaceCode: workspaceCode,
        ).runDeleteOperation();
        pleaseWaitDialog(context);
        await Future.delayed(
          const Duration(seconds: 10),
        );
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          _onRefresh();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      // actionsPadding: EdgeInsets.zero,

      contentPadding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
      // insetPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              workspaceName,
              style: TextStyle(
                color: AppColor.darkGrey,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Lottie.asset(height: 70, 'animations/warning-red.json'),
            const SizedBox(height: 6),
            const Text("Do you want to delete workspace ?"),
            const Text(
              'Deleted workspace cannot be recovered',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                cancelButton,
                continueButton,
              ],
            ),
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
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
      barrierDismissible: false,
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
  const WorkspaceCard(
      {Key? key,
      required this.isOwned,
      required this.workspaceName,
      required this.workspaceType,
      required this.height,
      required this.onTap,
      required this.onLongPress})
      : super(key: key);
  final bool isOwned;
  final String workspaceName;
  final String workspaceType;
  final double height;
  final Function() onTap;
  final Function() onLongPress;
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
