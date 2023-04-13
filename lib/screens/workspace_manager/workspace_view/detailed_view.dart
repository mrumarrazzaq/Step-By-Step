import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/colors.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:stepbystep/visualization/visualization.dart';

class DetailedView extends StatefulWidget {
  DetailedView({
    Key? key,
    required this.workspaceName,
    required this.workspaceCode,
    required this.role,
    required this.assignedBy,
    required this.level,
  }) : super(key: key);
  String workspaceCode;
  String workspaceName;
  String role;
  String assignedBy;
  int level;
  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  List<dynamic> membersList = [];
  List<dynamic> allowedMembers = [];
  bool isLoading = true;
  final Stream<QuerySnapshot> userRecords = FirebaseFirestore.instance
      .collection('User Data')
      // .orderBy('Created At', descending: true)
      .snapshots();

  String assignedRole = '';
  double _width = 0;
  getWorkspaceMembers() async {
    final value = await FirebaseFirestore.instance
        .collection("Workspaces")
        .doc(widget.workspaceCode)
        .get();

    setState(() {
      membersList = value.data()!['Workspace Members'];
      isLoading = true;
      print(membersList.toString());
    });
    for (var member in membersList) {
      getUserRole(member);
    }
  }

  getUserRole(String email) async {
    await FirebaseFirestore.instance
        .collection('User Data')
        .doc(email)
        .collection('Workspace Roles')
        .doc(widget.workspaceCode)
        .get()
        .then((ds) {
      assignedRole = ds['Role'];
      assignedRole = '$assignedRole ${ds['Level']}';
      print(assignedRole);
      if (assignedRole == '${widget.role} ${widget.level}') {
        allowedMembers.add(email);
      }
    });
    setState(() {
      isLoading = false;
    });
    print('Allowed Members');
    print(allowedMembers);
  }

  @override
  void initState() {
    super.initState();
    getWorkspaceMembers();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _width = double.infinity;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workspaceName,
          style:
              TextStyle(color: AppColor.darkGrey, fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColor.white,
        bottom: PreferredSize(
          preferredSize: const Size(30, 50),
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 5.0),
            width: double.infinity,
            color: AppColor.black,
            child: Center(
              child: Text(
                'Level ${widget.level}',
                style: GoogleFonts.inconsolata(
                    color: AppColor.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 40.0),
              child: DottedLine(
                direction: Axis.vertical,
                lineLength: double.infinity,
                lineThickness: 5.0,
                dashLength: 8.0,
                dashColor: Colors.black,
                dashGradient: [AppColor.grey, AppColor.grey],
                dashRadius: 0.0,
                dashGapLength: 7.0,
                dashGapColor: Colors.transparent,
                dashGapGradient: [AppColor.transparent, AppColor.transparent],
                dashGapRadius: 0.0,
              ),
            ),
            ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Root(role: widget.role, totalMembers: allowedMembers.length),
                isLoading && allowedMembers.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 160.0,
                          vertical: 20.0,
                        ),
                        child: SizedBox(
                          height: 40,
                          child:
                              CircularProgressIndicator(color: AppColor.orange),
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: userRecords,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColor.orange,
                                strokeWidth: 2.0,
                              ),
                            );
                          }
                          if (snapshot.hasData) {
                            List storedUserData = [];

                            snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map id = document.data() as Map<String, dynamic>;
                              storedUserData.add(id);
                              id['id'] = document.id;
                            }).toList();
                            return Column(
                              children: [
                                for (int i = 0;
                                    i < storedUserData.length;
                                    i++) ...[
                                  if (allowedMembers.contains(
                                      storedUserData[i]['User Email'])) ...[
                                    Connector(
                                      workspaceCode: widget.workspaceCode,
                                      workspaceName: widget.workspaceName,
                                      email: storedUserData[i]['User Email'],
                                      name: storedUserData[i]['User Name'],
                                      imageUrl: storedUserData[i]['Image URL'],
                                      width: _width,
                                    ),
                                  ],
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
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Root extends StatelessWidget {
  Root({Key? key, required this.role, required this.totalMembers})
      : super(key: key);
  String role;
  int totalMembers;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 55, left: 40.0),
          child: DottedLine(
            direction: Axis.horizontal,
            lineLength: MediaQuery.of(context).size.width / 2,
            lineThickness: 5.0,
            dashLength: 8.0,
            dashColor: Colors.black,
            dashGradient: [AppColor.grey, AppColor.grey],
            dashRadius: 0.0,
            dashGapLength: 7.0,
            dashGapColor: Colors.transparent,
            dashGapGradient: [AppColor.transparent, AppColor.transparent],
            dashGapRadius: 0.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 48),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: AppColor.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 13.0),
          child: Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: AppColor.orange,
              child: Text(
                totalMembers.toString(),
                style: GoogleFonts.oswald(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 120.0, right: 2, left: 2),
          child: Center(
            child: Text(
              role,
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Connector extends StatelessWidget {
  Connector({
    Key? key,
    required this.workspaceCode,
    required this.workspaceName,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.width,
  }) : super(key: key);
  String workspaceCode;
  String workspaceName;
  String name;
  String email;
  String imageUrl;
  double width;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastOutSlowIn,
      width: width,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 48, left: 40.0),
            child: DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 5.0,
              dashLength: 8.0,
              dashColor: Colors.black,
              dashGradient: [AppColor.grey, AppColor.grey],
              dashRadius: 0.0,
              dashGapLength: 7.0,
              dashGapColor: Colors.transparent,
              dashGapGradient: [AppColor.transparent, AppColor.transparent],
              dashGapRadius: 0.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, top: 40),
            child: CircleAvatar(
              radius: 10,
              backgroundColor: AppColor.grey,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Visualization(
                      workspaceCode: workspaceCode,
                      userEmail: email,
                      workspaceName: workspaceName,
                      userName: name),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(
                left: 80,
                bottom: 10,
                top: 15,
                right: 10,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColor.orange, width: 10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10000.0),
                          child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              // maxWidthDiskCache: 500,
                              // maxHeightDiskCache: 500,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                    height: 200,
                                    width: 200,
                                    color: AppColor.white,
                                  ),
                              errorWidget: (context, url, error) => Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: AppColor.orange.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'logos/user.png',
                                        width: 50,
                                        color: AppColor.white,
                                      ),
                                    ),
                                  )),
                        ),
                        // CircleAvatar(
                        //   backgroundColor: AppColor.orange.withOpacity(0.2),
                        //   radius: 32,
                        //   backgroundImage: AssetImage(
                        //     'logos/user.png',
                        //   ),
                        //   foregroundImage: imageUrl.isNotEmpty
                        //       ? NetworkImage(imageUrl)
                        //       : null,
                        // ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Lottie.asset(
                          repeat: false, height: 30, 'animations/graph.json'),
                    ],
                  ),
                ),
              ),

              // ListTile(
              //   minLeadingWidth: 0,
              //   leading: CircleAvatar(radius: 30, backgroundColor: AppColor.orange),
              //   title: Text(
              //     'Umar',
              //     style: TextStyle(fontWeight: FontWeight.bold),
              //   ),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
