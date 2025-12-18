// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_draft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDraftResponseWrapper _$ReportDraftResponseWrapperFromJson(
  Map<String, dynamic> json,
) => ReportDraftResponseWrapper(
  success: json['success'] as bool?,
  data: json['data'] == null
      ? null
      : ReportDraftData.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'] == null
      ? null
      : ReportDraftMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReportDraftResponseWrapperToJson(
  ReportDraftResponseWrapper instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
};

ReportDraftMeta _$ReportDraftMetaFromJson(Map<String, dynamic> json) =>
    ReportDraftMeta(
      timestamp: json['timestamp'] as String?,
      requestId: json['requestId'] as String?,
    );

Map<String, dynamic> _$ReportDraftMetaToJson(ReportDraftMeta instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'requestId': instance.requestId,
    };

ReportDraftData _$ReportDraftDataFromJson(Map<String, dynamic> json) =>
    ReportDraftData(
      callSessionId: json['callSessionId'] as String?,
      formData: json['formData'] as Map<String, dynamic>?,
      lastUpdated: json['lastUpdated'] as String?,
      hasUpdates: json['hasUpdates'] as bool?,
      reportSubmitted: json['reportSubmitted'] as bool?,
      reportId: json['reportId'] as String?,
      caseNumber: json['caseNumber'] as String?,
    );

Map<String, dynamic> _$ReportDraftDataToJson(ReportDraftData instance) =>
    <String, dynamic>{
      'callSessionId': instance.callSessionId,
      'formData': instance.formData,
      'lastUpdated': instance.lastUpdated,
      'hasUpdates': instance.hasUpdates,
      'reportSubmitted': instance.reportSubmitted,
      'reportId': instance.reportId,
      'caseNumber': instance.caseNumber,
    };
