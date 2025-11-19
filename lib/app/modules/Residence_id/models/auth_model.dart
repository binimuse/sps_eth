import 'package:json_annotation/json_annotation.dart';
import 'package:sps_eth_app/app/modules/login/models/login_model.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class SignupResponse {
  const SignupResponse({
    this.success,
    this.data,
    this.error,
    this.meta,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) =>
      _$SignupResponseFromJson(json);

  final bool? success;
  final SignupData? data;
  final SignupError? error;
  final SignupMeta? meta;

  Map<String, dynamic> toJson() => _$SignupResponseToJson(this);
}

@JsonSerializable()
class SignupError {
  const SignupError({
    this.code,
    this.message,
  });

  factory SignupError.fromJson(Map<String, dynamic> json) =>
      _$SignupErrorFromJson(json);

  final String? code;
  final String? message;

  Map<String, dynamic> toJson() => _$SignupErrorToJson(this);
}

@JsonSerializable()
class SignupData {
  const SignupData({
    this.success,
    this.message,
    this.user,
  });

  factory SignupData.fromJson(Map<String, dynamic> json) =>
      _$SignupDataFromJson(json);

  final bool? success;
  final String? message;
  final SignupUser? user;

  Map<String, dynamic> toJson() => _$SignupDataToJson(this);
}

@JsonSerializable()
class SignupUser {
  const SignupUser({
    this.id,
    this.phone,
    this.name,
  });

  factory SignupUser.fromJson(Map<String, dynamic> json) =>
      _$SignupUserFromJson(json);

  final String? id;
  final String? phone;
  final String? name;

  Map<String, dynamic> toJson() => _$SignupUserToJson(this);
}

@JsonSerializable()
class SignupMeta {
  const SignupMeta({
    this.timestamp,
    this.requestId,
  });

  factory SignupMeta.fromJson(Map<String, dynamic> json) =>
      _$SignupMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$SignupMetaToJson(this);
}

// OTP Models
@JsonSerializable()
class RequestOtpResponse {
  const RequestOtpResponse({
    this.success,
    this.data,
    this.error,
    this.meta,
  });

  factory RequestOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestOtpResponseFromJson(json);

  final bool? success;
  final OtpData? data;
  final SignupError? error;
  final SignupMeta? meta;

  Map<String, dynamic> toJson() => _$RequestOtpResponseToJson(this);
}

@JsonSerializable()
class OtpData {
  const OtpData({
    this.success,
    this.message,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) =>
      _$OtpDataFromJson(json);

  final bool? success;
  final String? message;

  Map<String, dynamic> toJson() => _$OtpDataToJson(this);
}

@JsonSerializable()
class VerifyOtpResponse {
  const VerifyOtpResponse({
    this.success,
    this.data,
    this.error,
    this.meta,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseFromJson(json);

  final bool? success;
  final VerifyOtpData? data;
  final SignupError? error;
  final SignupMeta? meta;

  Map<String, dynamic> toJson() => _$VerifyOtpResponseToJson(this);
}

@JsonSerializable()
class VerifyOtpData {
  const VerifyOtpData({
    this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpDataFromJson(json);

  final bool? success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final LoginUser? user;

  Map<String, dynamic> toJson() => _$VerifyOtpDataToJson(this);
}

