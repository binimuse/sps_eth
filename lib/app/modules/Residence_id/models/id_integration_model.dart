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

/// Response model for Residence ID registration lookup
@JsonSerializable()
class ResidenceRegistrationResponse {
  const ResidenceRegistrationResponse({
    this.success,
    this.data,
    this.meta,
    this.statusCode,
    this.message,
    this.error,
    this.timestamp,
  });

  factory ResidenceRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$ResidenceRegistrationResponseFromJson(json);

  final bool? success;
  final List<ResidenceData>? data;
  final ResidenceMeta? meta;
  final int? statusCode;
  final String? message;
  final String? error;
  final String? timestamp;

  Map<String, dynamic> toJson() => _$ResidenceRegistrationResponseToJson(this);
  
  /// Check if response was successful
  bool get isSuccess => success == true && data != null && data!.isNotEmpty;
  
  /// Get first resident data (primary resident)
  ResidenceData? get primaryResident => data?.isNotEmpty == true ? data!.first : null;
}

/// Meta model for Residence registration response
@JsonSerializable()
class ResidenceMeta {
  const ResidenceMeta({
    this.timestamp,
    this.requestId,
  });

  factory ResidenceMeta.fromJson(Map<String, dynamic> json) =>
      _$ResidenceMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$ResidenceMetaToJson(this);
}

/// Residence data model
@JsonSerializable()
class ResidenceData {
  const ResidenceData({
    this.memberType,
    this.locId,
    this.residentIdNo,
    this.title,
    this.firstName,
    this.middleName,
    this.lastName,
    this.firstNameAmh,
    this.middleNameAmh,
    this.lastNameAmh,
    this.fatherName,
    this.motherFullName,
    this.motherFullNameAmh,
    this.isEthiopian,
    this.serviceCode,
    this.serviceCategoryCode,
    this.currentStatus,
    this.partnerResidentId,
    this.passportNo,
    this.dob,
    this.dobAmh,
    this.gender,
    this.nationality,
    this.bloodGroup,
    this.fatherNationality,
    this.motherNationality,
    this.fatherResidentNationalId,
    this.motherResidentNationalId,
    this.idResidentRepresentative,
    this.maritalStatus,
    this.spouseName,
    this.spouseNameAmh,
    this.marriageType,
    this.educationLevel,
    this.occupationType,
    this.companyName,
    this.companyNameAmh,
    this.powOccupation,
    this.powOccupationAmh,
    this.powRegionCode,
    this.paAddress,
    this.paAddressAmh,
    this.incaseofEmergencyName,
    this.incaseofEmergencyNameAmh,
    this.incaseofEmergencyAddress,
    this.incaseofEmergencyAddressAmh,
    this.incaseofEmergencyTelephone,
    this.incaseofEmergencyRemark,
    this.incaseofEmergencyRemarkAmh,
    this.adoptionType,
    this.disabilityType,
    this.ppaRegionCode,
    this.ppaZone,
    this.ppaZoneAmh,
    this.ppaCity,
    this.ppaCityAmh,
    this.pobSubCityCode,
    this.pobWoreda,
    this.ppaKebele,
    this.ppaKebeleAmh,
    this.houseNo,
    this.poBox,
    this.phoneNo,
    this.fax,
    this.emailId,
    this.others,
    this.ppaAddress,
    this.ppaAddressAmh,
    this.ppaDateStartedlivinginWoreda,
    this.powPhoneNo,
    this.locality,
    this.localityAmh,
    this.raLivingatWoredaAmh,
    this.raiiLivingatWoredaAmh,
    this.pobRegion,
    this.economicStatus,
    this.familyStatus,
    this.ethnicity,
    this.religion,
    this.pobAddress,
    this.pobAddressAmh,
    this.pobLocality,
    this.pobLocalityAmh,
    this.pobLocationRegion,
    this.pobLocationZone,
    this.pobLocationZoneAmh,
    this.pobLocationCity,
    this.pobLocationCityAmh,
    this.pobLocationSubcity,
    this.pobLocationWoreda,
    this.pobLocationKebele,
    this.pobLocationKebeleAmh,
    this.isDisabledPerson,
    this.isResident,
  });

  factory ResidenceData.fromJson(Map<String, dynamic> json) =>
      _$ResidenceDataFromJson(json);

  @JsonKey(name: 'MemberType')
  final String? memberType;
  
  @JsonKey(name: 'LOCID')
  final String? locId;
  
  @JsonKey(name: 'ResidentIDNo')
  final String? residentIdNo;
  
  @JsonKey(name: 'Title')
  final String? title;
  
  @JsonKey(name: 'FirstName')
  final String? firstName;
  
  @JsonKey(name: 'MiddleName')
  final String? middleName;
  
