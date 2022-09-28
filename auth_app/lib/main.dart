// ignore_for_file: prefer_const_constructors
import 'package:auth_app/screens/auth/login/signin.dart';
import 'package:auth_app/screens/auth/register/signup.dart';
import 'package:auth_app/screens/home/home.dart';
import 'package:auth_app/services/preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: checkPrefs(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            title: "Chat App",
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                scaffoldBackgroundColor: Color.fromARGB(255, 22, 25, 29),
                //colorScheme: ColorScheme.dark(),
                appBarTheme: AppBarTheme(
                    backgroundColor: Color.fromARGB(255, 17, 20, 24))),
            darkTheme: ThemeData.dark(),
            routes: {
              '/': (context) => LoginScaffold(),
              '/signUp': (context) => SignUpScaffold(),
              '/home': (context) => HomeScaffold(),
            },
            initialRoute: '/home',
          );
        } else if (snapshot.hasError ||
            snapshot.data == null &&
                snapshot.connectionState != ConnectionState.waiting) {
          return MaterialApp(
            title: "Chat App",
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                scaffoldBackgroundColor: Color(0xff3a434d),
                //colorScheme: ColorScheme.dark(),
                appBarTheme: AppBarTheme(backgroundColor: Color(0xff3a434d))),
            darkTheme: ThemeData.dark(),
            routes: {
              '/': (context) => LoginScaffold(),
              '/signUp': (context) => SignUpScaffold(),
              '/home': (context) => HomeScaffold(),
            },
            initialRoute: '/',
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
