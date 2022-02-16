// ignore_for_file: must_be_immutable
import 'dart:convert';

import 'package:auth_app/common/avatar.dart';
import 'package:auth_app/common/glowing_action_button.dart';
import 'package:auth_app/common/notifications.dart';
import 'package:auth_app/models/message_data.dart';
import 'package:auth_app/models/private_messages.dart';
import 'package:auth_app/screens/home/home.dart';
import 'package:auth_app/screens/home/pages/voicecallui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:auth_app/common/myglobals.dart' as globals;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatelessWidget {
  static Route route(MessageData data, home_channel) => MaterialPageRoute(
        builder: (context) => ChatScreen(
          messageData: data,
          home_channel: home_channel,
        ),
      );

  ChatScreen({
    Key? key,
    required this.messageData,
    required this.home_channel,
  }) : super(key: key);

  final MessageData messageData;
  final WebSocketChannel home_channel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: false,
        backgroundColor: Color(0xff3a434d),
        elevation: 0,
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: InkWell(
              child: Icon(
                CupertinoIcons.back,
                size: 28,
              ),
              onTap: () {
                Navigator.of(context).pop();
              }),
        ),
        title: _AppBarTitle(
          messageData: messageData,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Icon(
                CupertinoIcons.video_camera_solid,
                size: 26,
                //onTap: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: InkWell(
                child: Icon(
                  CupertinoIcons.phone_solid,
                  size: 26,
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => VoiceCallUI()));
                },
              ),
            ),
          ),
        ],
      ),
      body: MessageSendBar(
          roomName: "room1",
          sourceUser: globals.currentUsername,
          targetUser: messageData.recvUsername,
          home_channel: home_channel),
    );
  }
}

class MessageSendBar extends StatefulWidget {
  MessageSendBar(
      {Key? key,
      required this.roomName,
      required this.sourceUser,
      required this.targetUser,
      required this.home_channel
      //required this.data})
      })
      : super(key: key);

  String roomName;
  String sourceUser;
  String? targetUser;
  late WebSocketChannel home_channel;
  //List<dynamic>? data;

  late WebSocketChannel channel =
      IOWebSocketChannel.connect("ws://10.80.1.167:8080/api/chat/$roomName/",
          //"ws://192.168.254.4:8080/api/chat/$roomName/",
          headers: {"Current-User": sourceUser});

  @override
  _MessageSendBarState createState() => _MessageSendBarState();
}

class _MessageSendBarState extends State<MessageSendBar> {
  TextEditingController text_controller = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0);

  // write func to update saw messages by target user.
  /*Future updateSeenMessage() async {
  
  }*/

  @override
  void initState() {
    super.initState();

    //_scrollController.animateTo(_scrollController.position.maxScrollExtent,
    //   duration: Duration(milliseconds: 100), curve: Curves.easeOut);
    //SchedulerBinding.instance!.addPostFrameCallback((_) {
    //  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // });

    Notif.init();
    listenNotifications();
  }

  void listenNotifications() =>
      Notif.onNotifications.stream.listen(onClickedNotif);

  void onClickedNotif(String? payload) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => HomeScaffold()));
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            // _DateLable(lable: "Yestarday"),
            child: StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, dynamic snapshot) {
                if (snapshot.connectionState != ConnectionState.waiting) {
                  List parsed = json.decode(snapshot.data);

                  List<DirectMessages> list =
                      parsed.map((e) => DirectMessages.fromJson(e)).toList();
                  //if (list.length >= 1) {
                  //  scrollIt();
                  //}

                  return ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (list[index].data != null) {
                        if (list[index].user == widget.sourceUser) {
                          return _MessageOwnTile(
                              message: list[index].data.toString(),
                              messageDate:
                                  list[index].date_sended.split(" ")[1]);
                        } else {
                          return _MessageTile(
                              message: list[index].data.toString(),
                              messageDate:
                                  list[index].date_sended.split(" ")[1]);
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                    itemCount: snapshot.data != null ? list.length : 0,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),
        SafeArea(
          bottom: true,
          top: false,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: 2,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: Icon(
                    CupertinoIcons.camera_fill,
                    size: 28,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: TextField(
                    controller: text_controller,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Type something...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 10.0,
                  bottom: 5,
                ),
                child: GlowingActionButton(
                  color: Color(0xfff4ac47), //Colors.accent,
                  icon: Icons.send_sharp,
                  onPressed: sendData,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void sendData() {
    if (text_controller.text.isNotEmpty) {
      widget.channel.sink.add(
          '[{ "type":"entrance", "data":"${text_controller.text}", "room_name":"${widget.roomName}", "user":"${widget.sourceUser}", "target_user":"${widget.targetUser}", "msg_saw_by_tusr":"false", "date_sended":"${DateTime.now()}" }]');

      /*Notif.showNotif(
          title: widget.sourceUser,
          body: text_controller.text,
          payload: 'dynamic payload');*/
      // send new message for notification
      //globals.listen_message.sink.add(
      widget.home_channel.sink.add(
          '[{ "type":"entrance", "data":"${text_controller.text}", "room_name":"${widget.roomName}", "user":"${widget.sourceUser}", "target_user":"${widget.targetUser}", "msg_saw_by_tusr":"false", "date_sended":"${DateTime.now()}"   }]');

      text_controller.clear();
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 85,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.channel.sink.close();
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.message,
    required this.messageDate,
  }) : super(key: key);

  final String message;
  final String messageDate;

  static const _borderRadius = 26.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xff59bee6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  topRight: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                messageDate.split(".")[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({
    Key? key,
    required this.message,
    required this.messageDate,
  }) : super(key: key);

  final String message;
  final String messageDate;

  static const _borderRadius = 26.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xfff4ac47),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                  bottomLeft: Radius.circular(_borderRadius),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
                child: Text(message,
                    style: const TextStyle(
                      color: Color(0xff3a434d),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                messageDate.split(".")[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DateLable extends StatelessWidget {
  const _DateLable({
    Key? key,
    required this.lable,
  }) : super(key: key);

  final String lable;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
            child: Text(
              lable,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Avatar.small(
          url: messageData.profilePic,
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                globals.currentUsername == messageData.recvUsername.toString()
                    ? messageData.recvUsername1.toString()
                    : messageData.recvUsername.toString(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 2),
              const Text(
                'Online now',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff59bee6),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
