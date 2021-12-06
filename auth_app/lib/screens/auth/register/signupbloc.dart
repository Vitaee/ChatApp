// ignore_for_file: prefer_const_constructors, override_on_non_overriding_member

import 'dart:async';
import 'package:auth_app/models/token.dart';
import 'package:auth_app/screens/auth/register/signupevent.dart';
import 'package:bloc/bloc.dart';
import 'package:auth_app/screens/auth/models/email.dart';
import 'package:auth_app/screens/auth/models/name.dart';
import 'package:auth_app/screens/auth/models/password.dart';
import 'package:auth_app/screens/auth/models/confirm_password.dart';
import 'package:formz/formz.dart';
import 'package:dio/dio.dart';
import 'signupstate.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpState());

  void ImageChanged(String value) {
    print(value);
    emit(state.copyWith(
      image: value,
      status: Formz.validate([
        state.name,
        state.email,
        state.password,
        state.confirmPassword,
      ]),
    ));
  }

  void NameChanged(String value) {
    final name = Name.dirty(value);
    emit(state.copyWith(
      name: name,
      status: Formz.validate([
        name,
        state.email,
        state.password,
        state.confirmPassword,
      ]),
    ));
  }

  void EmailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
        email: email,
        status: Formz.validate(
            [state.name, email, state.password, state.confirmPassword])));
  }

  void PasswordChanged(String value) {
    final password = Password.dirty(value);

    emit(state.copyWith(
      password: password,
      status: Formz.validate(
          [state.name, state.email, password, state.confirmPassword]),
    ));
  }

  void ConfirmPasswordChanged(String value) {
    final confirmedPassword = ConfirmPassword.dirty(
      password: state.password.value,
      value: value,
    );
    print('confirm is valid ${confirmedPassword.valid}');
    emit(state.copyWith(
      confirmPassword:
          confirmedPassword.valid ? confirmedPassword : ConfirmPassword.pure(),
      status: Formz.validate([
        state.name,
        state.email,
        state.password,
        confirmedPassword,
      ]),
    ));
  }

  Future<Token> signUpInWithCredentials() async {
    // should get fields as params.
    if (!state.status.isValidated) Token(accessToken: "", tokenType: "");
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    final Dio dio = Dio();
    try {
      //await Future.delayed(const Duration(milliseconds: 500));

      Response response = await dio.post('/api/user/register', data: {
        'username': "can",
        'email': 'wendu',
        'password': '1234',
        'image': 'image_path'
      });

      Token token = Token.fromJson(response.data);

      emit(state.copyWith(status: FormzStatus.submissionSuccess));
      return token;
    } on Exception catch (e) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
      return Token(accessToken: "error", tokenType: "error");
    }
  }
}
