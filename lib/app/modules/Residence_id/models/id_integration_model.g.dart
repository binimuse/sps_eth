// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_integration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaydaOtpRequest _$FaydaOtpRequestFromJson(Map<String, dynamic> json) =>
    FaydaOtpRequest(individualId: json['individualId'] as String);

Map<String, dynamic> _$FaydaOtpRequestToJson(FaydaOtpRequest instance) =>
    <String, dynamic>{'individualId': instance.individualId};

FaydaOtpResponse _$FaydaOtpResponseFromJson(Map<String, dynamic> json) =>
    FaydaOtpResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : FaydaOtpData.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : FaydaOtpMeta.fromJson(json['meta'] as Map<String, dynamic>),
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      error: json['error'] as String?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$FaydaOtpResponseToJson(FaydaOtpResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'meta': instance.meta,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'error': instance.error,
      'timestamp': instance.timestamp,
    };

FaydaOtpData _$FaydaOtpDataFromJson(Map<String, dynamic> json) => FaydaOtpData(
  id: json['id'] as String?,
  version: json['version'] as String?,
  responseTime: json['responseTime'] as String?,
  transactionID: json['transactionID'] as String?,
  response: json['response'] == null
      ? null
      : FaydaOtpResponseData.fromJson(json['response'] as Map<String, dynamic>),
  errors: json['errors'],
);

Map<String, dynamic> _$FaydaOtpDataToJson(FaydaOtpData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'responseTime': instance.responseTime,
      'transactionID': instance.transactionID,
      'response': instance.response,
      'errors': instance.errors,
    };

FaydaOtpResponseData _$FaydaOtpResponseDataFromJson(
  Map<String, dynamic> json,
) => FaydaOtpResponseData(
  maskedMobile: json['maskedMobile'] as String?,
  maskedEmail: json['maskedEmail'] as String?,
);

Map<String, dynamic> _$FaydaOtpResponseDataToJson(
  FaydaOtpResponseData instance,
) => <String, dynamic>{
  'maskedMobile': instance.maskedMobile,
  'maskedEmail': instance.maskedEmail,
};

FaydaOtpMeta _$FaydaOtpMetaFromJson(Map<String, dynamic> json) => FaydaOtpMeta(
  timestamp: json['timestamp'] as String?,
  requestId: json['requestId'] as String?,
);

Map<String, dynamic> _$FaydaOtpMetaToJson(FaydaOtpMeta instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'requestId': instance.requestId,
    };

FaydaVerifyRequest _$FaydaVerifyRequestFromJson(Map<String, dynamic> json) =>
    FaydaVerifyRequest(
      individualId: json['individualId'] as String,
      transactionID: json['transactionID'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$FaydaVerifyRequestToJson(FaydaVerifyRequest instance) =>
    <String, dynamic>{
      'individualId': instance.individualId,
      'transactionID': instance.transactionID,
      'otp': instance.otp,
    };

FaydaVerifyResponse _$FaydaVerifyResponseFromJson(Map<String, dynamic> json) =>
    FaydaVerifyResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : FaydaVerifyData.fromJson(json['data'] as Map<String, dynamic>),
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      error: json['error'] as String?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$FaydaVerifyResponseToJson(
  FaydaVerifyResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'error': instance.error,
  'timestamp': instance.timestamp,
};

FaydaVerifyData _$FaydaVerifyDataFromJson(Map<String, dynamic> json) =>
    FaydaVerifyData(
      id: json['id'] as String?,
      version: json['version'] as String?,
      responseTime: json['responseTime'] as String?,
      transactionID: json['transactionID'] as String?,
      response: json['response'] == null
          ? null
          : FaydaVerifyResponseData.fromJson(
              json['response'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$FaydaVerifyDataToJson(FaydaVerifyData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'responseTime': instance.responseTime,
      'transactionID': instance.transactionID,
      'response': instance.response,
    };

FaydaVerifyResponseData _$FaydaVerifyResponseDataFromJson(
  Map<String, dynamic> json,
) => FaydaVerifyResponseData(
  kycStatus: json['kycStatus'] as bool?,
  authResponseToken: json['authResponseToken'] as String?,
  identity: json['identity'] == null
      ? null
      : FaydaIdentity.fromJson(json['identity'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FaydaVerifyResponseDataToJson(
  FaydaVerifyResponseData instance,
) => <String, dynamic>{
  'kycStatus': instance.kycStatus,
  'authResponseToken': instance.authResponseToken,
  'identity': instance.identity,
};

FaydaIdentity _$FaydaIdentityFromJson(Map<String, dynamic> json) =>
    FaydaIdentity(
      name: (json['name'] as List<dynamic>?)
          ?.map((e) => FaydaLanguageValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      dob: json['dob'] as String?,
      gender: (json['gender'] as List<dynamic>?)
          ?.map((e) => FaydaLanguageValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      phoneNumber: json['phoneNumber'] as String?,
      emailId: json['emailId'] as String?,
      fullAddress: (json['fullAddress'] as List<dynamic>?)
          ?.map((e) => FaydaLanguageValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      nationality: (json['nationality'] as List<dynamic>?)
          ?.map((e) => FaydaLanguageValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      photo: json['photo'] as String?,
    );

Map<String, dynamic> _$FaydaIdentityToJson(FaydaIdentity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dob': instance.dob,
      'gender': instance.gender,
      'phoneNumber': instance.phoneNumber,
      'emailId': instance.emailId,
      'fullAddress': instance.fullAddress,
      'nationality': instance.nationality,
      'photo': instance.photo,
    };

FaydaLanguageValue _$FaydaLanguageValueFromJson(Map<String, dynamic> json) =>
    FaydaLanguageValue(
      language: json['language'] as String?,
      value: json['value'] as String?,
    );

Map<String, dynamic> _$FaydaLanguageValueToJson(FaydaLanguageValue instance) =>
    <String, dynamic>{'language': instance.language, 'value': instance.value};
