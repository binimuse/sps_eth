import 'package:json_annotation/json_annotation.dart';

part 'report_draft_model.g.dart';

/// Response wrapper for report draft API
@JsonSerializable()
class ReportDraftResponseWrapper {
  const ReportDraftResponseWrapper({
    this.success,
    this.data,
    this.meta,
  });

  factory ReportDraftResponseWrapper.fromJson(Map<String, dynamic> json) =>
      _$ReportDraftResponseWrapperFromJson(json);

  final bool? success;
  final ReportDraftData? data;
  final ReportDraftMeta? meta;

  Map<String, dynamic> toJson() => _$ReportDraftResponseWrapperToJson(this);
}

/// Meta information for report draft API responses
@JsonSerializable()
class ReportDraftMeta {
  const ReportDraftMeta({
    this.timestamp,
    this.requestId,
  });

  factory ReportDraftMeta.fromJson(Map<String, dynamic> json) =>
      _$ReportDraftMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$ReportDraftMetaToJson(this);
}

/// Report draft data
@JsonSerializable()
class ReportDraftData {
  const ReportDraftData({
    this.callSessionId,
    this.formData,
    this.lastUpdated,
    this.hasUpdates,
    this.reportSubmitted,
    this.reportId,
    this.caseNumber,
  });

  factory ReportDraftData.fromJson(Map<String, dynamic> json) =>
      _$ReportDraftDataFromJson(json);

  @JsonKey(name: 'callSessionId')
  final String? callSessionId;

  @JsonKey(name: 'formData')
  final Map<String, dynamic>? formData;

  @JsonKey(name: 'lastUpdated')
  final String? lastUpdated;

  @JsonKey(name: 'hasUpdates')
  final bool? hasUpdates;

  @JsonKey(name: 'reportSubmitted')
  final bool? reportSubmitted;

  @JsonKey(name: 'reportId')
  final String? reportId;

  @JsonKey(name: 'caseNumber')
  final String? caseNumber;

  Map<String, dynamic> toJson() => _$ReportDraftDataToJson(this);
}

