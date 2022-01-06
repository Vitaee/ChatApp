import 'dart:convert';

import 'package:auth_app/models/private_messages.dart';
import 'package:dio/dio.dart';

Future<List<DirectMessages>?> getMessages(String roomName) async {
  final Dio dio = Dio();
  BaseOptions options = BaseOptions(
      baseUrl: "http://192.168.254.4:8080/api/messages/$roomName/",
      responseType: ResponseType.plain);
  dio.options = options;

  try {
    final res =
        await dio.get("http://192.168.254.4:8080/api/messages/$roomName/");
    //await dio.get("http://10.80.1.165:8080/api/messages/$roomName/");

    final List parsed = json.decode(res.data);

    List<DirectMessages> list =
        parsed.map((e) => DirectMessages.fromJson(e)).toList();

    return list;
  } on Exception catch (e) {
    print(e);
    return null;
  }
}
