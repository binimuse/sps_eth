import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginResponse {
  const LoginResponse({
    this.success,
    this.data,
    this.error,
    this.meta,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  final bool? success;
  final LoginData? data;
  final LoginError? error;
  final LoginMeta? meta;

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginData {
  const LoginData({
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);

  final String? accessToken;
  final String? refreshToken;
  final LoginUser? user;

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}

@JsonSerializable()
class LoginUser {
  const LoginUser({
    this.id,
    this.phone,
    this.email,
    this.name,
    this.role,
    this.is2faEnabled,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);

  final String? id;
  final String? phone;
  final String? email;
  final String? name;
  final UserRole? role;
  @JsonKey(name: 'is2faEnabled')
  final bool? is2faEnabled;

  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}

@JsonSerializable()
class UserRole {
  const UserRole({
    this.id,
    this.name,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);

  final String? id;
  final String? name;

  Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}

@JsonSerializable()
class LoginError {
  const LoginError({
    this.code,
    this.message,
  });

  factory LoginError.fromJson(Map<String, dynamic> json) =>
      _$LoginErrorFromJson(json);

  final String? code;
  final String? message;

  Map<String, dynamic> toJson() => _$LoginErrorToJson(this);
}

@JsonSerializable()
class LoginMeta {
  const LoginMeta({
    this.timestamp,
    this.requestId,
  });

  factory LoginMeta.fromJson(Map<String, dynamic> json) =>
      _$LoginMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$LoginMetaToJson(this);
}

