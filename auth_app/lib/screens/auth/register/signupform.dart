// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'dart:io';

import 'package:auth_app/screens/auth/models/confirm_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_app/common/add_image_form.dart';
import 'signupbloc.dart';
import 'signupstate.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state.status.isSubmissionFailure) {
            print('INFO: Submission failure in registration.');
          } else if (state.status.isSubmissionSuccess) {
            Navigator.of(context).pushNamed('/home');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(38.0, 0, 38.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImageInputField(),
              NameInputField(),
              EmailInputField(),
              PasswordInputField(),
              ConfirmPasswordInput(),
              SignUpButton(),
            ],
          ),
        ));
  }
}

class ImageInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.image != current.image,
      builder: (context, state) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: AddImageForm(
              imagePath: state.image.toString(),
              onChanged: (image) =>
                  context.read<SignUpBloc>().ImageChanged(image),
            ));
      },
    );
  }
}

class NameInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            //hint: 'Name',
            key: const Key('SignUpForm_NameInput_textField'),
            //isRequiredField: true,
            keyboardType: TextInputType.text,
            onChanged: (name) => context.read<SignUpBloc>().NameChanged(name),
            decoration: InputDecoration(
              labelText: 'Username',
              helperText: '',
              hintText: 'abc',
              errorText: state.name.invalid ? 'invalid username' : null,
            ),
          ),
        );
      },
    );
  }
}

class EmailInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            //hint: 'Email',
            //isRequiredField: true,
            keyboardType: TextInputType.emailAddress,
            onChanged: (email) =>
                context.read<SignUpBloc>().EmailChanged(email),
            decoration: InputDecoration(
              hintText: 'abc@gmail.com',
              helperText: '',
              labelText: 'Email',
              errorText: state.email.invalid ? 'invalid email' : null,
            ),
          ),
        );
      },
    );
  }
}

class PasswordInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            // change to text field. do not use auth text field.
            //hint: 'Password',
            //isPasswordField: true,
            keyboardType: TextInputType.text,
            //error: state.password.error.toString(),
            onChanged: (password) =>
                context.read<SignUpBloc>().PasswordChanged(password),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              helperText: '',
              hintText: 'abc123456',
              errorText: state.password.invalid ? 'invalid password' : null,
            ),
          ),
        );
      },
    );
  }
}

class ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmPassword != current.confirmPassword,
      builder: (context, state) {
        return TextField(
          //hint: 'Confirm Password',
          //isRequiredField: true,
          //isPasswordField: true,
          keyboardType: TextInputType.text,
          //error: state.confirmPassword.error.toString(),
          obscureText: true,
          onChanged: (confirmPassword) => context
              .read<SignUpBloc>()
              .ConfirmPasswordChanged(confirmPassword),
          decoration: InputDecoration(
            labelText: 'Confirm password',
            helperText: '',
            hintText: 'abc123456',
            errorText:
                state.confirmPassword.valid ? null : "password must match",
          ),
        );
      },
    );
  }
}

class SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(top: 20),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('Sign Up'),
            disabledColor: Colors.blueAccent.withOpacity(0.6),
            color: Colors.blueAccent,
            onPressed: state.status.isValidated
                ? () => context.read<SignUpBloc>().signUpInWithCredentials(
                    state.email.value,
                    state.password.value,
                    state.name.value,
                    File(state.image.toString()))
                : () => null,
          ),
        );
      },
    );
  }
}
