import 'package:shared_preferences/shared_preferences.dart';

Future<String?> checkPrefs() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = await prefs.getString("jwt").toString();
    if (jwt.isEmpty) {
      return "no data";
    } else {
      return "gotJWT";
    }
  } on Exception catch (e) {
    print(e);
  }
}
