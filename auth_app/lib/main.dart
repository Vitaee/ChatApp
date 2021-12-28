// ignore_for_file: prefer_const_constructors
import 'package:auth_app/screens/auth/login/signin.dart';
import 'package:auth_app/screens/auth/register/signup.dart';
import 'package:auth_app/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //late final Future<String?> myFuture = checkPrefs();

  Future<String?> checkPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString("jwt").toString();
    if (jwt.isEmpty) {
      return "no data";
    } else {
      return "gotJWT";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: checkPrefs(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != "no data") {
          return MaterialApp(
            title: "Chat App",
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                scaffoldBackgroundColor: Color(0xff59bee6),
                //colorScheme: ColorScheme.dark(),
                appBarTheme: AppBarTheme(backgroundColor: Color(0xff3a434d))),
            darkTheme: ThemeData.dark(),
            routes: {
              '/': (context) => LoginScaffold(),
              '/signUp': (context) => SignUpScaffold(),
              '/home': (context) => HomeScaffold(),
            },
            initialRoute: '/home',
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
