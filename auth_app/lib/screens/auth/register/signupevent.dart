import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class ProfileImageChanged extends SignUpEvent {
  const ProfileImageChanged({required this.image});

  final String image;

  @override
  List<Object> get props => [image];
}

class NameChanged extends SignUpEvent {
  const NameChanged({required this.name});

  final String name;

  @override
  List<Object> get props => [name];
}

class EmailChanged extends SignUpEvent {
  const EmailChanged({
    required this.email,
  });

  final String email;

  @override
  List<Object> get props => [email];
}

class PasswordChanged extends SignUpEvent {
  const PasswordChanged({required this.password});

  final String password;

  @override
  List<Object> get props => [password];
}

class ConfirmPasswordChanged extends SignUpEvent {
  const ConfirmPasswordChanged({
    required this.confirmPassword,
  });

  final String confirmPassword;

  @override
  List<Object> get props => [confirmPassword];
}

class FormSubmitted extends SignUpEvent {}
