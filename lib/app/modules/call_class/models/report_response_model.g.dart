// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportResponseWrapper _$ReportResponseWrapperFromJson(
  Map<String, dynamic> json,
) => ReportResponseWrapper(
  success: json['success'] as bool?,
  data: json['data'] == null
      ? null
      : ReportData.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'] == null
      ? null
      : ReportMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReportResponseWrapperToJson(
  ReportResponseWrapper instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
};

ReportMeta _$ReportMetaFromJson(Map<String, dynamic> json) => ReportMeta(
  timestamp: json['timestamp'] as String?,
  requestId: json['requestId'] as String?,
);

Map<String, dynamic> _$ReportMetaToJson(ReportMeta instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'requestId': instance.requestId,
    };

ReportData _$ReportDataFromJson(Map<String, dynamic> json) => ReportData(
  id: json['id'] as String?,
  caseNumber: json['caseNumber'] as String?,
  reportType: json['reportType'] == null
      ? null
      : ReportType.fromJson(json['reportType'] as Map<String, dynamic>),
  status: json['status'] as String?,
  statements: (json['statements'] as List<dynamic>?)
      ?.map((e) => StatementData.fromJson(e as Map<String, dynamic>))
      .toList(),
  submitted: json['submitted'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReportDataToJson(ReportData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseNumber': instance.caseNumber,
      'reportType': instance.reportType,
      'status': instance.status,
      'statements': instance.statements,
      'submitted': instance.submitted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ReportType _$ReportTypeFromJson(Map<String, dynamic> json) => ReportType(
  id: json['id'] as String?,
  name: json['name'] as String?,
  code: json['code'] as String?,
);

Map<String, dynamic> _$ReportTypeToJson(ReportType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
    };

StatementPersonData _$StatementPersonDataFromJson(Map<String, dynamic> json) =>
    StatementPersonData(
      fullName: json['fullName'] as String?,
      phoneMobile: json['phoneMobile'] as String?,
      age: (json['age'] as num?)?.toInt(),
      sex: json['sex'] as String?,
      nationality: json['nationality'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
    );

Map<String, dynamic> _$StatementPersonDataToJson(
  StatementPersonData instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'phoneMobile': instance.phoneMobile,
  'age': instance.age,
  'sex': instance.sex,
  'nationality': instance.nationality,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
};

StatementData _$StatementDataFromJson(Map<String, dynamic> json) =>
    StatementData(
      id: json['id'] as String?,
      reportId: json['reportId'] as String?,
      person: json['person'] == null
          ? null
          : StatementPersonData.fromJson(
              json['person'] as Map<String, dynamic>,
            ),
      fullName: json['fullName'] as String?,
      phoneMobile: json['phoneMobile'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      age: (json['age'] as num?)?.toInt(),
      sex: json['sex'] as String?,
      nationality: json['nationality'] as String?,
      currentSubCity: json['currentSubCity'] as String?,
      currentKebele: json['currentKebele'] as String?,
      currentHouseNumber: json['currentHouseNumber'] as String?,
      specificAddress: json['specificAddress'] as String?,
      otherAddress: json['otherAddress'] as String?,
      statement: json['statement'] as String?,
      statementDate: json['statementDate'] == null
          ? null
          : DateTime.parse(json['statementDate'] as String),
      statementTime: json['statementTime'] as String?,
    );

Map<String, dynamic> _$StatementDataToJson(StatementData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportId': instance.reportId,
      'person': instance.person,
      'fullName': instance.fullName,
      'phoneMobile': instance.phoneMobile,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'age': instance.age,
      'sex': instance.sex,
      'nationality': instance.nationality,
      'currentSubCity': instance.currentSubCity,
      'currentKebele': instance.currentKebele,
      'currentHouseNumber': instance.currentHouseNumber,
      'specificAddress': instance.specificAddress,
      'otherAddress': instance.otherAddress,
      'statement': instance.statement,
      'statementDate': instance.statementDate?.toIso8601String(),
      'statementTime': instance.statementTime,
    };
