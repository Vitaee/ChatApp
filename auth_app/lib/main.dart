// ignore_for_file: prefer_const_constructors
import 'package:auth_app/screens/auth/login/signin.dart';
import 'package:auth_app/screens/auth/register/signup.dart';
import 'package:auth_app/screens/home/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bloc App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => LoginScaffold(),
        '/signUp': (context) => SignUpScaffold(),
        '/home': (context) => HomeScaffold(),
      },
      initialRoute: '/',
    );
  }
}
