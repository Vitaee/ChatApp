import 'dart:convert';

import 'package:auth_app/common/avatar.dart';
import 'package:auth_app/models/message_data.dart';
import 'package:auth_app/common/myglobals.dart' as globals;
import 'package:auth_app/screens/home/pages/private_messageui.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({Key? key}) : super(key: key);

  final WebSocketChannel listen_messsage = globals.listen_message;

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.listen_messsage.stream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          if (snapshot.data.length >= 1) {
            List parsed = json.decode(snapshot.data)["chats"];

            List<MessageData> list =
                parsed.map((e) => MessageData.fromJson(e)).toList();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Stories(),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _MessageTile(messageData: list[index]);
                    },
                    childCount: list.length,
                  ),
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
    widget.listen_messsage.sink.close();
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(ChatScreen.route(messageData));
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Avatar.medium(url: messageData.profilePic),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        globals.currentUsername ==
                                messageData.recvUsername.toString()
                            ? messageData.recvUsername1.toString()
                            : messageData.recvUsername.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            letterSpacing: 0.2,
                            wordSpacing: 1.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: _buildLastMessage(),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    _buildLastMessageAt(),
                    const SizedBox(
                      height: 8,
                    ),
                    Center(
                        child: Text(
                      "2", // this data should be dynamic
                      style: TextStyle(color: Colors.white),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastMessage() {
    // check if message sender == current user.
    /* globals.currentUsername ==
                                messageData.recvUsername.toString()
                            ? messageData.recvUsername1.toString()
                            : messageData.recvUsername.toString(),*/
    if (messageData.recvUsername1 == globals.currentUsername) {
      // other user should be dynamic.
      return Text(
        "Other User: " + messageData.lastMessage.toString(),
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 12,
            color: messageData.sawbyUser.toString() == 'false'
                ? Colors.red
                : Colors.white),
      );
    } else {
      return Text("You" + ": " + messageData.lastMessage.toString(),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ));
    }
  }

  Widget _buildLastMessageAt() {
    return Text(
      messageData.lastMessageDate.toString().split(" ")[0],
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
