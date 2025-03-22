class UsernameState {
  final String username;
  final int maxLength;
  final bool isValid;

  UsernameState({
    this.username = '',
    this.maxLength = 25,
    this.isValid = false,
  });

  UsernameState copyWith({
    String? username,
    int? maxLength,
    bool? isValid,
  }) {
    return UsernameState(
      username: username ?? this.username,
      maxLength: maxLength ?? this.maxLength,
      isValid: isValid ?? this.isValid,
    );
  }
}
