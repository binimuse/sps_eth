// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_call_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectCallResponseWrapper _$DirectCallResponseWrapperFromJson(
  Map<String, dynamic> json,
) => DirectCallResponseWrapper(
  success: json['success'] as bool?,
  data: json['data'] == null
      ? null
      : RequestCallResponse.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'] == null
      ? null
      : DirectCallMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DirectCallResponseWrapperToJson(
  DirectCallResponseWrapper instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
};

DirectCallMeta _$DirectCallMetaFromJson(Map<String, dynamic> json) =>
    DirectCallMeta(
      timestamp: json['timestamp'] as String?,
      requestId: json['requestId'] as String?,
    );

Map<String, dynamic> _$DirectCallMetaToJson(DirectCallMeta instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'requestId': instance.requestId,
    };

RequestCallResponse _$RequestCallResponseFromJson(Map<String, dynamic> json) =>
    RequestCallResponse(
      token: json['token'] as String?,
      roomName: json['roomName'] as String?,
      sessionId: json['sessionId'] as String?,
      wsUrl: json['wsUrl'] as String?,
    );

Map<String, dynamic> _$RequestCallResponseToJson(
  RequestCallResponse instance,
) => <String, dynamic>{
  'token': instance.token,
  'roomName': instance.roomName,
  'sessionId': instance.sessionId,
  'wsUrl': instance.wsUrl,
};

AcceptCallResponse _$AcceptCallResponseFromJson(Map<String, dynamic> json) =>
    AcceptCallResponse(
      token: json['token'] as String?,
      roomName: json['roomName'] as String?,
      sessionId: json['sessionId'] as String?,
      wsUrl: json['wsUrl'] as String?,
    );

Map<String, dynamic> _$AcceptCallResponseToJson(AcceptCallResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'roomName': instance.roomName,
      'sessionId': instance.sessionId,
      'wsUrl': instance.wsUrl,
    };

CallActionResponse _$CallActionResponseFromJson(Map<String, dynamic> json) =>
    CallActionResponse(message: json['message'] as String?);

Map<String, dynamic> _$CallActionResponseToJson(CallActionResponse instance) =>
    <String, dynamic>{'message': instance.message};

PendingCall _$PendingCallFromJson(Map<String, dynamic> json) => PendingCall(
  id: json['id'] as String?,
  roomName: json['roomName'] as String?,
  status: json['status'] as String?,
  callerId: json['callerId'] as String?,
  receiverId: json['receiverId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  caller: json['caller'] == null
      ? null
      : CallerInfo.fromJson(json['caller'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PendingCallToJson(PendingCall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomName': instance.roomName,
      'status': instance.status,
      'callerId': instance.callerId,
      'receiverId': instance.receiverId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'caller': instance.caller,
    };

CallerInfo _$CallerInfoFromJson(Map<String, dynamic> json) => CallerInfo(
  id: json['id'] as String?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$CallerInfoToJson(CallerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
    };

IncomingCallEvent _$IncomingCallEventFromJson(Map<String, dynamic> json) =>
    IncomingCallEvent(
      sessionId: json['sessionId'] as String?,
      roomName: json['roomName'] as String?,
      callerId: json['callerId'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$IncomingCallEventToJson(IncomingCallEvent instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'roomName': instance.roomName,
      'callerId': instance.callerId,
      'createdAt': instance.createdAt,
    };

CallAcceptedEvent _$CallAcceptedEventFromJson(Map<String, dynamic> json) =>
    CallAcceptedEvent(
      sessionId: json['sessionId'] as String?,
      roomName: json['roomName'] as String?,
    );

Map<String, dynamic> _$CallAcceptedEventToJson(CallAcceptedEvent instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'roomName': instance.roomName,
    };

CallRejectedEvent _$CallRejectedEventFromJson(Map<String, dynamic> json) =>
    CallRejectedEvent(
      sessionId: json['sessionId'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$CallRejectedEventToJson(CallRejectedEvent instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'message': instance.message,
    };

CallEndedEvent _$CallEndedEventFromJson(Map<String, dynamic> json) =>
    CallEndedEvent(
      sessionId: json['sessionId'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$CallEndedEventToJson(CallEndedEvent instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'duration': instance.duration,
      'message': instance.message,
    };
