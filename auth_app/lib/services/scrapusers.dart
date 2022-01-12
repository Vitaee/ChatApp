import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:auth_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FetchUser {
  var data = [];

  List<User> results = [];

  String fetchUrl = "http://10.80.1.165:8080/api/user/filter";

  Future<List<User>> getUserList(String query) async {
    final Dio dio = Dio();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString("jwt");
      BaseOptions options = BaseOptions(
        responseType: ResponseType.plain,
        headers: {"Authorization": "Bearer ${jwt}"},
      );
      dio.options = options;

      final res = await dio.post(fetchUrl + "/" + "$query");
      if (res.statusCode == 404) {
        return [];
      }

      final List parsed = json.decode(res.data)["result"];

      List<User> list = parsed.map((e) => User.fromJson(e)).toList();

      return list;
    } on Exception catch (e) {
      return [];
    }
  }
}
