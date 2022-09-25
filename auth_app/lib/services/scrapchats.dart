import 'dart:convert';

import 'package:auth_app/models/message_data.dart';
import 'package:dio/dio.dart';

import 'package:auth_app/common/myglobals.dart' as globals;

Future<List<MessageData>> getChats() async {
  final Dio dio = Dio();
  BaseOptions options = BaseOptions(
      responseType: ResponseType.plain,
      headers: {"Current-User": globals.currentUsername});
  dio.options = options;

  try {
    final res = await dio.get("http://185.250.192.69:8080/api/user/chats");
    if (res.statusCode == 404) {
      print(res.statusCode);
      return [];
    }

    final List parsed = json.decode(res.data)["chats"];

    List<MessageData> list =
        parsed.map((e) => MessageData.fromJson(e)).toList();

    return list;
  } on Exception catch (e) {
    print(e);
    return [];
  }
}
