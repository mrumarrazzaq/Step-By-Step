// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/security_section/signIn_screen.dart';
import 'package:stepbystep/screens/user_profile_section/profile_section_detail.dart';

String image = '';

class ProfileHeader extends StatefulWidget {
  String userName;
  String imageURL;

  ProfileHeader({required this.userName, required this.imageURL, Key? key})
      : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  bool _isLoading = false;

  uploadImage(String path) async {
//    final user = FirebaseAuth.instance.currentUser;
//    close = context.showLoading(msg: "Uploading", textColor: Colors.white);
    setState(() {
      _isLoading = true;
    });
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("profileImages/$currentUserEmail");
    UploadTask uploadTask = ref.putFile(File(path));
    await uploadTask.whenComplete(() async {
      String url = await ref.getDownloadURL();
      log('----------------------------------');
      log('url : $url');
      updateImage(url);
      setState(() {});
    }).catchError((onError) {
      log('---------------------------------------');
      log('Error while uploading image');
      log(onError);
    });
  }

  updateImage(url) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(user!.email)
          .update({'Image URL': url});

      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(user.email)
          .get()
          .then((ds) {
        widget.imageURL = ds['Image URL'];
      });

      setState(() {});
    } catch (e) {
      log(e.toString());
    }
    await Future.delayed(Duration(milliseconds: 500), close);
    setState(() {
      _isLoading = false;
      imageUrl = url;
    });
  }

  pickImage() async {
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
    );
    final path = result!.path;
    log('------------------------------------');
    log('Image Path : $path');
    image = path;
    uploadImage(path);
  }

  dynamic close;
  String imageUrl = "";
  String personName = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: SingleChildScrollView(
        child: profileHead(),
      ),
    );
  }

  Widget profileHead() {
    try {
      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              //main container
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.orange,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                top: -50,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: widget.imageURL.isEmpty
                      ? Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColor.orange,
                            shape: BoxShape.circle,
                            border: Border.all(width: 5, color: Colors.white),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              widget.userName[0],
                              style: GoogleFonts.righteous(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                        )
                      : Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(
                              image: NetworkImage(widget.imageURL.toString()),
                              fit: BoxFit.cover,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(width: 5, color: Colors.white),
                          ),
                        ),
                ),
              ),
              //Pick a image from gallery
              Positioned.fill(
                left: 95.0,
                top: 30.0,
                child: GestureDetector(
                  onTap: () async {
                    pickImage();
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 85,
                    ),
                    Text(
                      widget.userName,
                      style: GoogleFonts.righteous(
                          fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
              _isLoading == true
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 150,
                              height: 95,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12.0),
                              )),
                        ),
                        Positioned.fill(
                          top: -10,
                          child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              color: AppColor.orange,
                              backgroundColor: AppColor.white,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          top: 58,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text('Uploading Image',
                                style: TextStyle(color: AppColor.white)),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 22),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileSectionDetail()));
                    },
                    child: ListTile(
                      title: Text('Account'),
                      leading: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.black,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      title: Text('About Us'),
                      leading: Icon(
                        Icons.info,
                        size: 30,
                        color: Colors.black,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()),
                          (route) => false);
                    },
                    child: ListTile(
                      title: Text("Log Out"),
                      leading: Icon(
                        Icons.logout,
                        size: 30,
                        color: Colors.black,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      log(e.toString());
    }
    return Center(
      child: CircularProgressIndicator(
        color: AppColor.orange,
      ),
    );
  }
}