  @JsonKey(name: 'LastName')
  final String? lastName;
  
  @JsonKey(name: 'FirstNameAmh')
  final String? firstNameAmh;
  
  @JsonKey(name: 'MiddleNameAmh')
  final String? middleNameAmh;
  
  @JsonKey(name: 'LastNameAmh')
  final String? lastNameAmh;
  
  @JsonKey(name: 'FatherName')
  final String? fatherName;
  
  @JsonKey(name: 'MotherFullName')
  final String? motherFullName;
  
  @JsonKey(name: 'MotherFullNameAmh')
  final String? motherFullNameAmh;
  
  @JsonKey(name: 'IsEthiopian')
  final bool? isEthiopian;
  
  @JsonKey(name: 'ServiceCode')
  final String? serviceCode;
  
  @JsonKey(name: 'ServiceCategoryCode')
  final String? serviceCategoryCode;
  
  @JsonKey(name: 'CurrentStatus')
  final String? currentStatus;
  
  @JsonKey(name: 'PartnerResidentID')
  final String? partnerResidentId;
  
  @JsonKey(name: 'PassportNo')
  final String? passportNo;
  
  @JsonKey(name: 'DOB')
  final String? dob;
  
  @JsonKey(name: 'DOBAmh')
  final String? dobAmh;
  
  @JsonKey(name: 'Gender')
  final String? gender;
  
  @JsonKey(name: 'Nationality')
  final String? nationality;
  
  @JsonKey(name: 'BloodGroup')
  final String? bloodGroup;
  
  @JsonKey(name: 'FatherNationality')
  final String? fatherNationality;
  
  @JsonKey(name: 'MotherNationality')
  final String? motherNationality;
  
  @JsonKey(name: 'FatherResident_NationalID')
  final String? fatherResidentNationalId;
  
  @JsonKey(name: 'MotherResident_NationalID')
  final String? motherResidentNationalId;
  
  @JsonKey(name: 'IDResidentRepresentative')
  final String? idResidentRepresentative;
  
  @JsonKey(name: 'MaritalStatus')
  final String? maritalStatus;
  
  @JsonKey(name: 'SpouseName')
  final String? spouseName;
  
  @JsonKey(name: 'SpouseNameAmh')
  final String? spouseNameAmh;
  
  @JsonKey(name: 'MarriageType')
  final String? marriageType;
  
  @JsonKey(name: 'EducationLevel')
  final String? educationLevel;
  
  @JsonKey(name: 'OccupationType')
  final String? occupationType;
  
  @JsonKey(name: 'CompanyName')
  final String? companyName;
  
  @JsonKey(name: 'CompanyNameAmh')
  final String? companyNameAmh;
  
  @JsonKey(name: 'POWOccupation')
  final String? powOccupation;
  
  @JsonKey(name: 'POWOccupationAmh')
  final String? powOccupationAmh;
  
  @JsonKey(name: 'POWRegionCode')
  final String? powRegionCode;
  
  @JsonKey(name: 'PAAddress')
  final String? paAddress;
  
  @JsonKey(name: 'PAAddressAmh')
  final String? paAddressAmh;
  
  @JsonKey(name: 'IncaseofEmergencyName')
  final String? incaseofEmergencyName;
  
  @JsonKey(name: 'IncaseofEmergencyNameAmh')
  final String? incaseofEmergencyNameAmh;
  
  @JsonKey(name: 'IncaseofEmergencyAddress')
  final String? incaseofEmergencyAddress;
  
  @JsonKey(name: 'IncaseofEmergencyAddressAmh')
  final String? incaseofEmergencyAddressAmh;
  
  @JsonKey(name: 'IncaseofEmergencyTelephone')
  final String? incaseofEmergencyTelephone;
  
  @JsonKey(name: 'IncaseofEmergencyRemark')
  final String? incaseofEmergencyRemark;
  
  @JsonKey(name: 'IncaseofEmergencyRemarkAmh')
  final String? incaseofEmergencyRemarkAmh;
  
  @JsonKey(name: 'AdoptionType')
  final String? adoptionType;
  
  @JsonKey(name: 'DisabilityType')
  final String? disabilityType;
  
  @JsonKey(name: 'PPARegionCode')
  final String? ppaRegionCode;
  
  @JsonKey(name: 'PPAZone')
  final String? ppaZone;
  
  @JsonKey(name: 'PPAZoneAmh')
  final String? ppaZoneAmh;
  
  @JsonKey(name: 'PPACity')
  final String? ppaCity;
  
  @JsonKey(name: 'PPACityAmh')
  final String? ppaCityAmh;
  
  @JsonKey(name: 'POBSubCityCode')
  final String? pobSubCityCode;
  
  @JsonKey(name: 'POBWoreda')
  final String? pobWoreda;
  
