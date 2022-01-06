// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:auth_app/common/avatar.dart';
import 'package:auth_app/common/glowing_action_button.dart';
import 'package:auth_app/models/message_data.dart';
import 'package:auth_app/models/private_messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatelessWidget {
  static Route route(MessageData data) => MaterialPageRoute(
        builder: (context) => ChatScreen(
          messageData: data,
        ),
      );

  const ChatScreen({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

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
                child: Icon(
                  CupertinoIcons.phone_solid,
                  size: 26,
                  //onTap: () {},
                ),
              ),
            ),
          ],
        ),
        body: MessageSendBar(
            //roomName: "${messageData.recvUsername}-${messageData.currentUser}",
            roomName: "room1",
            sourceUser: messageData.currentUser!,
            targetUser: messageData.recvUsername));
  }
}

class MessageSendBar extends StatefulWidget {
  MessageSendBar(
      {Key? key,
      required this.roomName,
      required this.sourceUser,
      required this.targetUser})
      : super(key: key);

  String roomName;
  String sourceUser;
  String? targetUser;

  late WebSocketChannel channel = IOWebSocketChannel.connect(
      "ws://10.80.1.165:8080/api/chat/$roomName/$sourceUser");

  @override
  _MessageSendBarState createState() => _MessageSendBarState();
}

class _MessageSendBarState extends State<MessageSendBar> {
  TextEditingController text_controller = TextEditingController();
  List<dynamic> messages = [];
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
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState != ConnectionState.waiting) {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      if (messages[index].user == widget.sourceUser) {
                        return _MessageOwnTile(
                            message: messages[index].data,
                            messageDate: "21:05 PM");
                      } else {
                        return _MessageTile(
                            message: messages[index].data,
                            messageDate: "21:05 PM");
                      }
                    },
                    itemCount: messages.length,
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
          '[{ "type":"entrance", "data":"${text_controller.text}", "room_name":"${widget.roomName}", "user":"${widget.sourceUser}", "target_user":"${widget.targetUser}" }]');

      DirectMessages message = DirectMessages(
          type: "entrance",
          data: text_controller.text,
          room_name: widget.roomName,
          user: widget.sourceUser,
          target_user: widget.targetUser,
          time: DateTime.now().toString().substring(10, 16));
      messages.add(message);
      text_controller.clear();
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}

class _DemoMessageList extends StatelessWidget {
  const _DemoMessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        children: const [
          _DateLable(lable: 'Yesterday'),
          _MessageOwnTile(message: "message", messageDate: "21:05 PM"),
          _MessageTile(message: "message2", messageDate: "21:06 PM")
        ],
      ),
    );
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
                messageDate,
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
                messageDate,
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
                messageData.recvUsername!,
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

class _ActionBottomBar extends StatelessWidget {
  const _ActionBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: TextField(
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
              onPressed: () {
                print('TODO: send a message');
              },
            ),
          ),
        ],
      ),
    );
  }
}
