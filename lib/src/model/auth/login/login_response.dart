import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:deep_pick/deep_pick.dart';

part 'login_response.freezed.dart';

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String message,
    required String username,
    required String id,
    required String url,
    required String token,
    required String tokenType,
    required String accessToken,
    required int expiresIn,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      LoginResponse.fromPick(pick(json).required());

  factory LoginResponse.fromPick(RequiredPick pick) => LoginResponse(
    message: pick('message').asStringOrThrow(),
    username: pick('username').asStringOrThrow(),
    id: pick('id').asStringOrThrow(),
    url: pick('url').asStringOrThrow(),
    token: pick('token').asStringOrThrow(),
    tokenType: pick('token_type').asStringOrThrow(),
    accessToken: pick('access_token').asStringOrThrow(),
    expiresIn: pick('expires_in').asIntOrThrow(),
  );
}
