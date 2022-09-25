import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../common/avatar.dart';
import '../../models/message_data.dart';
import '../../models/user.dart';
import '../home/pages/private_messageui.dart';
import 'package:auth_app/common/myglobals.dart' as globals;
import 'package:dio/dio.dart';

class SearchUserPage extends StatefulWidget {
  SearchUserPage({Key? key}) : super(key: key);

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  Future<List<User>> getUserList() async {
    try {
      final Dio dio = Dio();
      BaseOptions options = BaseOptions(
        responseType: ResponseType.plain,
        headers: {"Current-User": globals.currentUsername},
      );
      dio.options = options;

      final res = await dio.post("http://185.250.192.69:8080/api/user/filter/");

      if (res.statusCode == 404) {
        return [];
      }
      final List parsed = json.decode(res.data);
      List<User> list = parsed.map((e) => User.fromJson(e)).toList();

      return list;
    } on Exception catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserList(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    child: ListTile(
                      title: Row(
                        children: [
                          Avatar.medium(
                              url: snapshot.data[index].image
                                  .toString()
                                  .replaceAll('185', 'http://185')),
                          SizedBox(width: 20),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${snapshot.data[index].username}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '${snapshot.data[index].email}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ])
                        ],
                      ),
                    ),
                    onTap: () {
                      //Navigator.pushNamed(context, "/home");
                      MessageData msg = MessageData(
                          currentUser: globals.currentUsername,
                          lastMessage: "",
                          profilePic: snapshot.data[index].image
                              .toString()
                              .replaceAll('185', 'http://185'),
                          lastMessageDate: "",
                          recvUsername: snapshot.data[index].username,
                          sawbyUser: "false");
                      Navigator.of(context).push(ChatScreen.route(msg));
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Text("We did not found any user yet!"),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
