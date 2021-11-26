// ignore_for_file: prefer_const_constructors, override_on_non_overriding_member

import 'dart:async';
import 'package:auth_app/screens/auth/register/signupevent.dart';
import 'package:bloc/bloc.dart';
import 'package:auth_app/screens/auth/models/email.dart';
import 'package:auth_app/screens/auth/models/name.dart';
import 'package:auth_app/screens/auth/models/password.dart';
import 'package:auth_app/screens/auth/models/confirm_password.dart';
import 'package:formz/formz.dart';

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

  Future<void> signUpInWithCredentials() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Exception catch (e) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
