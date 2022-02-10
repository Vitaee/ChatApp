import 'dart:convert';

import 'package:auth_app/common/avatar.dart';
import 'package:auth_app/models/message_data.dart';
import 'package:auth_app/common/myglobals.dart' as globals;
import 'package:auth_app/screens/home/pages/private_messageui.dart';
import 'package:auth_app/services/scrapchats.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({Key? key}) : super(key: key);
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  Future<List<MessageData>> getChats() async {
    final Dio dio = Dio();
    BaseOptions options = BaseOptions(
        responseType: ResponseType.plain,
        headers: {"Current-User": globals.currentUsername});
    dio.options = options;

    try {
      final res = await dio.get("http://10.80.1.167:8080/api/user/chats/");
      if (res.statusCode == 404) {
        return [];
      }

      final List parsed = json.decode(res.data)["chats"];

      List<MessageData> list =
          parsed.map((e) => MessageData.fromJson(e)).toList();

      return list;
    } on Exception catch (e) {
      //print(e);
      return [];
    }
  }

  WebSocketChannel? home_channel;

  @override
  void initState() {
    home_channel = IOWebSocketChannel.connect("ws://10.80.1.167:8080/api/chats",
        headers: {"Current-User": globals.currentUsername});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: home_channel!.stream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          if (snapshot.data.length >= 1) {
            List parsed = json.decode(snapshot.data)["chats"];
            List<MessageData> list =
                parsed.map((e) => MessageData.fromJson(e)).toList();

            return Stack(
              children: [
                Align(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Stories(),
                      ),
                    ],
                  ),
                  alignment: Alignment.topCenter,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 145.0),
                  child: MessageTiles(home_channel: home_channel!),
                )
              ],
            );
          } else {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Stories(),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Center(
                      child: Text("Text with someone!"),
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
  void dispose() {
    super.dispose();
    home_channel!.sink.close();
    //widget.home_channel.sink.close();
  }
}

class MessageTiles extends StatefulWidget {
  const MessageTiles({Key? key, required this.home_channel}) : super(key: key);
  final WebSocketChannel home_channel;
  @override
  _MessageTilesState createState() => _MessageTilesState();
}

class _MessageTilesState extends State<MessageTiles> {
  //late final Future myFuture;

  @override
  void initState() {
    //myFuture = getChats();
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
                      onTap: () => {
                        Navigator.of(context).push(ChatScreen.route(
                            snapshot.data[index], widget.home_channel))
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
                                  url: snapshot.data[index].profilePic,
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
}

class _Stories extends StatelessWidget {
  const _Stories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8, bottom: 16),
                child: Text(
                  'Stories',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 60,
                        child: _StoryCard(
                          profilePic:
                              "https://t4.ftcdn.net/jpg/00/84/67/19/360_F_84671939_jxymoYZO8Oeacc3JRBDE8bSXBWj0ZfA9.jpg",
                          userName: "can",
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({Key? key, required this.profilePic, required this.userName})
      : super(key: key);

  final String profilePic;
  final String userName;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar.medium(url: profilePic),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              "Username",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
