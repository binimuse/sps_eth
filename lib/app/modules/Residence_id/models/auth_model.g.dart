// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupResponse _$SignupResponseFromJson(Map<String, dynamic> json) =>
    SignupResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : SignupData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : SignupError.fromJson(json['error'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : SignupMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SignupResponseToJson(SignupResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'error': instance.error,
      'meta': instance.meta,
    };

SignupError _$SignupErrorFromJson(Map<String, dynamic> json) => SignupError(
  code: json['code'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$SignupErrorToJson(SignupError instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};

SignupData _$SignupDataFromJson(Map<String, dynamic> json) => SignupData(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  user: json['user'] == null
      ? null
      : SignupUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SignupDataToJson(SignupData instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'user': instance.user,
    };

SignupUser _$SignupUserFromJson(Map<String, dynamic> json) => SignupUser(
  id: json['id'] as String?,
  phone: json['phone'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$SignupUserToJson(SignupUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
    };

SignupMeta _$SignupMetaFromJson(Map<String, dynamic> json) => SignupMeta(
  timestamp: json['timestamp'] as String?,
  requestId: json['requestId'] as String?,
);

Map<String, dynamic> _$SignupMetaToJson(SignupMeta instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'requestId': instance.requestId,
    };

RequestOtpResponse _$RequestOtpResponseFromJson(Map<String, dynamic> json) =>
    RequestOtpResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : OtpData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : SignupError.fromJson(json['error'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : SignupMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequestOtpResponseToJson(RequestOtpResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'error': instance.error,
      'meta': instance.meta,
    };

OtpData _$OtpDataFromJson(Map<String, dynamic> json) => OtpData(
  success: json['success'] as bool?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$OtpDataToJson(OtpData instance) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

VerifyOtpResponse _$VerifyOtpResponseFromJson(Map<String, dynamic> json) =>
    VerifyOtpResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : VerifyOtpData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : SignupError.fromJson(json['error'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : SignupMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerifyOtpResponseToJson(VerifyOtpResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'error': instance.error,
      'meta': instance.meta,
    };

VerifyOtpData _$VerifyOtpDataFromJson(Map<String, dynamic> json) =>
    VerifyOtpData(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] == null
          ? null
          : LoginUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerifyOtpDataToJson(VerifyOtpData instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
    };
