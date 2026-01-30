// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchLocationResponseWrapper _$BranchLocationResponseWrapperFromJson(
  Map<String, dynamic> json,
) => BranchLocationResponseWrapper(
  success: json['success'] as bool?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => BranchLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : BranchLocationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BranchLocationResponseWrapperToJson(
  BranchLocationResponseWrapper instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
};

BranchLocationMeta _$BranchLocationMetaFromJson(Map<String, dynamic> json) =>
    BranchLocationMeta(
      timestamp: json['timestamp'] as String?,
      requestId: json['requestId'] as String?,
    );

Map<String, dynamic> _$BranchLocationMetaToJson(BranchLocationMeta instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'requestId': instance.requestId,
    };

BranchLocation _$BranchLocationFromJson(Map<String, dynamic> json) =>
    BranchLocation(
      id: json['id'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      descriptionJson: json['descriptionJson'] == null
          ? null
          : DescriptionJson.fromJson(
              json['descriptionJson'] as Map<String, dynamic>,
            ),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      nameJson: json['nameJson'] == null
          ? null
          : NameJson.fromJson(json['nameJson'] as Map<String, dynamic>),
      parentBranchId: json['parentBranchId'] as String?,
      branchType: json['branchType'] as String?,
      shareLocation: json['shareLocation'] as bool?,
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BranchLocationToJson(BranchLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'descriptionJson': instance.descriptionJson,
      'lat': instance.lat,
      'lng': instance.lng,
      'nameJson': instance.nameJson,
      'parentBranchId': instance.parentBranchId,
      'branchType': instance.branchType,
      'shareLocation': instance.shareLocation,
      'distance': instance.distance,
    };

DescriptionJson _$DescriptionJsonFromJson(Map<String, dynamic> json) =>
    DescriptionJson(am: json['am'] as String?, en: json['en'] as String?);

Map<String, dynamic> _$DescriptionJsonToJson(DescriptionJson instance) =>
    <String, dynamic>{'am': instance.am, 'en': instance.en};

NameJson _$NameJsonFromJson(Map<String, dynamic> json) =>
    NameJson(am: json['am'] as String?, en: json['en'] as String?);

Map<String, dynamic> _$NameJsonToJson(NameJson instance) => <String, dynamic>{
  'am': instance.am,
  'en': instance.en,
};
