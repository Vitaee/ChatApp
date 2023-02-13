import 'dart:convert';

import 'package:auth_app/common/avatar.dart';
import 'package:auth_app/common/myglobals.dart';
import 'package:auth_app/common/notifications.dart';
import 'package:auth_app/models/message_data.dart';
import 'package:auth_app/common/myglobals.dart' as globals;
import 'package:auth_app/screens/home/pages/private_messageui.dart';
import 'package:auth_app/services/scrapchats.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({Key? key}) : super(key: key);
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  //final FirebaseMessaging fcm = FirebaseMessaging.instance;
  //late WebSocketChannel home_channel;

  @override
  void initState() {
    print("[LOG] Connection in home page");
    globals.home_channel = IOWebSocketChannel.connect(
        "ws://${globals.prodUrl}/api/chats/${globals.currentUsername}/",
        headers: {"Current-User": globals.currentUsername});

    asyncMethods();

    listenNotifications();

    super.initState();
  }

  void asyncMethods() async {
    dynamic deviceTokenOfUser = await fcm.getToken();
    await postFcmToken(deviceTokenOfUser);
    await callNotif();
  }

  Future callNotif() async {
    await Notifications.init(fcm);
  }

  Future postFcmToken(dynamic fcm_token) async {
    final Dio dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jwt = prefs.getString("jwt");
    dynamic res;
    BaseOptions options = BaseOptions(
        responseType: ResponseType.plain,
        headers: {
          "Current-User": globals.currentUsername,
          'Authorization': "Bearer ${jwt}"
        });
    dio.options = options;
    try {
      res = await dio.post("http://${globals.prodUrl}/api/user/deviceToken/",
          data: {"fcm_token": fcm_token});
    } catch (err) {
      print(err);
    }
  }

  void listenNotifications() =>
      Notifications.onNotifications.stream.listen(onClickedNotif);

  void onClickedNotif(NotificationResponse? notif) {
    String parsed = notif!.payload!.toString();

    List<MessageData> notif_data = json
        .decode(parsed)["chats"]
        .map((e) => MessageData.fromJson(e))
        .toList();

    Navigator.of(context).push(ChatScreen.route(notif_data.last));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: globals.home_channel.stream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          if (snapshot.data.toString().length > 5) {
            try {
              List parsed = snapshot.data != null
                  ? json.decode(snapshot.data)["chats"]
                  : [];
              List<MessageData> list =
                  parsed.map((e) => MessageData.fromJson(e)).toList();
            } catch (err) {
              globals.home_channel = IOWebSocketChannel.connect(
                  "ws://${globals.prodUrl}/api/chats/${globals.currentUsername}/",
                  headers: {"Current-User": globals.currentUsername});
            }
            return Stack(
              children: [
                Align(
                  child: Text("Hello ${globals.currentUsername}"),
                  alignment: Alignment.topCenter,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: MessageTiles(),
                )
              ],
            );
          } else {
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Center(
                      child: Text(
                          "Text with someone! ${globals.currentUsername}!"),
                    );
                  }, childCount: 1),
                ),
              ],
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    print("home channel closing!!");
    await globals.home_channel.sink.close(status.goingAway);
  }
}

class MessageTiles extends StatefulWidget {
  const MessageTiles({Key? key}) : super(key: key);
  @override
  _MessageTilesState createState() => _MessageTilesState();
}

class _MessageTilesState extends State<MessageTiles> {
  //late final Future myFuture;

  @override
  void initState() {
    //myFuture = getChats();
    print("MESSAGE TILES**********************");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getChats(), //myFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            if (snapshot.data.length >= 1) {
              return CustomScrollView(slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return InkWell(
                      onTap: () async => {
                        //await globals.home_channel.sink.close(status.goingAway),
                        Navigator.of(context)
                            .push(ChatScreen.route(snapshot.data[index]))
                      },
                      child: Container(
                        height: 100,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Avatar.medium(
                                  url: snapshot.data[index].profilePic
                                      .toString()
                                      .replaceAll('185', 'http://185'),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        snapshot.data[index].recvUsername,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            letterSpacing: 0.2,
                                            wordSpacing: 1.5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: lastMessage(snapshot.data[index]),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 4,
                                    ),
                                    lastMessageDate(snapshot.data[index]),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Center(
                                      child: Text(
                                        "2",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: snapshot.data.length),
                )
              ]);
            } else {
              return Center(
                child: Text(
                  "Text with someone!",
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget lastMessage(dynamic data) {
    if (data.recvUsername1 != globals.currentUsername) {
      return Text("You: " + data.lastMessage.toString(),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ));
    } else {
      return Text("${data.recvUsername}" + ": " + data.lastMessage.toString(),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 12,
              color: data.sawbyUser.toString() == 'false'
                  ? Colors.red
                  : Colors.white));
    }
  }

  Widget lastMessageDate(dynamic data) {
    return Text(
      data.lastMessageDate.toString().split(" ")[0],
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: -0.2,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    print("home channel closing!! from message tiles*********");
    //await globals.home_channel.sink.close(status.goingAway);
  }
}
