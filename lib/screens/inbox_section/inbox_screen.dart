// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';

import 'package:provider/provider.dart';
import 'package:date_format/date_format.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/providers/silence_operations.dart';
import 'package:stepbystep/widgets/realtime_user_online_status.dart';

class InboxScreen extends StatefulWidget {
  InboxScreen({
    Key? key,
    required this.name,
    required this.receiverEmail,
    required this.currentStatus,
    required this.imageURL,
    required this.internetConnectionStatus,
  }) : super(key: key);
  String name;
  String imageURL;
  String receiverEmail;
  String currentStatus;
  bool internetConnectionStatus;
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  FocusNode focusNode = FocusNode();
  var chatBubbleId;
  var receiverId;
  var selectedChatBubbleId = '';
  String bubbleMessage = '';
  List<String> chatBubbleIdsList = [];

  Color selectedChatBubbleColor = Colors.blue;

  bool _isChatBubbleSelected = false;
  bool isKeyboardVisible = false;
  bool isEmojiVisible = false;
  final TextEditingController _massageController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String _message = 'default';

  final IconData _messageStatus = Icons.access_time_sharp;

  bool isTextFieldEmpty = true;
  Offset _tapPosition = const Offset(0, 0);

  saveMassages(String time, String message, int messageStatus) async {
    var senderId = await FirebaseFirestore.instance
        .collection('$currentUserEmail Chat')
        .add({
      'Message': message,
      'Reaction': '',
      'Sender Email': currentUserEmail.toString(),
      'Receiver Email': widget.receiverEmail,
      'Message Status': messageStatus,
      'Receiver Id': '',
      'Created At': DateTime.now(),
      'Time': time,
    });
    var receiverId = await FirebaseFirestore.instance
        .collection('${widget.receiverEmail} Chat')
        .add({
      'Message': message,
      'Reaction': '',
      'Sender Email': currentUserEmail.toString(),
      'Receiver Email': widget.receiverEmail,
      'Message Status': messageStatus,
      'Receiver Id': senderId.id,
      'Created At': DateTime.now(),
      'Time': time,
    });

    await senderId.update({
      'Receiver Id': receiverId.id,
    });

    log('-------------------------');
    log('Sender Id ==  ${senderId.id}');
    log('Receiver Id ==  ${receiverId.id}');
    log('Massage Send Successfully');
    log('-------------------------');
  }

  //--------------------------------------------------------------//
  CollectionReference chatEvent =
      FirebaseFirestore.instance.collection('$currentUserEmail Chat');

  Future<void> deleteChatBubble(id) {
    return chatEvent
        .doc(id)
        .delete()
        .then((value) => log('Message deleted '))
        .catchError((error) => log('Failed to delete Message $error'));
  }

  updateChatBubble(String id, String userReaction, String receiverId) async {
    log(currentUserEmail!);
    log(widget.receiverEmail);

    // await FirebaseFirestore.instance
    //     .collection('$currentUserEmail Chat')
    //     .doc(id)
    //     .update({
    //       'isCompleted': 1,
    //       'Reaction': userReaction,
    //     })
    //     .then((value) => log('Sender Message Status Updated'))
    //     .catchError((error) => log('Failed to Update $error'));

    await FirebaseFirestore.instance
        .collection('${widget.receiverEmail} Chat')
        .doc(receiverId)
        .update({
          'isCompleted': 1,
          'Reaction': userReaction,
        })
        .then((value) => log('Receiver Message Status Updated'))
        .catchError((error) => log('Failed to Update $error'));
  }

  void resetToRest() {
    setState(() {
      _isChatBubbleSelected = false;
      selectedChatBubbleId = '';
      chatBubbleIdsList.clear();
    });
  }

  //--------------------------------------------------------------//

  setProviderValue() {
    log('Setting ProviderValue');
    context.read<SilenceOperation>().setIsType(true);
  }

