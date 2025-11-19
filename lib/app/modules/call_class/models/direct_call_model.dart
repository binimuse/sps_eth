import 'package:json_annotation/json_annotation.dart';

part 'direct_call_model.g.dart';

// Wrapper for API responses with success/data/meta structure
@JsonSerializable()
class DirectCallResponseWrapper {
  const DirectCallResponseWrapper({
    this.success,
    this.data,
    this.meta,
  });

  factory DirectCallResponseWrapper.fromJson(Map<String, dynamic> json) =>
      _$DirectCallResponseWrapperFromJson(json);

  final bool? success;
  final RequestCallResponse? data;
  final DirectCallMeta? meta;

  Map<String, dynamic> toJson() => _$DirectCallResponseWrapperToJson(this);
}

// Meta information for API responses
@JsonSerializable()
class DirectCallMeta {
  const DirectCallMeta({
    this.timestamp,
    this.requestId,
  });

  factory DirectCallMeta.fromJson(Map<String, dynamic> json) =>
      _$DirectCallMetaFromJson(json);

  final String? timestamp;
  final String? requestId;

  Map<String, dynamic> toJson() => _$DirectCallMetaToJson(this);
}

// Request Call Response (data field)
@JsonSerializable()
class RequestCallResponse {
  const RequestCallResponse({
    this.token,
    this.roomName,
    this.sessionId,
    this.wsUrl,
  });

  factory RequestCallResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestCallResponseFromJson(json);

  final String? token;
  final String? roomName;
  final String? sessionId;
  final String? wsUrl;

  Map<String, dynamic> toJson() => _$RequestCallResponseToJson(this);
}

// Accept Call Response (same structure as Request)
@JsonSerializable()
class AcceptCallResponse {
  const AcceptCallResponse({
    this.token,
    this.roomName,
    this.sessionId,
    this.wsUrl,
  });

  factory AcceptCallResponse.fromJson(Map<String, dynamic> json) =>
      _$AcceptCallResponseFromJson(json);

  final String? token;
  final String? roomName;
  final String? sessionId;
  final String? wsUrl;

  Map<String, dynamic> toJson() => _$AcceptCallResponseToJson(this);
}

// Reject/End Call Response
@JsonSerializable()
class CallActionResponse {
  const CallActionResponse({
    this.message,
  });

  factory CallActionResponse.fromJson(Map<String, dynamic> json) =>
      _$CallActionResponseFromJson(json);

  final String? message;

  Map<String, dynamic> toJson() => _$CallActionResponseToJson(this);
}

// Pending Call Item
@JsonSerializable()
class PendingCall {
  const PendingCall({
    this.id,
    this.roomName,
    this.status,
    this.callerId,
    this.receiverId,
    this.createdAt,
    this.caller,
  });

  factory PendingCall.fromJson(Map<String, dynamic> json) =>
      _$PendingCallFromJson(json);

  final String? id;
  final String? roomName;
  final String? status;
  final String? callerId;
  final String? receiverId;
  final DateTime? createdAt;
  final CallerInfo? caller;

  Map<String, dynamic> toJson() => _$PendingCallToJson(this);
}

@JsonSerializable()
class CallerInfo {
  const CallerInfo({
    this.id,
    this.name,
    this.phone,
    this.email,
  });

  factory CallerInfo.fromJson(Map<String, dynamic> json) =>
      _$CallerInfoFromJson(json);

  final String? id;
  final String? name;
  final String? phone;
  final String? email;

  Map<String, dynamic> toJson() => _$CallerInfoToJson(this);
}

// WebSocket Event Payloads
@JsonSerializable()
class IncomingCallEvent {
  const IncomingCallEvent({
    this.sessionId,
    this.roomName,
    this.callerId,
    this.createdAt,
  });

  factory IncomingCallEvent.fromJson(Map<String, dynamic> json) =>
      _$IncomingCallEventFromJson(json);

  final String? sessionId;
  final String? roomName;
  final String? callerId;
  final String? createdAt;

  Map<String, dynamic> toJson() => _$IncomingCallEventToJson(this);
}

@JsonSerializable()
class CallAcceptedEvent {
  const CallAcceptedEvent({
    this.sessionId,
    this.roomName,
  });

  factory CallAcceptedEvent.fromJson(Map<String, dynamic> json) =>
      _$CallAcceptedEventFromJson(json);

  final String? sessionId;
  final String? roomName;

  Map<String, dynamic> toJson() => _$CallAcceptedEventToJson(this);
}

@JsonSerializable()
class CallRejectedEvent {
  const CallRejectedEvent({
    this.sessionId,
    this.message,
  });

  factory CallRejectedEvent.fromJson(Map<String, dynamic> json) =>
      _$CallRejectedEventFromJson(json);

  final String? sessionId;
  final String? message;

  Map<String, dynamic> toJson() => _$CallRejectedEventToJson(this);
}

@JsonSerializable()
class CallEndedEvent {
  const CallEndedEvent({
    this.sessionId,
    this.duration,
    this.message,
  });

  factory CallEndedEvent.fromJson(Map<String, dynamic> json) =>
      _$CallEndedEventFromJson(json);

  final String? sessionId;
  final int? duration;
  final String? message;

  Map<String, dynamic> toJson() => _$CallEndedEventToJson(this);
}

