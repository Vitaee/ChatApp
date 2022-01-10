import 'package:formz/formz.dart';

/// Validation errors for the [Password] [FormzInput].
enum PasswordValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template password}
/// Form input for an password input.
/// {@endtemplate}
class Password extends FormzInput<String, PasswordValidationError> {
  /// {@macro password}
  const Password.pure() : super.pure('');

  /// {@macro password}
  const Password.dirty([String value = '']) : super.dirty(value);

  static final passwordRegExp = RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,}');

  @override
  PasswordValidationError? validator(String value) {
    return passwordRegExp.hasMatch(value)
        ? null
        : PasswordValidationError.invalid;
  }
}
