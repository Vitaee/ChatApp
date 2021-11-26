// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class HomeScaffold extends StatelessWidget {
  const HomeScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Home'),
      ),
      body: SafeArea(
          child: Center(
        child: Text('Logged'),
      )),
    );
  }
}
