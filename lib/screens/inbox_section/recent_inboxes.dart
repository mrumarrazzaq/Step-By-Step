import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/inbox_section/inbox_screen.dart';
import 'package:stepbystep/widgets/app_stream_builder.dart';

class RecentInboxes extends StatefulWidget {
  RecentInboxes({Key? key}) : super(key: key);

  @override
  _RecentInboxesState createState() => _RecentInboxesState();
}

class _RecentInboxesState extends State<RecentInboxes> {
//  String receiverEmail = '';
//  String receiverName = '';
//  String receiverProfileImageUrl = '';
//  Timestamp timestamp = Timestamp.now();
//  fetch() async {
//    final user = FirebaseAuth.instance.currentUser;
//    print(user!.email);
//    print('-------------------------------------');
//    print('Current user data is fetching');
//    try {
//      await FirebaseFirestore.instance
//          .collection('Recent Chats ${currentUserEmail.toString()}')
//          .doc(user.email)
//          .get()
//          .then((ds) {
//        receiverEmail = ds['Receiver Email'];
//        receiverName = ds['Receiver Name'];
//        receiverProfileImageUrl = ds['Receiver profileImageUrl'];
//        timestamp = ds['Created At'];
//      });
//      setState(() {});
//    } catch (e) {
//      print(e.toString());
//    }
//  }

  @override
  Widget build(BuildContext context) {
    log('-------------------------------------------------------------');
    log('Recent Inbox Screen Build is Called ');
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColor.orange,
            width: double.infinity,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Recent Inboxes',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColor.white, fontSize: 20),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
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
                          final List recentMassages = [];

                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map id = document.data() as Map<String, dynamic>;
                            recentMassages.add(id);
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
                              recentMassages.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.only(top: 30.0),
                                      child: Center(
                                        child: Text(
                                          'No Recent Inbox',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              for (int i = 0;
                                  i < recentMassages.length;
                                  i++) ...[
                                recentMassages[i]['User Email'] ==
                                        currentUserEmail
                                    ? Container()
                                    : CustomRecentChatsTile(
                                        name: recentMassages[i]['User Name'],
                                        email: recentMassages[i]['User Email'],
                                        imagePath: recentMassages[i]
                                            ['Image URL'],
                                        currentStatus: recentMassages[i]
                                            ['User Current Status'],
                                      ),
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
