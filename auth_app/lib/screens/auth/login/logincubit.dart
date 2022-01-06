import 'package:auth_app/models/token.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:auth_app/screens/auth/models/email.dart';
import 'package:auth_app/screens/auth/models/password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginstate.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState(errorMessage: ''));

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password]),
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password]),
    ));
  }

  Future<Token> logInWithCredentials(String email, String password) async {
    if (!state.status.isValidated) return Token(token: "");
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    final Dio dio = Dio();
    try {
      //await Future.delayed(const Duration(milliseconds: 500));

      Response response = await dio.post(
          //"http://10.80.1.165:8080/api/user/login",
          "http://192.168.254.4:8080/api/user/login",
          data: {"username": email, "password": password});

      Token data = Token.fromJson(response.data);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString("jwt", data.token.toString());

      emit(state.copyWith(status: FormzStatus.submissionSuccess));
      return data;
    } on Exception catch (e) {
      emit(state.copyWith(
          status: FormzStatus.submissionFailure, errorMessage: e.toString()));
      return Token(token: "error");
    }
  }
}
