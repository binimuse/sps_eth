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

ResidenceRegistrationResponse _$ResidenceRegistrationResponseFromJson(
  Map<String, dynamic> json,
) => ResidenceRegistrationResponse(
  success: json['success'] as bool?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => ResidenceData.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : ResidenceMeta.fromJson(json['meta'] as Map<String, dynamic>),
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  error: json['error'] as String?,
  timestamp: json['timestamp'] as String?,
);

Map<String, dynamic> _$ResidenceRegistrationResponseToJson(
  ResidenceRegistrationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'error': instance.error,
  'timestamp': instance.timestamp,
};

ResidenceMeta _$ResidenceMetaFromJson(Map<String, dynamic> json) =>
    ResidenceMeta(
      timestamp: json['timestamp'] as String?,
      requestId: json['requestId'] as String?,
    );

Map<String, dynamic> _$ResidenceMetaToJson(ResidenceMeta instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'requestId': instance.requestId,
    };

ResidenceData _$ResidenceDataFromJson(
  Map<String, dynamic> json,
) => ResidenceData(
  memberType: json['MemberType'] as String?,
  locId: json['LOCID'] as String?,
  residentIdNo: json['ResidentIDNo'] as String?,
  title: json['Title'] as String?,
  firstName: json['FirstName'] as String?,
  middleName: json['MiddleName'] as String?,
  lastName: json['LastName'] as String?,
  firstNameAmh: json['FirstNameAmh'] as String?,
  middleNameAmh: json['MiddleNameAmh'] as String?,
  lastNameAmh: json['LastNameAmh'] as String?,
  fatherName: json['FatherName'] as String?,
  motherFullName: json['MotherFullName'] as String?,
  motherFullNameAmh: json['MotherFullNameAmh'] as String?,
  isEthiopian: json['IsEthiopian'] as bool?,
  serviceCode: json['ServiceCode'] as String?,
  serviceCategoryCode: json['ServiceCategoryCode'] as String?,
  currentStatus: json['CurrentStatus'] as String?,
  partnerResidentId: json['PartnerResidentID'] as String?,
  passportNo: json['PassportNo'] as String?,
  dob: json['DOB'] as String?,
  dobAmh: json['DOBAmh'] as String?,
  gender: json['Gender'] as String?,
  nationality: json['Nationality'] as String?,
  bloodGroup: json['BloodGroup'] as String?,
  fatherNationality: json['FatherNationality'] as String?,
  motherNationality: json['MotherNationality'] as String?,
  fatherResidentNationalId: json['FatherResident_NationalID'] as String?,
  motherResidentNationalId: json['MotherResident_NationalID'] as String?,
  idResidentRepresentative: json['IDResidentRepresentative'] as String?,
  maritalStatus: json['MaritalStatus'] as String?,
  spouseName: json['SpouseName'] as String?,
  spouseNameAmh: json['SpouseNameAmh'] as String?,
  marriageType: json['MarriageType'] as String?,
  educationLevel: json['EducationLevel'] as String?,
  occupationType: json['OccupationType'] as String?,
  companyName: json['CompanyName'] as String?,
  companyNameAmh: json['CompanyNameAmh'] as String?,
  powOccupation: json['POWOccupation'] as String?,
  powOccupationAmh: json['POWOccupationAmh'] as String?,
  powRegionCode: json['POWRegionCode'] as String?,
  paAddress: json['PAAddress'] as String?,
  paAddressAmh: json['PAAddressAmh'] as String?,
  incaseofEmergencyName: json['IncaseofEmergencyName'] as String?,
  incaseofEmergencyNameAmh: json['IncaseofEmergencyNameAmh'] as String?,
  incaseofEmergencyAddress: json['IncaseofEmergencyAddress'] as String?,
  incaseofEmergencyAddressAmh: json['IncaseofEmergencyAddressAmh'] as String?,
  incaseofEmergencyTelephone: json['IncaseofEmergencyTelephone'] as String?,
  incaseofEmergencyRemark: json['IncaseofEmergencyRemark'] as String?,
  incaseofEmergencyRemarkAmh: json['IncaseofEmergencyRemarkAmh'] as String?,
  adoptionType: json['AdoptionType'] as String?,
  disabilityType: json['DisabilityType'] as String?,
  ppaRegionCode: json['PPARegionCode'] as String?,
  ppaZone: json['PPAZone'] as String?,
  ppaZoneAmh: json['PPAZoneAmh'] as String?,
  ppaCity: json['PPACity'] as String?,
  ppaCityAmh: json['PPACityAmh'] as String?,
  pobSubCityCode: json['POBSubCityCode'] as String?,
  pobWoreda: json['POBWoreda'] as String?,
  ppaKebele: json['PPAKebele'] as String?,
  ppaKebeleAmh: json['PPAKebeleAmh'] as String?,
  houseNo: json['HouseNo'] as String?,
  poBox: json['POBox'] as String?,
  phoneNo: json['PhoneNo'] as String?,
  fax: json['Fax'] as String?,
  emailId: json['EmailID'] as String?,
  others: json['Others'] as String?,
  ppaAddress: json['PPAAddress'] as String?,
  ppaAddressAmh: json['PPAAddressAmh'] as String?,
  ppaDateStartedlivinginWoreda: json['PPADateStartedlivinginWoreda'] as String?,
  powPhoneNo: json['POWPhoneNo'] as String?,
  locality: json['Locality'] as String?,
  localityAmh: json['localityAmh'] as String?,
  raLivingatWoredaAmh: json['RALivingatWoredaAmh'] as String?,
  raiiLivingatWoredaAmh: json['RAIILivingatWoredaAmh'] as String?,
  pobRegion: json['POBRegion'] as String?,
  economicStatus: json['EconomicStatus'] as String?,
  familyStatus: json['FamilyStatus'] as String?,
  ethnicity: json['Ethnicity'] as String?,
  religion: json['Religion'] as String?,
  pobAddress: json['POBAddress'] as String?,
  pobAddressAmh: json['POBAddressAmh'] as String?,
  pobLocality: json['POBLocality'] as String?,
  pobLocalityAmh: json['POBLocalityAmh'] as String?,
  pobLocationRegion: json['POBLocationRegion'] as String?,
  pobLocationZone: json['POBLocationZone'] as String?,
  pobLocationZoneAmh: json['POBLocationZoneAmh'] as String?,
  pobLocationCity: json['POBLocationCity'] as String?,
  pobLocationCityAmh: json['POBLocationCityAmh'] as String?,
  pobLocationSubcity: json['POBLocationSubcity'] as String?,
  pobLocationWoreda: json['POBLocationWoreda'] as String?,
  pobLocationKebele: json['POBLocationKebele'] as String?,
  pobLocationKebeleAmh: json['POBLocationKebeleAmh'] as String?,
  isDisabledPerson: json['IsDisabledPerson'] as String?,
  isResident: json['IsResident'] as String?,
);

