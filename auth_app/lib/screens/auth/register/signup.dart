import 'package:auth_app/screens/auth/register/signupbloc.dart';
import 'package:auth_app/screens/auth/register/signupform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScaffold extends StatelessWidget {
  const SignUpScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: BlocProvider(
            create: (_) => SignUpBloc(),
            child: SignUpForm(),
          ),
        ));
  }
}
