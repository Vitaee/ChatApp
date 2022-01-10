import 'package:formz/formz.dart';

enum NameError { empty, invalid }

class Name extends FormzInput<String, NameError> {
  const Name.pure() : super.pure('');
  const Name.dirty([String value = '']) : super.dirty(value);

  static final RegExp nameRegExp = RegExp(
    r'^(?=.*[a-z])[A-Za-z ]{2,}$',
  );

  @override
  NameError? validator(String value) {
    if (value.isNotEmpty == false) {
      return NameError.empty;
    }
    return nameRegExp.hasMatch(value) ? null : NameError.invalid;
  }
}
