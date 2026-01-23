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

RequestCallRequest _$RequestCallRequestFromJson(Map<String, dynamic> json) =>
    RequestCallRequest(
      isVisitor: json['isVisitor'] as bool?,
      preferredLanguage: json['preferredLanguage'] as String?,
    );

Map<String, dynamic> _$RequestCallRequestToJson(RequestCallRequest instance) =>
    <String, dynamic>{
      'isVisitor': instance.isVisitor,
      'preferredLanguage': instance.preferredLanguage,
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

ReportTypeInfo _$ReportTypeInfoFromJson(Map<String, dynamic> json) =>
    ReportTypeInfo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      nameAmharic: json['nameAmharic'] as String?,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$ReportTypeInfoToJson(ReportTypeInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameAmharic': instance.nameAmharic,
      'code': instance.code,
    };

ReportInfo _$ReportInfoFromJson(Map<String, dynamic> json) => ReportInfo(
  id: json['id'] as String?,
  caseNumber: json['caseNumber'] as String?,
  reportType: json['reportType'] == null
      ? null
      : ReportTypeInfo.fromJson(json['reportType'] as Map<String, dynamic>),
  submitted: json['submitted'] as bool?,
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReportInfoToJson(ReportInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseNumber': instance.caseNumber,
      'reportType': instance.reportType,
      'submitted': instance.submitted,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

PersonInfo _$PersonInfoFromJson(Map<String, dynamic> json) => PersonInfo(
  id: json['id'] as String?,
  fullName: json['fullName'] as String?,
  sex: json['sex'] as String?,
  age: (json['age'] as num?)?.toInt(),
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  phoneMobile: json['phoneMobile'] as String?,
  nationality: json['nationality'] as String?,
);

Map<String, dynamic> _$PersonInfoToJson(PersonInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'sex': instance.sex,
      'age': instance.age,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'phoneMobile': instance.phoneMobile,
      'nationality': instance.nationality,
    };

StatementInfo _$StatementInfoFromJson(Map<String, dynamic> json) =>
    StatementInfo(
      id: json['id'] as String?,
      reportId: json['reportId'] as String?,
      statementTakerName: json['statementTakerName'] as String?,
      person: json['person'] == null
          ? null
          : PersonInfo.fromJson(json['person'] as Map<String, dynamic>),
      applicantType: json['applicantType'] as String?,
      statement: json['statement'] as String?,
      statementDate: json['statementDate'] == null
          ? null
          : DateTime.parse(json['statementDate'] as String),
      statementTime: json['statementTime'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StatementInfoToJson(StatementInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportId': instance.reportId,
      'statementTakerName': instance.statementTakerName,
      'person': instance.person,
      'applicantType': instance.applicantType,
      'statement': instance.statement,
      'statementDate': instance.statementDate?.toIso8601String(),
      'statementTime': instance.statementTime,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

CallDetailsResponse _$CallDetailsResponseFromJson(Map<String, dynamic> json) =>
    CallDetailsResponse(
      id: json['id'] as String?,
      caller: json['caller'] == null
          ? null
          : CallerInfo.fromJson(json['caller'] as Map<String, dynamic>),
      receiver: json['receiver'] == null
          ? null
          : CallerInfo.fromJson(json['receiver'] as Map<String, dynamic>),
      report: json['report'] == null
          ? null
          : ReportInfo.fromJson(json['report'] as Map<String, dynamic>),
      statement: json['statement'] == null
          ? null
          : StatementInfo.fromJson(json['statement'] as Map<String, dynamic>),
      roomName: json['roomName'] as String?,
      status: json['status'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CallDetailsResponseToJson(
  CallDetailsResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'caller': instance.caller,
  'receiver': instance.receiver,
  'report': instance.report,
  'statement': instance.statement,
  'roomName': instance.roomName,
  'status': instance.status,
  'startedAt': instance.startedAt?.toIso8601String(),
  'endedAt': instance.endedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

CallDetailsResponseWrapper _$CallDetailsResponseWrapperFromJson(
  Map<String, dynamic> json,
) => CallDetailsResponseWrapper(
  success: json['success'] as bool?,
  data: json['data'] == null
      ? null
      : CallDetailsResponse.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'] == null
      ? null
      : DirectCallMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CallDetailsResponseWrapperToJson(
  CallDetailsResponseWrapper instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
};
