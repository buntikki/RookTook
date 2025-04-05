import 'package:lichess_mobile/src/model/auth/auth_input_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_input_controller.g.dart';

@riverpod
class AuthInputController extends _$AuthInputController {
  @override
  AuthInputState build() {
    return AuthInputState();
  }

  void setInputType(InputType type) {
    final maxLength = type == InputType.email ? 100 : 25;
    state = state.copyWith(
      type: type,
      maxLength: maxLength,
      isValid: _validateInput(state.value, type),
    );
  }

  void updateInput(String value) {
    String newValue = value;
    if (value.length > state.maxLength) {
      newValue = value.substring(0, state.maxLength);
    }
    bool isValid = _validateInput(newValue, state.type);

    state = state.copyWith(
      value: newValue,
      isValid: isValid,
    );
  }

  void clearInput() {
    state = state.copyWith(
      value: '',
      isValid: false,
    );
  }

  bool _validateInput(String value, InputType type) {
    if (value.trim().isEmpty) {
      return false;
    }

    switch (type) {
      case InputType.username:
        return value.trim().length >= 3;

      case InputType.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return emailRegex.hasMatch(value.trim());
    }
  }
}
