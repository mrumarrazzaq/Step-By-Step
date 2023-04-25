import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/ads/ad_mob_service.dart';
import 'package:stepbystep/apis/get_apis.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/table_calendar/workspace_table_calendar.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_task_tile.dart';

class TaskView extends StatefulWidget {
  TaskView({
    Key? key,
    required this.isOwner,
    required this.userEmail,
    required this.workspaceCode,
    required this.workspaceTaskCode,
    required this.taskStatusValue,
    required this.color,
    required this.snapshot,
    required this.leftButton,
    required this.rightButton,
  }) : super(key: key);
  bool isOwner;
  String userEmail;
  String workspaceCode;
  String workspaceTaskCode;
  int taskStatusValue;
  Stream<QuerySnapshot> snapshot;
  Color color;
  bool leftButton;
  bool rightButton;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  String dateFilter = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
  DateTime initialSelectedDate = DateTime.now();
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
          stream: widget.snapshot,
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
              final List storedData = [];

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map id = document.data() as Map<String, dynamic>;
                storedData.add(id);
                id['id'] = document.id;
              }).toList();
              for (int i = 0; i < storedData.length; i++) {
                checkExpiredTask(storedData[i]['Due Date'],
                    storedData[i]['Raw Date'], storedData[i]['id']);
              }
              return Column(
                children: [
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      dense: true,
                      title: InkWell(
                        onTap: () async {
                          bool isTrue = await GetApi.isPaidAccount();
                          if (!isTrue) {
                            _showInterstitialAd();
                          }
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkspaceTableCalendar(
                                  tasks: storedData,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'See Task History',
                            style: GoogleFonts.aBeeZee(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      textColor: AppColor.black,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            color: Colors.black,
                            width: 2,
                            height: 30,
                            margin: const EdgeInsets.only(right: 10),
                          ),
                          InkWell(
                            onTap: () {
                              _pickDate();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              color: Colors.transparent,
                              child: Lottie.asset(
                                  repeat: false,
                                  height: 30,
                                  'animations/calendar.json'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Lottie.asset(repeat: false, 'animations/black-divider.json'),
                  DatePicker(
                    initialSelectedDate,
                    initialSelectedDate: initialSelectedDate,
                    selectionColor: Colors.black,
                    selectedTextColor: Colors.white,
                    width: 60,
                    onDateChange: (dateTime) {
                      setState(() {
                        dateFilter =
                            formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        log(dateTime.toString());
                        log(dateFilter.toString());
                      });
                    },
                  ),
                  for (int i = 0; i < storedData.length; i++) ...[
                    if (storedData[i]['Due Date'].isNotEmpty) ...[],
                    if (storedData[i]['Task Status'] ==
                            widget.taskStatusValue &&
                        dateFilter == storedData[i]['Date Filter']) ...[
                      WorkspaceTaskTile(
                        isOwner: widget.isOwner,
                        userEmail: widget.userEmail,
                        workspaceCode: widget.workspaceCode,
                        workspaceTaskCode: widget.workspaceTaskCode,
                        docId: storedData[i]['id'],
                        title: storedData[i]['Task Title'],
                        description: storedData[i]['Task Description'],
                        taskStatusValue: widget.taskStatusValue,
                        email: storedData[i]['Assigned By'],
                        date: storedData[i]['Due Date'],
                        fileName: storedData[i]['File Name'],
                        fileURL: storedData[i]['File URL'],
                        color: widget.color,
                        leftButton: widget.leftButton,
                        rightButton: widget.rightButton,
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
            ));
          }),
    );
  }

  void checkExpiredTask(String dueDate, var rawDate, String docId) async {
    if (dueDate != 'No Due Date') {
      log('CHECK FOR EXPIRED TASKS');
      if (rawDate.toDate().isBefore(DateTime.now())) {
        await FirebaseFirestore.instance
            .collection(widget.workspaceTaskCode)
            .doc(docId)
            .update({
          'Task Status': 4,
        });

        try {
          log('___________________________________________________________');
          await FirebaseFirestore.instance
              .collection('Report ${widget.workspaceTaskCode}')
              .where('Task Id', isEqualTo: docId)
              .get()
              .then((querySnapshot) {
            var docSnapshot = querySnapshot.docs[0];
            docId = docSnapshot.id;
            log('Document ID: $docId');
          });

          await FirebaseFirestore.instance
              .collection('Report ${widget.workspaceTaskCode}')
              .doc(docId)
              .update({
            'TODO': 0,
            'DOING': 0,
            'REVIEW': 0,
            'COMPLETED': 0,
            'EXPIRED': 1
          });
          log('Updated Successfully');
          log('___________________________________________________________');
        } catch (e) {
          log(e.toString());
          log('++++++++++++++++++++++++++++++++++++++++++');
        }
      }
    }
  }

  void _pickDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 01, 01),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.orange,
              onPrimary: AppColor.white,
              onSurface: AppColor.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: AppColor.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickDate != null) {
      setState(() {
        initialSelectedDate = pickDate;
        log(initialSelectedDate.toString());
        //dateFilter = formatDate(pickDate, [dd, ' ', MM, ' ', yyyy]);
      });
    }
  }
}