  @JsonKey(name: 'PPAKebele')
  final String? ppaKebele;
  
  @JsonKey(name: 'PPAKebeleAmh')
  final String? ppaKebeleAmh;
  
  @JsonKey(name: 'HouseNo')
  final String? houseNo;
  
  @JsonKey(name: 'POBox')
  final String? poBox;
  
  @JsonKey(name: 'PhoneNo')
  final String? phoneNo;
  
  @JsonKey(name: 'Fax')
  final String? fax;
  
  @JsonKey(name: 'EmailID')
  final String? emailId;
  
  @JsonKey(name: 'Others')
  final String? others;
  
  @JsonKey(name: 'PPAAddress')
  final String? ppaAddress;
  
  @JsonKey(name: 'PPAAddressAmh')
  final String? ppaAddressAmh;
  
  @JsonKey(name: 'PPADateStartedlivinginWoreda')
  final String? ppaDateStartedlivinginWoreda;
  
  @JsonKey(name: 'POWPhoneNo')
  final String? powPhoneNo;
  
  @JsonKey(name: 'Locality')
  final String? locality;
  
  @JsonKey(name: 'localityAmh')
  final String? localityAmh;
  
  @JsonKey(name: 'RALivingatWoredaAmh')
  final String? raLivingatWoredaAmh;
  
  @JsonKey(name: 'RAIILivingatWoredaAmh')
  final String? raiiLivingatWoredaAmh;
  
  @JsonKey(name: 'POBRegion')
  final String? pobRegion;
  
  @JsonKey(name: 'EconomicStatus')
  final String? economicStatus;
  
  @JsonKey(name: 'FamilyStatus')
  final String? familyStatus;
  
  @JsonKey(name: 'Ethnicity')
  final String? ethnicity;
  
  @JsonKey(name: 'Religion')
  final String? religion;
  
  @JsonKey(name: 'POBAddress')
  final String? pobAddress;
  
  @JsonKey(name: 'POBAddressAmh')
  final String? pobAddressAmh;
  
  @JsonKey(name: 'POBLocality')
  final String? pobLocality;
  
  @JsonKey(name: 'POBLocalityAmh')
  final String? pobLocalityAmh;
  
  @JsonKey(name: 'POBLocationRegion')
  final String? pobLocationRegion;
  
  @JsonKey(name: 'POBLocationZone')
  final String? pobLocationZone;
  
  @JsonKey(name: 'POBLocationZoneAmh')
  final String? pobLocationZoneAmh;
  
  @JsonKey(name: 'POBLocationCity')
  final String? pobLocationCity;
  
  @JsonKey(name: 'POBLocationCityAmh')
  final String? pobLocationCityAmh;
  
  @JsonKey(name: 'POBLocationSubcity')
  final String? pobLocationSubcity;
  
  @JsonKey(name: 'POBLocationWoreda')
  final String? pobLocationWoreda;
  
  @JsonKey(name: 'POBLocationKebele')
  final String? pobLocationKebele;
  
  @JsonKey(name: 'POBLocationKebeleAmh')
  final String? pobLocationKebeleAmh;
  
  @JsonKey(name: 'IsDisabledPerson')
  final String? isDisabledPerson;
  
  @JsonKey(name: 'IsResident')
  final String? isResident;

  Map<String, dynamic> toJson() => _$ResidenceDataToJson(this);
  
  /// Get full name (English)
  String? get fullName {
    final parts = <String>[];
    if (firstName != null && firstName!.isNotEmpty) parts.add(firstName!);
    if (middleName != null && middleName!.isNotEmpty) parts.add(middleName!);
    if (lastName != null && lastName!.isNotEmpty) parts.add(lastName!);
    return parts.isEmpty ? null : parts.join(' ');
  }
  
  /// Get full name (Amharic)
  String? get fullNameAmh {
    final parts = <String>[];
    if (firstNameAmh != null && firstNameAmh!.isNotEmpty) parts.add(firstNameAmh!);
    if (middleNameAmh != null && middleNameAmh!.isNotEmpty) parts.add(middleNameAmh!);
    if (lastNameAmh != null && lastNameAmh!.isNotEmpty) parts.add(lastNameAmh!);
    return parts.isEmpty ? null : parts.join(' ');
  }
}

/// Response model for TIN number lookup
@JsonSerializable()
class TinTaxpayerResponse {
  const TinTaxpayerResponse({
    this.success,
    this.data,
    this.meta,
    this.statusCode,
    this.message,
    this.error,
    this.timestamp,
  });

  factory TinTaxpayerResponse.fromJson(Map<String, dynamic> json) =>
      _$TinTaxpayerResponseFromJson(json);

  final bool? success;
  final TinTaxpayerData? data;
  final TinTaxpayerMeta? meta;
  final int? statusCode;
  final String? message;
  final String? error;
  final String? timestamp;

