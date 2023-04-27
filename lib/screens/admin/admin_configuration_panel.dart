import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:stepbystep/colors.dart';

class AdminConfigurationPanel extends StatefulWidget {
  const AdminConfigurationPanel({Key? key}) : super(key: key);

  @override
  State<AdminConfigurationPanel> createState() =>
      _AdminConfigurationPanelState();
}

class _AdminConfigurationPanelState extends State<AdminConfigurationPanel> {
  final Stream<QuerySnapshot> _userData = FirebaseFirestore.instance
      .collection('User Data')
      .orderBy('Created At', descending: true)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
          stream: _userData,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
              final List storedUserData = [];
              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map id = document.data() as Map<String, dynamic>;
                storedUserData.add(id);
                id['id'] = document.id;
              }).toList();

              return Column(
                children: [
                  for (int i = 0; i < storedUserData.length; i++) ...[
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 3),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: ListTile(
                          leading: ClipRRect(
                            borderRadius: storedUserData[i]['Image URL'].isEmpty
                                ? BorderRadius.circular(0)
                                : BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl:
                                  storedUserData[i]['Image URL'].toString(),
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColor.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 60,
                                width: 60,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColor.white,
                                ),
                                child: Image.asset(
                                  'logos/user.png',
                                  width: 20,
                                ),
                              ),
                            ),
                          ),
                          title: Text(storedUserData[i]['User Name']),
                          subtitle: Text(storedUserData[i]['User Email']),
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: storedUserData[i]['Verify Account']
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16)
                              : const Icon(Icons.close,
                                  color: Colors.red, size: 16),
                        ),
                        childrenPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          CheckboxListTile(
                            title: const Text('Verified Account'),
                            value: storedUserData[i]['Verify Account'],
                            onChanged: (value) async {
                              await updateUserAccount(
                                email: storedUserData[i]['User Email'],
                                fieldName: 'Verify Account',
                                fieldValue: value!,
                              );
                            },
                          ),
                          CheckboxListTile(
                            title: const Text(
                              'Paid Account',
                            ),
                            value: storedUserData[i]['Paid Account'],
                            onChanged: (value) async {
                              await updateUserAccount(
                                email: storedUserData[i]['User Email'],
                                fieldName: 'Paid Account',
                                fieldValue: value!,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
    );
  }

  updateUserAccount(
      {required String email,
      required String fieldName,
      required bool fieldValue}) async {
    await FirebaseFirestore.instance.collection('User Data').doc(email).update({
      fieldName: fieldValue,
    });
  }
}
