import 'package:auth_app/screens/home/chatui.dart';
import 'package:auth_app/services/currentuser.dart';
import 'package:flutter/material.dart';
import '../../common/avatar.dart';
import 'infocard.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 52, 55, 59),
        body: SafeArea(
          minimum: const EdgeInsets.only(top: 100),
          child: FutureBuilder(
              future: currentUser(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError ||
                    snapshot.data == null &&
                        snapshot.connectionState != ConnectionState.waiting) {
                  return ChatScreen();
                } else if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      Avatar.large(
                          url: snapshot.data.image
                              .toString()
                              .replaceAll('185', 'http://185')),
                      Text(
                        snapshot.data.email,
                        style: TextStyle(
                          fontSize: 40.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Pacifico",
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        width: 200,
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),

                      // we will be creating a new widget name info carrd

                      InfoCard(
                          text: snapshot.data.username,
                          icon: Icons.verified_user,
                          onPressed: () async {})
                    ],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ));
  }
}
