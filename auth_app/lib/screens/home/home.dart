// ignore_for_file: prefer_const_constructors

import 'package:auth_app/models/user.dart';
import 'package:auth_app/screens/auth/login/signin.dart';
import 'package:auth_app/screens/home/chatui.dart';
import 'package:auth_app/services/currentuser.dart';
import 'package:flutter/material.dart';
import 'package:auth_app/common/myglobals.dart' as globals;

class HomeScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        future: currentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError ||
              snapshot.data == null &&
                  snapshot.connectionState != ConnectionState.waiting) {
            return LoginScaffold();
          } else if (snapshot.hasData) {
            globals.currentUsername = snapshot.data.username;
            return ChatScreen();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
