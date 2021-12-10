import 'package:auth_app/models/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<User?> currentUser() async {
  final Dio dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    String? jwt = prefs.getString("jwt");

    Response response = await dio
        .get("http://10.0.2.2:8080/api/user/", queryParameters: {"token": jwt});

    User data = User.fromJson(response.data);

    return data;
  } on Exception catch (e) {
    return null;
  }
}