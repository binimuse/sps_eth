// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livekit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveKitTokenResponse _$LiveKitTokenResponseFromJson(
  Map<String, dynamic> json,
) => LiveKitTokenResponse(
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : LiveKitTokenData.fromJson(json['data'] as Map<String, dynamic>),
  status: json['status'] as bool?,
);

Map<String, dynamic> _$LiveKitTokenResponseToJson(
  LiveKitTokenResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'data': instance.data,
  'status': instance.status,
};

LiveKitTokenData _$LiveKitTokenDataFromJson(Map<String, dynamic> json) =>
    LiveKitTokenData(
      accessToken: json['accessToken'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$LiveKitTokenDataToJson(LiveKitTokenData instance) =>
    <String, dynamic>{'accessToken': instance.accessToken, 'url': instance.url};

LiveKitRoomResponse _$LiveKitRoomResponseFromJson(Map<String, dynamic> json) =>
    LiveKitRoomResponse(
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : LiveKitRoomData.fromJson(json['data'] as Map<String, dynamic>),
      status: json['status'] as bool?,
    );

Map<String, dynamic> _$LiveKitRoomResponseToJson(
  LiveKitRoomResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'data': instance.data,
  'status': instance.status,
};

LiveKitRoomData _$LiveKitRoomDataFromJson(Map<String, dynamic> json) =>
    LiveKitRoomData(
      roomName: json['roomName'] as String,
      roomId: json['roomId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LiveKitRoomDataToJson(LiveKitRoomData instance) =>
    <String, dynamic>{
      'roomName': instance.roomName,
      'roomId': instance.roomId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

LiveKitRoomInfoResponse _$LiveKitRoomInfoResponseFromJson(
  Map<String, dynamic> json,
) => LiveKitRoomInfoResponse(
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : LiveKitRoomInfo.fromJson(json['data'] as Map<String, dynamic>),
  status: json['status'] as bool?,
);

Map<String, dynamic> _$LiveKitRoomInfoResponseToJson(
  LiveKitRoomInfoResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'data': instance.data,
  'status': instance.status,
};

LiveKitRoomInfo _$LiveKitRoomInfoFromJson(Map<String, dynamic> json) =>
    LiveKitRoomInfo(
      roomName: json['roomName'] as String,
      numParticipants: (json['numParticipants'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$LiveKitRoomInfoToJson(LiveKitRoomInfo instance) =>
    <String, dynamic>{
      'roomName': instance.roomName,
      'numParticipants': instance.numParticipants,
      'isActive': instance.isActive,
    };
