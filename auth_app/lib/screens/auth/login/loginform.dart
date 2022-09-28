// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'loginstate.dart';
import 'logincubit.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          print("Submission failure");
        } else if (state.status.isSubmissionSuccess) {
          Navigator.pushNamed(context, '/home');
        }
      },
      builder: (context, state) => Stack(
        children: <Widget>[
          Container(
            //height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("./assets/login_bg.png"),
                  fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(38.0, 150, 38.0, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  WelcomeText(),
                  Divider(
                    height: 120,
                    thickness: 0.01,
                  ),
                  EmailInput(),
                  Divider(
                    height: 30,
                    thickness: 0.01,
                  ),
                  PasswordInput(),
                  Divider(
                    height: 50,
                    thickness: 0.01,
                  ),
                  LoginButton(),
                  SignUpButton()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Text(
        'Welcome!',
        textAlign: TextAlign.left,
        style: TextStyle(color: Colors.orange, fontSize: 35),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle:
                TextStyle(color: Color.fromARGB(255, 13, 17, 17), fontSize: 18),
            errorText: state.email.invalid ? 'invalid email' : null,
            fillColor: Color.fromARGB(255, 0, 60, 109),
          ),
          style: TextStyle(color: Colors.black),
        );
      },
    );
  }
}

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) =>
              context.read<LoginCubit>().passwordChanged(password),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle:
                TextStyle(color: Color.fromARGB(255, 12, 17, 17), fontSize: 18),
            errorText: state.password.invalid ? 'invalid password' : null,
            fillColor: Colors.blue,
          ),
          style: TextStyle(color: Colors.black),
        );
      },
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(top: 20),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('Login'),
            disabledColor: Color(0xff4c505b).withOpacity(0.65),
            color: Color(0xff4c505b),
            onPressed: state.status.isValidated
                ? () => context.read<LoginCubit>().logInWithCredentials(
                    state.email.value, state.password.value)
                : null,
          ),
        );
      },
    );
  }
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(top: 30),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              'Sign Up',
              style: TextStyle(color: Colors.black),
            ),
            color: Colors.transparent,
            onPressed: () => Navigator.pushNamed(context, '/signUp'),
          ),
        );
      },
    );
  }
}