Map<String, dynamic> _$ResidenceDataToJson(ResidenceData instance) =>
    <String, dynamic>{
      'MemberType': instance.memberType,
      'LOCID': instance.locId,
      'ResidentIDNo': instance.residentIdNo,
      'Title': instance.title,
      'FirstName': instance.firstName,
      'MiddleName': instance.middleName,
      'LastName': instance.lastName,
      'FirstNameAmh': instance.firstNameAmh,
      'MiddleNameAmh': instance.middleNameAmh,
      'LastNameAmh': instance.lastNameAmh,
      'FatherName': instance.fatherName,
      'MotherFullName': instance.motherFullName,
      'MotherFullNameAmh': instance.motherFullNameAmh,
      'IsEthiopian': instance.isEthiopian,
      'ServiceCode': instance.serviceCode,
      'ServiceCategoryCode': instance.serviceCategoryCode,
      'CurrentStatus': instance.currentStatus,
      'PartnerResidentID': instance.partnerResidentId,
      'PassportNo': instance.passportNo,
      'DOB': instance.dob,
      'DOBAmh': instance.dobAmh,
      'Gender': instance.gender,
      'Nationality': instance.nationality,
      'BloodGroup': instance.bloodGroup,
      'FatherNationality': instance.fatherNationality,
      'MotherNationality': instance.motherNationality,
      'FatherResident_NationalID': instance.fatherResidentNationalId,
      'MotherResident_NationalID': instance.motherResidentNationalId,
      'IDResidentRepresentative': instance.idResidentRepresentative,
      'MaritalStatus': instance.maritalStatus,
      'SpouseName': instance.spouseName,
      'SpouseNameAmh': instance.spouseNameAmh,
      'MarriageType': instance.marriageType,
      'EducationLevel': instance.educationLevel,
      'OccupationType': instance.occupationType,
      'CompanyName': instance.companyName,
      'CompanyNameAmh': instance.companyNameAmh,
      'POWOccupation': instance.powOccupation,
      'POWOccupationAmh': instance.powOccupationAmh,
      'POWRegionCode': instance.powRegionCode,
      'PAAddress': instance.paAddress,
      'PAAddressAmh': instance.paAddressAmh,
      'IncaseofEmergencyName': instance.incaseofEmergencyName,
      'IncaseofEmergencyNameAmh': instance.incaseofEmergencyNameAmh,
      'IncaseofEmergencyAddress': instance.incaseofEmergencyAddress,
      'IncaseofEmergencyAddressAmh': instance.incaseofEmergencyAddressAmh,
      'IncaseofEmergencyTelephone': instance.incaseofEmergencyTelephone,
      'IncaseofEmergencyRemark': instance.incaseofEmergencyRemark,
      'IncaseofEmergencyRemarkAmh': instance.incaseofEmergencyRemarkAmh,
      'AdoptionType': instance.adoptionType,
      'DisabilityType': instance.disabilityType,
      'PPARegionCode': instance.ppaRegionCode,
      'PPAZone': instance.ppaZone,
      'PPAZoneAmh': instance.ppaZoneAmh,
      'PPACity': instance.ppaCity,
      'PPACityAmh': instance.ppaCityAmh,
      'POBSubCityCode': instance.pobSubCityCode,
      'POBWoreda': instance.pobWoreda,
      'PPAKebele': instance.ppaKebele,
      'PPAKebeleAmh': instance.ppaKebeleAmh,
      'HouseNo': instance.houseNo,
      'POBox': instance.poBox,
      'PhoneNo': instance.phoneNo,
      'Fax': instance.fax,
      'EmailID': instance.emailId,
      'Others': instance.others,
      'PPAAddress': instance.ppaAddress,
      'PPAAddressAmh': instance.ppaAddressAmh,
      'PPADateStartedlivinginWoreda': instance.ppaDateStartedlivinginWoreda,
      'POWPhoneNo': instance.powPhoneNo,
      'Locality': instance.locality,
      'localityAmh': instance.localityAmh,
      'RALivingatWoredaAmh': instance.raLivingatWoredaAmh,
      'RAIILivingatWoredaAmh': instance.raiiLivingatWoredaAmh,
      'POBRegion': instance.pobRegion,
      'EconomicStatus': instance.economicStatus,
      'FamilyStatus': instance.familyStatus,
      'Ethnicity': instance.ethnicity,
      'Religion': instance.religion,
      'POBAddress': instance.pobAddress,
      'POBAddressAmh': instance.pobAddressAmh,
      'POBLocality': instance.pobLocality,
      'POBLocalityAmh': instance.pobLocalityAmh,
      'POBLocationRegion': instance.pobLocationRegion,
      'POBLocationZone': instance.pobLocationZone,
      'POBLocationZoneAmh': instance.pobLocationZoneAmh,
      'POBLocationCity': instance.pobLocationCity,
      'POBLocationCityAmh': instance.pobLocationCityAmh,
      'POBLocationSubcity': instance.pobLocationSubcity,
      'POBLocationWoreda': instance.pobLocationWoreda,
      'POBLocationKebele': instance.pobLocationKebele,
      'POBLocationKebeleAmh': instance.pobLocationKebeleAmh,
      'IsDisabledPerson': instance.isDisabledPerson,
      'IsResident': instance.isResident,
    };

