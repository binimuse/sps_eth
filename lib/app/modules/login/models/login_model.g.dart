// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : LoginData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : LoginError.fromJson(json['error'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : LoginMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'error': instance.error,
      'meta': instance.meta,
    };

LoginData _$LoginDataFromJson(Map<String, dynamic> json) => LoginData(
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  user: json['user'] == null
      ? null
      : LoginUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginDataToJson(LoginData instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'user': instance.user,
};

LoginUser _$LoginUserFromJson(Map<String, dynamic> json) => LoginUser(
  id: json['id'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  name: json['name'] as String?,
  role: json['role'] == null
      ? null
      : UserRole.fromJson(json['role'] as Map<String, dynamic>),
  is2faEnabled: json['is2faEnabled'] as bool?,
);

Map<String, dynamic> _$LoginUserToJson(LoginUser instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'email': instance.email,
  'name': instance.name,
  'role': instance.role,
  'is2faEnabled': instance.is2faEnabled,
};

UserRole _$UserRoleFromJson(Map<String, dynamic> json) =>
    UserRole(id: json['id'] as String?, name: json['name'] as String?);

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

LoginError _$LoginErrorFromJson(Map<String, dynamic> json) => LoginError(
  code: json['code'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$LoginErrorToJson(LoginError instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};

LoginMeta _$LoginMetaFromJson(Map<String, dynamic> json) => LoginMeta(
  timestamp: json['timestamp'] as String?,
  requestId: json['requestId'] as String?,
);

Map<String, dynamic> _$LoginMetaToJson(LoginMeta instance) => <String, dynamic>{
  'timestamp': instance.timestamp,
  'requestId': instance.requestId,
};
