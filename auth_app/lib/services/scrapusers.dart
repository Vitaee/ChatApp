import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:auth_app/models/user.dart';
import 'package:auth_app/common/myglobals.dart' as globals;

class FetchUser {
  String fetchUrl = "http://10.80.1.165:8080/api/user/filter";

  Future<List<User>> getUserList(String query) async {
    try {
      final Dio dio = Dio();
      BaseOptions options = BaseOptions(
        responseType: ResponseType.plain,
        headers: {"Current-User": globals.currentUsername},
      );
      dio.options = options;

      final res = await dio.post(fetchUrl + "/" + "$query");

      List parsed = json.decode(res.data);

      print(parsed);
      print("object");
      print("la burda degil mi");
      List<User> list = parsed.map((e) => User.fromJson(e)).toList();
      print("\n");
      print(list[0]);
      print("\n");
      return list;
    } on Exception catch (e) {
      print(e);
      return [];
    }
  }
}
