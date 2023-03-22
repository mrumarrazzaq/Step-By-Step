import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stepbystep/apis/app_functions.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/apis/messege_notification_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:dio/dio.dart';

class WorkspaceTaskTile extends StatefulWidget {
  bool isOwner;
  String userEmail;
  String workspaceCode;
  String workspaceTaskCode;
  String docId;
  String title;
  String description;
  String email;
  String date;
  int taskStatusValue;
  Color color;
  String fileURL;
  String fileName;
  bool leftButton;
  bool rightButton;
  WorkspaceTaskTile({
    Key? key,
    required this.isOwner,
    required this.userEmail,
    required this.workspaceCode,
    required this.workspaceTaskCode,
    required this.docId,
    required this.title,
    required this.description,
    required this.email,
    required this.date,
    required this.taskStatusValue,
    required this.fileName,
    required this.fileURL,
    required this.color,
    required this.leftButton,
    required this.rightButton,
  }) : super(key: key);

  @override
  State<WorkspaceTaskTile> createState() => _WorkspaceTaskTileState();
}

class _WorkspaceTaskTileState extends State<WorkspaceTaskTile> {
  final dio = Dio();
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (status == DownloadTaskStatus.complete) {
        log('Download Complete');
      }
      setState(() {});
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  Future download(String url, String fileName) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final baseStorage = await getExternalStorageDirectory();
        // String appDocPath = baseStorage!.path;
        if (!Directory("${baseStorage!.path}/SBS").existsSync()) {
          Directory("${baseStorage.path}/SBS").createSync(recursive: true);
        }
        final taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: '${baseStorage.path}/SBS',
          showNotification: true,
          openFileFromNotification: true,
        );
        // if (taskId == null) {
        //   return;
        // }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        if (widget.isOwner) {
          showTaskDeletionDialog(
            context: context,
            fileURL: widget.fileURL,
            taskTitle: widget.title,
            workspaceTaskCode: widget.workspaceTaskCode,
            docId: widget.docId,
          );
        }

        log(widget.docId);
      },
      child: Card(
        margin: const EdgeInsets.only(left: 10, bottom: 10, top: 10, right: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Container(
            width: double.infinity,
            // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.color,
              border: Border(
                right: BorderSide(color: widget.color, width: 10),
              ),
              //borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: double.infinity,
              // margin:
              // const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Task Title      :  ',
                          style: TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: widget.title,
                          style: TextStyle(
                            color: AppColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Assigned By :  ',
                          style: TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: widget.email,
                          style: TextStyle(
                            color: AppColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Due Date       :  ',
                          style: TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: widget.date,
                          style: TextStyle(
                            color: AppColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.fileName.isNotEmpty,
                    child: ExpansionTile(
                      collapsedTextColor: AppColor.black,
                      textColor: AppColor.black,
                      collapsedIconColor: AppColor.black,
                      title: const Text('Attachment'),
                      children: [
                        ListTile(
                          title: Text(widget.fileName),
                          trailing: IconButton(
                            onPressed: () async {
                              download(widget.fileURL, widget.fileName);
                            },
                            splashRadius: 30,
                            icon: const Icon(Icons.download),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: widget.leftButton,
                        child: GestureDetector(
                          onTap: () async {
                            if (widget.leftButton) {
                              log('LB Task Status Value : ${widget.taskStatusValue - 1}');
                              if (widget.taskStatusValue - 1 == 1) {
                                log('Review');
                                if (widget.isOwner) {
                                  String userName =
                                      await AppFunctions.getNameByEmail(
                                          email: currentUserEmail.toString());
                                  String workspaceName = await AppFunctions
                                      .getWorkspaceNameByWorkspaceCode(
                                          workspaceCode: widget.workspaceCode);
                                  String token =
                                      await AppFunctions.getTokenByEmail(
                                          email: widget.userEmail);
                                  MessageNotificationApi.send(
                                      token: token,
                                      title: '📝 Task Do Again',
                                      body:
                                          '$userName remove your task from review in $workspaceName workspace.');
                                } else {
                                  String userName =
                                      await AppFunctions.getNameByEmail(
                                          email: currentUserEmail.toString());
                                  String workspaceName = await AppFunctions
                                      .getWorkspaceNameByWorkspaceCode(
                                          workspaceCode: widget.workspaceCode);
                                  String token =
                                      await AppFunctions.getTokenByEmail(
                                          email: widget.email);
                                  MessageNotificationApi.send(
                                      token: token,
                                      title: '📝 Task Remove From Review',
                                      body:
                                          '$userName remove task from review in $workspaceName workspace.');
                                }
                              }
                              if (widget.taskStatusValue - 1 == 2) {
                                log('Doing');
                                String userName =
                                    await AppFunctions.getNameByEmail(
                                        email: currentUserEmail.toString());
                                String workspaceName = await AppFunctions
                                    .getWorkspaceNameByWorkspaceCode(
                                        workspaceCode: widget.workspaceCode);
                                String token =
                                    await AppFunctions.getTokenByEmail(
                                        email: widget.userEmail);
                                MessageNotificationApi.send(
                                    token: token,
                                    title: '📝 Task In-Completed do again',
                                    body:
                                        'Your task completion failed after review by $userName in $workspaceName workspace.');
                              }

                              await FirebaseFirestore.instance
                                  .collection(widget.workspaceTaskCode)
                                  .doc(widget.docId)
                                  .update({
                                'Task Status': widget.isOwner
                                    ? widget.taskStatusValue - 2
                                    : widget.taskStatusValue - 1,
                              });
                            }
                          },
                          child: RotatedBox(
                              quarterTurns: 2,
                              child: Lottie.asset(
                                  height: 20, 'animations/arrow.json')),
                        ),

                        // IconButton(
                        //   onPressed: () async {
                        //     if (leftButton) {
                        //       log('LB Task Status Value : ${taskStatusValue - 1}');
                        //       await FirebaseFirestore.instance
                        //           .collection(workspaceTaskCode)
                        //           .doc(docId)
                        //           .update({
                        //         'Task Status': isOwner
                        //             ? taskStatusValue - 2
                        //             : taskStatusValue - 1,
                        //       });
                        //     }
                        //   },
                        //   icon: const Icon(Icons.arrow_back),
                        // ),
                      ),
                      Visibility(
                        visible: widget.rightButton,
                        child: GestureDetector(
                          onTap: () async {
                            if (widget.rightButton) {
                              log('RB Task Status Value : ${widget.taskStatusValue + 1}');
                              await FirebaseFirestore.instance
                                  .collection(widget.workspaceTaskCode)
                                  .doc(widget.docId)
                                  .update({
                                'Task Status': widget.taskStatusValue + 1,
                              });
                              if (widget.taskStatusValue + 1 == 2) {
                                log('Review');
                                String userName =
                                    await AppFunctions.getNameByEmail(
                                        email: currentUserEmail.toString());
                                String workspaceName = await AppFunctions
                                    .getWorkspaceNameByWorkspaceCode(
                                        workspaceCode: widget.workspaceCode);
                                log(workspaceName);
                                String token =
                                    await AppFunctions.getTokenByEmail(
                                        email: widget.email);
                                MessageNotificationApi.send(
                                    token: token,
                                    title: '📝 Task In Review ',
                                    body:
                                        'Please review a task of $userName in $workspaceName workspace.');
                              }

                              if (widget.taskStatusValue + 1 == 3) {
                                log('Completed');
                                String userName =
                                    await AppFunctions.getNameByEmail(
                                        email: currentUserEmail.toString());
                                String workspaceName = await AppFunctions
                                    .getWorkspaceNameByWorkspaceCode(
                                        workspaceCode: widget.workspaceCode);
                                String token =
                                    await AppFunctions.getTokenByEmail(
                                        email: widget.userEmail);
                                MessageNotificationApi.send(
                                    token: token,
                                    title: '📝 Task Completed',
                                    body:
                                        'Great your task has been completed after review by $userName in $workspaceName workspace.');
                              }
                            }
                          },
                          child:
                              Lottie.asset(height: 20, 'animations/arrow.json'),
                        ),
                        // IconButton(
                        //   onPressed: () async {
                        //     if (rightButton) {
                        //       log('RB Task Status Value : ${taskStatusValue + 1}');
                        //       await FirebaseFirestore.instance
                        //           .collection(workspaceTaskCode)
                        //           .doc(docId)
                        //           .update({
                        //         'Task Status': taskStatusValue + 1,
                        //       });
                        //     }
                        //   },
                        //   icon: const Icon(
                        //     Icons.arrow_forward,
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showTaskDeletionDialog(
      {required BuildContext context,
      required String fileURL,
      required String taskTitle,
      required String workspaceTaskCode,
      required String docId}) {
    Widget cancelButton = MaterialButton(
      color: AppColor.white,
      child: const Text(
        'Cancel',
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget deleteButton = MaterialButton(
      color: Colors.red,
      child: Text(
        'Delete',
        style: TextStyle(color: AppColor.white),
      ),
      onPressed: () async {
        Navigator.pop(context);
        try {
          await FirebaseFirestore.instance
              .collection(workspaceTaskCode)
              .doc(docId)
              .delete();
          String reportId = await FireBaseApi.getDocIdByField(
              collectionName:
                  'Report ${widget.userEmail} ${widget.workspaceCode}',
              fieldName: 'Task Id',
              fieldValue: docId);
          await FirebaseFirestore.instance
              .collection('Report ${widget.userEmail} ${widget.workspaceCode}')
              .doc(reportId)
              .delete();

          if(fileURL.isNotEmpty)
            {
              await FirebaseStorage.instance.refFromURL(fileURL).delete();
            }
          
          await Fluttertoast.showToast(
            msg: 'Task Deleted Successfully', // message
            toastLength: Toast.LENGTH_SHORT, // length
            gravity: ToastGravity.BOTTOM, // location
            backgroundColor: AppColor.black,
          );
        } catch (e) {
          log(e.toString());
        }
      },
    );

    AlertDialog alert = AlertDialog(
      // title: Text(taskTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              taskTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Lottie.asset(height: 70, repeat: false, 'animations/Delete.json'),
            const SizedBox(height: 6),
            const Text("Do you want to delete Task ?"),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                cancelButton,
                deleteButton,
              ],
            ),
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future openDownloadedFile(
      {required String url, required String fileName}) async {
    final file = await downloadFile(url, fileName);
    if (file == null) return;
    log('Path : ${file.path}');
    // OpenFile.open(file.path);
  }

  Future<File?> downloadFile(String url, String name) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/$name');
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );

      final raf = file.openSync(mode: FileMode.write);
      raf.writeByteSync(response.data);
      await raf.close();
      return file;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
