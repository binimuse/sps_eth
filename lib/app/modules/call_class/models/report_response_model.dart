import 'package:json_annotation/json_annotation.dart';

part 'report_response_model.g.dart';

/// Report Response Model from Admin API
/// Endpoint: https://sps-admin.zorcloud.net/api/v1/reports/{reportId}
@JsonSerializable()
class ReportResponseWrapper {
  const ReportResponseWrapper({
    this.success,
    this.data,
    this.meta,
  });

  factory ReportResponseWrapper.fromJson(Map<String, dynamic> json) =>
      _$ReportResponseWrapperFromJson(json);

  final bool? success;
  final ReportData? data;
  final ReportMeta? meta;

  Map<String, dynamic> toJson() => _$ReportResponseWrapperToJson(this);
}

@JsonSerializable()
class ReportMeta {
  const ReportMeta({
    this.timestamp,
    this.requestId,
  });

  factory ReportMeta.fromJson(Map<String, dynamic> json) =>
      _$ReportMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$ReportMetaToJson(this);
}

@JsonSerializable()
class ReportData {
  const ReportData({
    this.id,
    this.caseNumber,
    this.reportType,
    this.status,
    this.statements,
    this.submitted,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) =>
      _$ReportDataFromJson(json);

  final String? id;
  final String? caseNumber;
  final ReportType? reportType;
  final String? status;
  final List<StatementData>? statements;
  final bool? submitted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$ReportDataToJson(this);
}

@JsonSerializable()
class ReportType {
  const ReportType({
    this.id,
    this.name,
    this.code,
  });

  factory ReportType.fromJson(Map<String, dynamic> json) =>
      _$ReportTypeFromJson(json);

  final String? id;
  final String? name;
  final String? code;

  Map<String, dynamic> toJson() => _$ReportTypeToJson(this);
}

@JsonSerializable()
class StatementData {
  const StatementData({
    this.id,
    this.reportId,
    this.fullName,
    this.phoneMobile,
    this.dateOfBirth,
    this.age,
    this.sex,
    this.nationality,
    this.currentSubCity,
    this.currentKebele,
    this.currentHouseNumber,
    this.specificAddress,
    this.otherAddress,
    this.statement,
    this.statementDate,
    this.statementTime,
  });

  factory StatementData.fromJson(Map<String, dynamic> json) =>
      _$StatementDataFromJson(json);

  final String? id;
  final String? reportId;
  final String? fullName;
  final String? phoneMobile;
  final DateTime? dateOfBirth;
  final int? age;
  final String? sex;
  final String? nationality;
  final String? currentSubCity;
  final String? currentKebele;
  final String? currentHouseNumber;
  final String? specificAddress;
  final String? otherAddress;
  final String? statement;
  final DateTime? statementDate;
  final String? statementTime;

  Map<String, dynamic> toJson() => _$StatementDataToJson(this);
}