  Map<String, dynamic> toJson() => _$TinTaxpayerResponseToJson(this);
  
  /// Check if response was successful
  bool get isSuccess => success == true && data != null && data!.taxPayerDetails != null;
  
  /// Get taxpayer details
  TinTaxPayerDetails? get taxPayerDetails => data?.taxPayerDetails;
}

/// Data model for TIN taxpayer response
@JsonSerializable()
class TinTaxpayerData {
  const TinTaxpayerData({
    this.status,
    this.taxPayerDetails,
  });

  factory TinTaxpayerData.fromJson(Map<String, dynamic> json) =>
      _$TinTaxpayerDataFromJson(json);

  final String? status;
  @JsonKey(name: 'taxPayerDetails')
  final TinTaxPayerDetails? taxPayerDetails;

  Map<String, dynamic> toJson() => _$TinTaxpayerDataToJson(this);
}

/// Meta model for TIN taxpayer response
@JsonSerializable()
class TinTaxpayerMeta {
  const TinTaxpayerMeta({
    this.timestamp,
    this.requestId,
  });

  factory TinTaxpayerMeta.fromJson(Map<String, dynamic> json) =>
      _$TinTaxpayerMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$TinTaxpayerMetaToJson(this);
}

/// Taxpayer details model
@JsonSerializable()
class TinTaxPayerDetails {
  const TinTaxPayerDetails({
    this.cmpTin,
    this.firstName,
    this.middleName,
    this.lastName,
    this.firstNameF,
    this.middleNameF,
    this.lastNameF,
    this.registName,
    this.registNameF,
    this.homePhone,
    this.workPhone,
    this.tpTypeDesc,
    this.region,
    this.cityName,
    this.localityDesc,
    this.kebeleDesc,
    this.taxCentreDesc,
    this.faydaId,
  });

  factory TinTaxPayerDetails.fromJson(Map<String, dynamic> json) =>
      _$TinTaxPayerDetailsFromJson(json);

  @JsonKey(name: 'CMP_TIN')
  final String? cmpTin;
  
  @JsonKey(name: 'FIRST_NAME')
  final String? firstName;
  
  @JsonKey(name: 'MIDDLE_NAME')
  final String? middleName;
  
  @JsonKey(name: 'LAST_NAME')
  final String? lastName;
  
  @JsonKey(name: 'FIRST_NAME_F')
  final String? firstNameF;
  
  @JsonKey(name: 'MIDDLE_NAME_F')
  final String? middleNameF;
  
  @JsonKey(name: 'LAST_NAME_F')
  final String? lastNameF;
  
  @JsonKey(name: 'REGIST_NAME')
  final String? registName;
  
  @JsonKey(name: 'REGIST_NAME_F')
  final String? registNameF;
  
  @JsonKey(name: 'HOME_PHONE')
  final String? homePhone;
  
  @JsonKey(name: 'WORK_PHONE')
  final String? workPhone;
  
  @JsonKey(name: 'TP_TYPE_DESC')
  final String? tpTypeDesc;
  
  @JsonKey(name: 'REGION')
  final String? region;
  
  @JsonKey(name: 'CITY_NAME')
  final String? cityName;
  
  @JsonKey(name: 'LOCALITY_DESC')
  final String? localityDesc;
  
  @JsonKey(name: 'KEBELE_DESC')
  final String? kebeleDesc;
  
  @JsonKey(name: 'TAX_CENTRE_DESC')
  final String? taxCentreDesc;
  
  @JsonKey(name: 'FAYDA_ID')
  final String? faydaId;

  Map<String, dynamic> toJson() => _$TinTaxPayerDetailsToJson(this);
  
  /// Get full name (English)
  String? get fullName {
    final parts = <String>[];
    if (firstName != null && firstName!.isNotEmpty) parts.add(firstName!);
    if (middleName != null && middleName!.isNotEmpty) parts.add(middleName!);
    if (lastName != null && lastName!.isNotEmpty) parts.add(lastName!);
    return parts.isEmpty ? null : parts.join(' ');
  }
  
  /// Get full name (Amharic)
  String? get fullNameF {
    final parts = <String>[];
    if (firstNameF != null && firstNameF!.isNotEmpty) parts.add(firstNameF!);
    if (middleNameF != null && middleNameF!.isNotEmpty) parts.add(middleNameF!);
    if (lastNameF != null && lastNameF!.isNotEmpty) parts.add(lastNameF!);
    return parts.isEmpty ? null : parts.join(' ');
  }
  
  /// Get phone number (prefer work phone, fallback to home phone)
  String? get phoneNumber {
    if (workPhone != null && workPhone!.isNotEmpty) {
      return workPhone;
    }
    return homePhone;
  }
}
