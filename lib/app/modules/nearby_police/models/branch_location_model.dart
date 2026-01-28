import 'package:json_annotation/json_annotation.dart';

part 'branch_location_model.g.dart';

// Wrapper for API response
@JsonSerializable()
class BranchLocationResponseWrapper {
  const BranchLocationResponseWrapper({
    this.success,
    this.data,
    this.meta,
  });

  factory BranchLocationResponseWrapper.fromJson(Map<String, dynamic> json) =>
      _$BranchLocationResponseWrapperFromJson(json);

  final bool? success;
  final List<BranchLocation>? data;
  final BranchLocationMeta? meta;

  Map<String, dynamic> toJson() => _$BranchLocationResponseWrapperToJson(this);
}

// Meta information
@JsonSerializable()
class BranchLocationMeta {
  const BranchLocationMeta({
    this.timestamp,
    this.requestId,
  });

  factory BranchLocationMeta.fromJson(Map<String, dynamic> json) =>
      _$BranchLocationMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$BranchLocationMetaToJson(this);
}

// Branch location data
@JsonSerializable()
class BranchLocation {
  const BranchLocation({
    this.id,
    this.name,
    this.code,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.descriptionJson,
    this.lat,
    this.lng,
    this.nameJson,
    this.parentBranchId,
    this.branchType,
    this.shareLocation,
    this.distance,
  });

  factory BranchLocation.fromJson(Map<String, dynamic> json) =>
      _$BranchLocationFromJson(json);

  final String? id;
  final String? name;
  final String? code;
  final String? description;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final DescriptionJson? descriptionJson;
  final double? lat;
  final double? lng;
  final NameJson? nameJson;
  final String? parentBranchId;
  final String? branchType;
  final bool? shareLocation;
  final double? distance;

  Map<String, dynamic> toJson() => _$BranchLocationToJson(this);
}

// Description JSON (multilingual)
@JsonSerializable()
class DescriptionJson {
  const DescriptionJson({
    this.am,
    this.en,
  });

  factory DescriptionJson.fromJson(Map<String, dynamic> json) =>
      _$DescriptionJsonFromJson(json);

  final String? am;
  final String? en;

  Map<String, dynamic> toJson() => _$DescriptionJsonToJson(this);
}

// Name JSON (multilingual)
@JsonSerializable()
class NameJson {
  const NameJson({
    this.am,
    this.en,
  });

  factory NameJson.fromJson(Map<String, dynamic> json) =>
      _$NameJsonFromJson(json);

  final String? am;
  final String? en;

  Map<String, dynamic> toJson() => _$NameJsonToJson(this);
}
