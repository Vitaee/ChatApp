import 'dart:convert';

import 'package:auth_app/common/avatar.dart';
import 'package:auth_app/models/message_data.dart';
import 'package:auth_app/models/user.dart';
import 'package:auth_app/screens/home/pages/private_messageui.dart';
import 'package:auth_app/common/myglobals.dart' as globals;
import 'package:auth_app/services/scrapusers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchUser extends SearchDelegate {
  // write future to fetch other users
  //FetchUser _userList = FetchUser();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Future<List<User>> getUserList(String query) async {
    try {
      final Dio dio = Dio();
      BaseOptions options = BaseOptions(
        responseType: ResponseType.plain,
        headers: {"Current-User": globals.currentUsername},
      );
      dio.options = options;

      final res = await dio
          .post("http://10.80.1.165:8080/api/user/filter" + "/" + "$query");

      final List parsed = json.decode(res.data);
      List<User> list = parsed.map((e) => User.fromJson(e)).toList();

      return list;
    } on Exception catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
        //future: _userList.getUserList(query),
        future: getUserList(query),
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
                              url: snapshot.data[index].image.replaceAll(
                                  'localhost', 'http://10.80.1.165')),
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
                          profilePic: snapshot.data[index].image,
                          lastMessageDate: "",
                          recvUsername: snapshot.data[index].username,
                          sawbyUser: "false");
                      Navigator.of(context).push(ChatScreen.route(msg));
                    },
                  );
                },
              );
            } else {
              print("\n");
              print(snapshot.data);
              print("\n");
              return Center(
                child: Text("User you search does not exist!"),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Search User'),
    );
  }
}