  @override
  Widget build(BuildContext context) {
    log('-------------------------------------------------------------');
    log('Chat Screen Build is Called ${widget.internetConnectionStatus}');
    // print('FocusManager ${FocusManager.instance.primaryFocus?.hasFocus}');

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        backwardsCompatibility: true,
        leadingWidth: 30,
        elevation: 0,
        foregroundColor: AppColor.white,
        backgroundColor: AppColor.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.imageURL.isNotEmpty
                  ? CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(widget.imageURL),
                    )
                  : CircleAvatar(
                      radius: 20.0,
                      backgroundColor: AppColor.white.withOpacity(0.4),
                      child: Text(
                        widget.name[0],
                        style: GoogleFonts.righteous(
                          fontSize: 20,
                          color: AppColor.black,
                        ),
                      ),
                    ),
              const SizedBox(width: 5),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColor.white,
                    ),
                  ),
                  RealtimeUserOnlineStatus(receiverEmail: widget.receiverEmail),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.videocam,
                color: AppColor.white,
                size: 20,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.call,
                color: AppColor.white,
                size: 20,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.more_vert,
                color: AppColor.white,
                size: 20,
              ),
              onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          _isChatBubbleSelected
              ? Hero(
                  tag: 'animate1',
                  child: Container(
                      color: AppColor.orange,
                      width: double.infinity,
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.arrow_back, color: AppColor.white),
                              onPressed: () {
                                resetToRest();
                              },
                            ),
                            // Text(
                            //   '${chatBubbleIdsList.length}',
                            //   style: TextStyle(
                            //     color: whiteColor,
                            //   ),
                            // ),
                            IconButton(
                              icon: Icon(Icons.replay, color: AppColor.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.star, color: AppColor.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: AppColor.white),
                              onPressed: () {
                                deleteChatBubble(chatBubbleId);
                                setState(() {
                                  selectedChatBubbleColor = Colors.transparent;
                                  _isChatBubbleSelected = false;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.copy, color: AppColor.white),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: bubbleMessage));
                                setState(() {
                                  selectedChatBubbleColor = Colors.transparent;
                                  _isChatBubbleSelected = false;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.share, color: AppColor.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.more_vert, color: AppColor.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      )),
                )
              : Hero(
                  tag: 'animate1',
                  child: Container(
                    color: AppColor.orange,
                    width: double.infinity,
                    height: 100,
                  ),
                ),

          //Messages
          Positioned.fill(
            bottom: isEmojiVisible ? 250 : 0,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(
                    top: _isChatBubbleSelected ? 70 : 0.0, bottom: 63.0),
                child: GestureDetector(
                  onTap: () {
                    chatBubbleIdsList.clear();
                    if (selectedChatBubbleId != '') {
                      resetToRest();
                    }
                  },
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0)),
                    ),
                    child: Scrollbar(
                      radius: const Radius.circular(30.0),
                      controller: scrollController,
                      child: ListView(
                        shrinkWrap: true,
                        reverse: true,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('$currentUserEmail Chat')
                                .orderBy('Created At', descending: false)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                log('Something went wrong');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {}

                              final List storedMassages = [];
                              if (snapshot.hasData) {
                                snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map id =
                                      document.data() as Map<String, dynamic>;
                                  storedMassages.add(id);
                                  id['id'] = document.id;
                                }).toList();
                              }
                              return Column(
//                            crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  storedMassages.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 50.0),
                                          child: Center(
                                            child: Text(
                                              'Say Hi to ${widget.name}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  for (int i = 0;
                                      i < storedMassages.length;
                                      i++) ...[
                                    storedMassages[i]['Sender Email'] ==
                                                currentUserEmail &&
                                            storedMassages[i]
                                                    ['Receiver Email'] ==
                                                widget.receiverEmail
                                        ?
                                        //Sender ChatBubble
                                        Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  chatBubbleIdsList.add(
                                                      storedMassages[i]['id']);
                                                },
                                                onTapDown: (details) {
                                                  _tapPosition =
                                                      details.globalPosition;
                                                  log(_tapPosition.toString());
                                                },
                                                onLongPress: () async {
                                                  setState(() {
                                                    _isChatBubbleSelected =
                                                        true;
                                                    bubbleMessage =
                                                        storedMassages[i]
                                                            ['Message'];
                                                    chatBubbleId =
                                                        storedMassages[i]['id'];
                                                    selectedChatBubbleId =
                                                        storedMassages[i]['id'];
                                                    receiverId =
                                                        storedMassages[i]
                                                            ['Receiver Id'];
                                                    chatBubbleIdsList.add(
                                                        selectedChatBubbleId);
                                                  });
                                                  // showReactionMenu(
                                                  //   context,
                                                  //   _tapPosition,
                                                  //   chatBubbleId,
                                                  //   receiverId,
                                                  // );
                                                  log('selectedChatBubbleId : $selectedChatBubbleId');
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  color: storedMassages[i]
                                                              ['id'] ==
                                                          selectedChatBubbleId
                                                      ? Colors.blue[100]
                                                      : AppColor.transparent,
                                                  child: ChatBubble(
                                                    clipper: ChatBubbleClipper5(
                                                        type: BubbleType
                                                            .sendBubble),
                                                    shadowColor: Colors.black,
                                                    elevation: 1.5,
                                                    alignment:
                                                        Alignment.topRight,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 10,
                                                            bottom: 8.0),
                                                    backGroundColor:
                                                        AppColor.orange,
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            storedMassages[i]
                                                                ['Message'],
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  storedMassages[
                                                                          i]
                                                                      ['Time'],
                                                                  style: TextStyle(
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                      textBaseline:
                                                                          TextBaseline
                                                                              .ideographic,
                                                                      color: Colors
                                                                              .grey[
                                                                          400],
                                                                      fontSize:
                                                                          11),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          4.0),
                                                                  child: Icon(
                                                                      storedMassages[i]['Message Status'] == 0
                                                                          ? Icons
                                                                              .check
                                                                          : Icons
                                                                              .access_time_sharp,
                                                                      size: 15,
                                                                      color: Colors
                                                                              .grey[
                                                                          400]),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Visibility(
                                              //   visible: storedMassages[i]
                                              //           ['Reaction']
                                              //       .isNotEmpty,
                                              //   child: Positioned.fill(
                                              //     left: MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.8,
                                              //     child: Align(
                                              //       alignment:
                                              //           Alignment.bottomRight,
                                              //       child: GestureDetector(
                                              //         onTapDown: (details) {
                                              //           _tapPosition = details
                                              //               .globalPosition;
                                              //           showReactionMenu(
                                              //             context,
                                              //             _tapPosition,
                                              //             storedMassages[i]['id'],
                                              //             storedMassages[i]
                                              //                 ['Receiver Id'],
                                              //           );
                                              //           print(_tapPosition);
                                              //         },
                                              //         child: Container(
                                              //           padding:
                                              //               const EdgeInsets.all(
                                              //                   4.5),
                                              //           decoration: BoxDecoration(
                                              //             color: Colors.white,
                                              //             borderRadius:
                                              //                 BorderRadius
                                              //                     .circular(50),
                                              //           ),
                                              //           child: Text(
                                              //               storedMassages[i]
                                              //                   ['Reaction']),
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          )
                                        : storedMassages[i]['Sender Email'] ==
                                                    widget.receiverEmail &&
                                                storedMassages[i]
                                                        ['Receiver Email'] ==
                                                    currentUserEmail
                                            ?
                                            //Receiver ChatBubble
                                            Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        chatBubbleIdsList.add(
                                                            storedMassages[i]
                                                                ['id']);
                                                      },
                                                      onTapDown: (details) {
                                                        _tapPosition = details
                                                            .globalPosition;
                                                        print(_tapPosition);
                                                      },
                                                      onLongPress: () async {
                                                        setState(() {
                                                          _isChatBubbleSelected =
                                                              true;
                                                          chatBubbleId =
                                                              storedMassages[i]
                                                                  ['id'];
                                                          selectedChatBubbleId =
                                                              storedMassages[i]
                                                                  ['id'];
                                                          chatBubbleIdsList.add(
                                                              selectedChatBubbleId);
                                                        });
                                                        showReactionMenu(
                                                          context,
                                                          _tapPosition,
                                                          chatBubbleId,
                                                          storedMassages[i]
                                                              ['Receiver Id'],
                                                        );
                                                        print(
                                                            'selectedChatBubbleId : $selectedChatBubbleId');
                                                      },
                                                      child: Container(
                                                        width: double.infinity,
                                                        color: storedMassages[i]
                                                                    ['id'] ==
                                                                selectedChatBubbleId
                                                            ? Colors.blue[100]
                                                            : AppColor
                                                                .transparent,
                                                        child: ChatBubble(
                                                          clipper: ChatBubbleClipper5(
                                                              type: BubbleType
                                                                  .receiverBubble),
                                                          backGroundColor:
                                                              Colors.grey[100],
                                                          shadowColor:
                                                              Colors.black,
                                                          elevation: 1.5,
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10,
                                                                  left: 10,
                                                                  bottom: 8.0),
                                                          child: Container(
                                                            constraints:
                                                                BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  storedMassages[
                                                                          i][
                                                                      'Message'],
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 5.0),
                                                                  child: Text(
                                                                    storedMassages[
                                                                            i][
                                                                        'Time'],
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        textBaseline:
                                                                            TextBaseline
                                                                                .ideographic,
                                                                        color: Colors.grey[
                                                                            500],
                                                                        fontSize:
                                                                            11),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: storedMassages[i]
                                                            ['Reaction']
                                                        .isNotEmpty,
                                                    child: Positioned.fill(
                                                      left: 10,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: GestureDetector(
                                                          onTapDown: (details) {
                                                            _tapPosition = details
                                                                .globalPosition;
                                                            showReactionMenu(
                                                              context,
                                                              _tapPosition,
                                                              storedMassages[i]
                                                                  ['id'],
                                                              storedMassages[i][
                                                                  'Receiver Id'],
                                                            );
                                                            print(_tapPosition);
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50),
                                                            ),
                                                            child: Text(
                                                                storedMassages[
                                                                        i][
                                                                    'Reaction']),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: AppColor.black,
                        size: 25.0,
                      ),
                      splashColor: AppColor.orange.withOpacity(0.3),
                      splashRadius: 10,
                      onPressed: onClickEmoji,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          onTap: () {
                            setState(() {
                              isEmojiVisible = false;
                            });
                          },
                          focusNode: focusNode,
                          // keyboardType: TextInputType.text,
                          // style: const TextStyle(color: Colors.white),
                          cursorColor: AppColor.black,

                          //autofocus: true,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              if (Provider.of<SilenceOperation>(context,
                                          listen: false)
                                      .getIsType ==
                                  false) {
                                context
                                    .read<SilenceOperation>()
                                    .setIsType(true);
                                log('setIsType To True');
                              }
                            } else {
                              if (Provider.of<SilenceOperation>(context,
                                          listen: false)
                                      .getIsType ==
                                  true) {
                                context
                                    .read<SilenceOperation>()
                                    .setIsType(false);
                                log('setIsType To False');
                              }
                            }
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            // fillColor: AppColor.white,
                            // filled: true,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide(color: AppColor.grey, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide(color: AppColor.grey, width: 1.5),
                            ),
                            hintText: 'Type Message',
                            hintStyle: TextStyle(color: AppColor.black),
                            labelStyle: TextStyle(color: AppColor.black),
                            prefixText: '  ',
                          ),
                          controller: _massageController,
                        ),
                      ),
                    ),
                    MaterialButton(
                      shape: const CircleBorder(),
                      height: 50.0,
                      minWidth: 50.0,
                      onPressed: () async {
                        if (_massageController.text.isNotEmpty) {
                          String time = formatDate(
                              DateTime.now(), [hh, ':', nn, ' ', am]);
                          _message = _massageController.text;
                          _massageController.clear();
                          context.read<SilenceOperation>().setIsType(true);
                          await saveMassages(time, _message, 0);
                        }
                      },
                      color: AppColor.orange,
                      child: Icon(
                        Provider.of<SilenceOperation>(context, listen: true)
                                .getIsType
                            ? Icons.mic
                            : Icons.send,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: isEmojiVisible,
                  child: SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      textEditingController: _massageController,
                      onEmojiSelected: (Category? category, Emoji emoji) {
                        context.read<SilenceOperation>().setIsType(false);
                      },
                      config: Config(
                        columns: 9,
                        emojiSizeMax: 20 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.30
                                : 1.0),
                      ),
                    ),
                  ),
                  /* child: Container(
                    height: 250,
                    color: AppColor.darkGrey.withOpacity(0.4),
                  ),*/
                ),

                // Visibility(
                //   visible: isEmojiVisible,
                //   // child: Container(
                //   //   height: 270,
                //   //   color: AppColor.darkGrey,
                //   // ),
                //   child: EmojiPickerWidget(),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showReactionMenu(
    BuildContext context,
    Offset position,
    String bubbleId,
    String receiverId,
  ) async {
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: 300,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'value',
          height: 35,
          textStyle: const TextStyle(color: Colors.white),
          onTap: () {},
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '👍', receiverId);
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: const Text(
                  '👍',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '❤', receiverId);
                  resetToRest();
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                icon: const Text(
                  '❤',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '😂', receiverId);
                  resetToRest();
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                icon: const Text(
                  '😂',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '😮', receiverId);
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: const Text(
                  '😮',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '😥', receiverId);
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: const Text(
                  '😥',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '🙏', receiverId);
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: const Text(
                  '🙏',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () {
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.add,
                  color: AppColor.grey,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onClickEmoji() async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    await Future.delayed(const Duration(milliseconds: 100));
    toggleEmojiKeyboard();
  }

  Future toggleEmojiKeyboard() async {
    setState(() {
      isEmojiVisible = !isEmojiVisible;
    });

    log('isEmojiVisible : $isEmojiVisible');
  }
}

///
