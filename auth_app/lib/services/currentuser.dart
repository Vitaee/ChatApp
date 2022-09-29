import 'package:auth_app/models/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth_app/common/myglobals.dart' as globals;

Future<User?> currentUser() async {
  final Dio dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    String? jwt = prefs.getString("jwt");

    dio.options.headers["Authorization"] = "Bearer ${jwt}";

    Response response = await dio.get("http://${globals.prodUrl}/api/user/");
    User data = User.fromJson(response.data);

    return data;
  } on Exception catch (e) {
    //print("$e");
    return null;
  }
}
