import 'package:json_annotation/json_annotation.dart';

part 'livekit_model.g.dart';

@JsonSerializable()
class LiveKitTokenResponse {
  const LiveKitTokenResponse({
    this.message,
    this.data,
    this.status,
  });

  factory LiveKitTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveKitTokenResponseFromJson(json);

  final String? message;
  final LiveKitTokenData? data;
  final bool? status;

  Map<String, dynamic> toJson() => _$LiveKitTokenResponseToJson(this);
}

@JsonSerializable()
class LiveKitTokenData {
  const LiveKitTokenData({
    required this.accessToken,
    required this.url,
  });

  factory LiveKitTokenData.fromJson(Map<String, dynamic> json) =>
      _$LiveKitTokenDataFromJson(json);

  final String accessToken;
  final String url;

  Map<String, dynamic> toJson() => _$LiveKitTokenDataToJson(this);
}

@JsonSerializable()
class LiveKitRoomResponse {
  const LiveKitRoomResponse({
    this.message,
    this.data,
    this.status,
  });

  factory LiveKitRoomResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveKitRoomResponseFromJson(json);

  final String? message;
  final LiveKitRoomData? data;
  final bool? status;

  Map<String, dynamic> toJson() => _$LiveKitRoomResponseToJson(this);
}

@JsonSerializable()
class LiveKitRoomData {
  const LiveKitRoomData({
    required this.roomName,
    required this.roomId,
    this.createdAt,
  });

  factory LiveKitRoomData.fromJson(Map<String, dynamic> json) =>
      _$LiveKitRoomDataFromJson(json);

  final String roomName;
  final String roomId;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$LiveKitRoomDataToJson(this);
}

@JsonSerializable()
class LiveKitRoomInfoResponse {
  const LiveKitRoomInfoResponse({
    this.message,
    this.data,
    this.status,
  });

  factory LiveKitRoomInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveKitRoomInfoResponseFromJson(json);

  final String? message;
  final LiveKitRoomInfo? data;
  final bool? status;

  Map<String, dynamic> toJson() => _$LiveKitRoomInfoResponseToJson(this);
}

@JsonSerializable()
class LiveKitRoomInfo {
  const LiveKitRoomInfo({
    required this.roomName,
    required this.numParticipants,
    required this.isActive,
  });

  factory LiveKitRoomInfo.fromJson(Map<String, dynamic> json) =>
      _$LiveKitRoomInfoFromJson(json);

  final String roomName;
  final int numParticipants;
  final bool isActive;

  Map<String, dynamic> toJson() => _$LiveKitRoomInfoToJson(this);
}

