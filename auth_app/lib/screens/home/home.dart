// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:auth_app/models/user.dart';
import 'package:auth_app/screens/home/currentuser.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScaffold extends StatelessWidget {
  const HomeScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove("jwt");
              Navigator.pushNamed(context, '/');
            },
          )
        ],
      ),
      body: FutureBuilder<User>(
        future: currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(
              'There was an error :(',
            );
          } else if (snapshot.hasData) {
            return SafeArea(
              child: Center(
                child: Text(
                  "Hello ${snapshot.data!.username} welcome!",
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
