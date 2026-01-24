import 'package:json_annotation/json_annotation.dart';

part 'id_integration_model.g.dart';

/// Request model for Fayda ID OTP request
@JsonSerializable()
class FaydaOtpRequest {
  const FaydaOtpRequest({
    required this.individualId,
  });

  factory FaydaOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$FaydaOtpRequestFromJson(json);

  final String individualId;

  Map<String, dynamic> toJson() => _$FaydaOtpRequestToJson(this);
}

/// Response model for Fayda ID OTP request
@JsonSerializable()
class FaydaOtpResponse {
  const FaydaOtpResponse({
    this.success,
    this.data,
    this.meta,
    this.statusCode,
    this.message,
    this.error,
    this.timestamp,
  });

  factory FaydaOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$FaydaOtpResponseFromJson(json);

  final bool? success;
  final FaydaOtpData? data;
  final FaydaOtpMeta? meta;
  final int? statusCode;
  final String? message;
  final String? error;
  final String? timestamp;

  Map<String, dynamic> toJson() => _$FaydaOtpResponseToJson(this);
}

/// Data model for Fayda OTP response
@JsonSerializable()
class FaydaOtpData {
  const FaydaOtpData({
    this.id,
    this.version,
    this.responseTime,
    this.transactionID,
    this.response,
    this.errors,
  });

  factory FaydaOtpData.fromJson(Map<String, dynamic> json) =>
      _$FaydaOtpDataFromJson(json);

  final String? id;
  final String? version;
  final String? responseTime;
  @JsonKey(name: 'transactionID')
  final String? transactionID;
  final FaydaOtpResponseData? response;
  final dynamic errors;

  Map<String, dynamic> toJson() => _$FaydaOtpDataToJson(this);
}

/// Response data within FaydaOtpData
@JsonSerializable()
class FaydaOtpResponseData {
  const FaydaOtpResponseData({
    this.maskedMobile,
    this.maskedEmail,
  });

  factory FaydaOtpResponseData.fromJson(Map<String, dynamic> json) =>
      _$FaydaOtpResponseDataFromJson(json);

  final String? maskedMobile;
  final String? maskedEmail;

  Map<String, dynamic> toJson() => _$FaydaOtpResponseDataToJson(this);
}

/// Meta model for Fayda OTP response
@JsonSerializable()
class FaydaOtpMeta {
  const FaydaOtpMeta({
    this.timestamp,
    this.requestId,
  });

  factory FaydaOtpMeta.fromJson(Map<String, dynamic> json) =>
      _$FaydaOtpMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$FaydaOtpMetaToJson(this);
}

/// Request model for Fayda ID verification (get data)
@JsonSerializable()
class FaydaVerifyRequest {
  const FaydaVerifyRequest({
    required this.individualId,
    required this.transactionID,
    required this.otp,
  });

  factory FaydaVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$FaydaVerifyRequestFromJson(json);

  final String individualId;
  @JsonKey(name: 'transactionID')
  final String transactionID;
  final String otp;

  Map<String, dynamic> toJson() => _$FaydaVerifyRequestToJson(this);
}

/// Response model for Fayda ID verification
@JsonSerializable()
class FaydaVerifyResponse {
  const FaydaVerifyResponse({
    this.success,
    this.data,
    this.statusCode,
    this.message,
    this.error,
    this.timestamp,
  });

  factory FaydaVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$FaydaVerifyResponseFromJson(json);

  final bool? success;
  final FaydaVerifyData? data;
  final int? statusCode;
  final String? message;
  final String? error;
  final String? timestamp;

  Map<String, dynamic> toJson() => _$FaydaVerifyResponseToJson(this);
  
  /// Check if verification was successful
  bool get isSuccess {
    final result = success == true && 
                   data != null && 
                   data!.response != null && 
                   data!.response!.kycStatus == true;
    return result;
  }
  
  /// Get user name (English)
  String? get name {
    if (data?.response?.identity?.name != null && data!.response!.identity!.name!.isNotEmpty) {
      // Find English name or return first one
      for (var nameItem in data!.response!.identity!.name!) {
        if (nameItem.language == 'eng') {
          return nameItem.value;
        }
      }
      return data!.response!.identity!.name!.first.value;
    }
    return null;
  }
  
  /// Get date of birth
  String? get dateOfBirth => data?.response?.identity?.dob;
  
