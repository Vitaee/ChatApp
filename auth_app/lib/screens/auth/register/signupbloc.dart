// ignore_for_file: prefer_const_constructors, override_on_non_overriding_member, invalid_use_of_visible_for_testing_member
import 'dart:io';

import 'package:auth_app/models/token.dart';
import 'package:auth_app/screens/auth/register/models/confirm_password.dart';
import 'package:auth_app/screens/auth/register/models/email.dart';
import 'package:auth_app/screens/auth/register/models/name.dart';
import 'package:auth_app/screens/auth/register/models/password.dart';
import 'package:auth_app/screens/auth/register/signupevent.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:formz/formz.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      confirmPassword: confirmedPassword.valid ? confirmedPassword : null,
      status: Formz.validate([
        state.name,
        state.email,
        state.password,
        confirmedPassword,
      ]),
    ));
  }

  Future<Token> signUpInWithCredentials(
      String email, String password, String username, File image) async {
    if (!state.status.isValidated) return Token(token: "");
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    final Dio dio = Dio();
    try {
      FormData form_data = FormData.fromMap(
          {"email": email, "password": password, "username": username});

      form_data.files
          .add(MapEntry("file", await MultipartFile.fromFile(image.path)));

      Response response = await dio
          .post("http://10.80.1.167:8080/api/user/register", data: form_data);

      Token data = Token.fromJson(response.data);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString("jwt", data.token.toString());

      emit(state.copyWith(status: FormzStatus.submissionSuccess));
      return data;
    } on Exception catch (e) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
      return Token(token: "error $e");
    }
  }
}
