// ignore_for_file: prefer_const_constructors

import 'package:auth_app/models/user.dart';
import 'package:auth_app/screens/auth/login/signin.dart';
import 'package:auth_app/screens/home/chatui.dart';
import 'package:auth_app/services/currentuser.dart';
import 'package:flutter/material.dart';

class HomeScaffold extends StatelessWidget {
  late final Future<User?> myFuture = currentUser();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        future: myFuture,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return LoginScaffold();
          } else if (snapshot.hasData) {
            return ChatScreen();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