  /// Get gender (English)
  String? get gender {
    if (data?.response?.identity?.gender != null && data!.response!.identity!.gender!.isNotEmpty) {
      for (var genderItem in data!.response!.identity!.gender!) {
        if (genderItem.language == 'eng') {
          return genderItem.value;
        }
      }
      return data!.response!.identity!.gender!.first.value;
    }
    return null;
  }
  
  /// Get nationality (English)
  String? get nationality {
    if (data?.response?.identity?.nationality != null && data!.response!.identity!.nationality!.isNotEmpty) {
      for (var natItem in data!.response!.identity!.nationality!) {
        if (natItem.language == 'eng') {
          return natItem.value;
        }
      }
      return data!.response!.identity!.nationality!.first.value;
    }
    return null;
  }
  
  /// Get phone number
  String? get phoneNumber => data?.response?.identity?.phoneNumber;
  
  /// Get name in Amharic
  String? get nameAm {
    if (data?.response?.identity?.name != null && data!.response!.identity!.name!.isNotEmpty) {
      for (var nameItem in data!.response!.identity!.name!) {
        if (nameItem.language == 'amh') {
          return nameItem.value;
        }
      }
      return null;
    }
    return null;
  }
  
  /// Get full address (English)
  String? get address {
    if (data?.response?.identity?.fullAddress != null && data!.response!.identity!.fullAddress!.isNotEmpty) {
      for (var addrItem in data!.response!.identity!.fullAddress!) {
        if (addrItem.language == 'eng') {
          return addrItem.value;
        }
      }
      return data!.response!.identity!.fullAddress!.first.value;
    }
    return null;
  }
  
  /// Get photo URL
  String? get photo => data?.response?.identity?.photo;
  
  /// Get status
  String? get status => data?.response?.kycStatus == true ? 'verified' : null;
  
  /// Get transaction ID
  String? get transactionID => data?.transactionID;
}

/// Data model for Fayda verify response
@JsonSerializable()
class FaydaVerifyData {
  const FaydaVerifyData({
    this.id,
    this.version,
    this.responseTime,
    this.transactionID,
    this.response,
  });

  factory FaydaVerifyData.fromJson(Map<String, dynamic> json) =>
      _$FaydaVerifyDataFromJson(json);

  final String? id;
  final String? version;
  final String? responseTime;
  @JsonKey(name: 'transactionID')
  final String? transactionID;
  final FaydaVerifyResponseData? response;

  Map<String, dynamic> toJson() => _$FaydaVerifyDataToJson(this);
}

/// Response data within FaydaVerifyData
@JsonSerializable()
class FaydaVerifyResponseData {
  const FaydaVerifyResponseData({
    this.kycStatus,
    this.authResponseToken,
    this.identity,
  });

  factory FaydaVerifyResponseData.fromJson(Map<String, dynamic> json) =>
      _$FaydaVerifyResponseDataFromJson(json);

  final bool? kycStatus;
  final String? authResponseToken;
  final FaydaIdentity? identity;

  Map<String, dynamic> toJson() => _$FaydaVerifyResponseDataToJson(this);
}

/// Identity model
@JsonSerializable()
class FaydaIdentity {
  const FaydaIdentity({
    this.name,
    this.dob,
    this.gender,
    this.phoneNumber,
    this.emailId,
    this.fullAddress,
    this.nationality,
    this.photo,
  });

  factory FaydaIdentity.fromJson(Map<String, dynamic> json) =>
      _$FaydaIdentityFromJson(json);

  final List<FaydaLanguageValue>? name;
  final String? dob;
  final List<FaydaLanguageValue>? gender;
  final String? phoneNumber;
  final String? emailId;
  final List<FaydaLanguageValue>? fullAddress;
  final List<FaydaLanguageValue>? nationality;
  final String? photo;

  Map<String, dynamic> toJson() => _$FaydaIdentityToJson(this);
}

/// Language value model (for multilingual fields)
@JsonSerializable()
class FaydaLanguageValue {
  const FaydaLanguageValue({
    this.language,
    this.value,
  });

  factory FaydaLanguageValue.fromJson(Map<String, dynamic> json) =>
      _$FaydaLanguageValueFromJson(json);

  final String? language;
  final String? value;

  Map<String, dynamic> toJson() => _$FaydaLanguageValueToJson(this);
}
