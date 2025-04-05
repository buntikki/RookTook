class AuthInputState {
  final String value;
  final int maxLength;
  final bool isValid;
  final InputType type;

  AuthInputState({
    this.value = '',
    this.maxLength = 25,
    this.isValid = false,
    this.type = InputType.username,
  });

  AuthInputState copyWith({
    String? value,
    int? maxLength,
    bool? isValid,
    InputType? type,
  }) {
    return AuthInputState(
      value: value ?? this.value,
      maxLength: maxLength ?? this.maxLength,
      isValid: isValid ?? this.isValid,
      type: type ?? this.type,
    );
  }
}

enum InputType {
  username,
  email,
}