TinTaxpayerResponse _$TinTaxpayerResponseFromJson(Map<String, dynamic> json) =>
    TinTaxpayerResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : TinTaxpayerData.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : TinTaxpayerMeta.fromJson(json['meta'] as Map<String, dynamic>),
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      error: json['error'] as String?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$TinTaxpayerResponseToJson(
  TinTaxpayerResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'error': instance.error,
  'timestamp': instance.timestamp,
};

TinTaxpayerData _$TinTaxpayerDataFromJson(Map<String, dynamic> json) =>
    TinTaxpayerData(
      status: json['status'] as String?,
      taxPayerDetails: json['taxPayerDetails'] == null
          ? null
          : TinTaxPayerDetails.fromJson(
              json['taxPayerDetails'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TinTaxpayerDataToJson(TinTaxpayerData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'taxPayerDetails': instance.taxPayerDetails,
    };

TinTaxpayerMeta _$TinTaxpayerMetaFromJson(Map<String, dynamic> json) =>
    TinTaxpayerMeta(
      timestamp: json['timestamp'] as String?,
      requestId: json['requestId'] as String?,
    );

Map<String, dynamic> _$TinTaxpayerMetaToJson(TinTaxpayerMeta instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'requestId': instance.requestId,
    };

TinTaxPayerDetails _$TinTaxPayerDetailsFromJson(Map<String, dynamic> json) =>
    TinTaxPayerDetails(
      cmpTin: json['CMP_TIN'] as String?,
      firstName: json['FIRST_NAME'] as String?,
      middleName: json['MIDDLE_NAME'] as String?,
      lastName: json['LAST_NAME'] as String?,
      firstNameF: json['FIRST_NAME_F'] as String?,
      middleNameF: json['MIDDLE_NAME_F'] as String?,
      lastNameF: json['LAST_NAME_F'] as String?,
      registName: json['REGIST_NAME'] as String?,
      registNameF: json['REGIST_NAME_F'] as String?,
      homePhone: json['HOME_PHONE'] as String?,
      workPhone: json['WORK_PHONE'] as String?,
      tpTypeDesc: json['TP_TYPE_DESC'] as String?,
      region: json['REGION'] as String?,
      cityName: json['CITY_NAME'] as String?,
      localityDesc: json['LOCALITY_DESC'] as String?,
      kebeleDesc: json['KEBELE_DESC'] as String?,
      taxCentreDesc: json['TAX_CENTRE_DESC'] as String?,
      faydaId: json['FAYDA_ID'] as String?,
    );

Map<String, dynamic> _$TinTaxPayerDetailsToJson(TinTaxPayerDetails instance) =>
    <String, dynamic>{
      'CMP_TIN': instance.cmpTin,
      'FIRST_NAME': instance.firstName,
      'MIDDLE_NAME': instance.middleName,
      'LAST_NAME': instance.lastName,
      'FIRST_NAME_F': instance.firstNameF,
      'MIDDLE_NAME_F': instance.middleNameF,
      'LAST_NAME_F': instance.lastNameF,
      'REGIST_NAME': instance.registName,
      'REGIST_NAME_F': instance.registNameF,
      'HOME_PHONE': instance.homePhone,
      'WORK_PHONE': instance.workPhone,
      'TP_TYPE_DESC': instance.tpTypeDesc,
      'REGION': instance.region,
      'CITY_NAME': instance.cityName,
      'LOCALITY_DESC': instance.localityDesc,
      'KEBELE_DESC': instance.kebeleDesc,
      'TAX_CENTRE_DESC': instance.taxCentreDesc,
      'FAYDA_ID': instance.faydaId,
    };
