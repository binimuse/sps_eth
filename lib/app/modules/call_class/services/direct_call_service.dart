import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/call_class/models/direct_call_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part 'direct_call_service.g.dart';

/// Service for Direct Call API integration using Retrofit
/// Follows the project's standard API integration pattern
@RestApi(baseUrl: Constants.baseUrl)
abstract class DirectCallService {
  factory DirectCallService(Dio dio) = _DirectCallService;

  /// Request a call (Client/User role)
  /// 
  /// Request body: {} (empty)
  /// 
  /// Response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "token": "livekit-jwt-token",
  ///     "roomName": "call-1234567890-abc123",
  ///     "sessionId": "session-uuid",
  ///     "wsUrl": "wss://your-livekit-server.com"
  ///   },
  ///   "meta": { ... }
  /// }
  @POST(Constants.directCallRequest)
  Future<DirectCallResponseWrapper> requestCall();

  /// Accept a call (Employee role)
  /// 
  /// Response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "token": "livekit-jwt-token",
  ///     "roomName": "call-1234567890-abc123",
  ///     "sessionId": "session-uuid",
  ///     "wsUrl": "wss://your-livekit-server.com"
  ///   },
  ///   "meta": { ... }
  /// }
  @POST(Constants.directCallAccept)
  Future<DirectCallResponseWrapper> acceptCall(@Path('sessionId') String sessionId);

  /// Reject a call (Employee role)
  /// 
  /// Response:
  /// {
  ///   "message": "Call rejected"
  /// }
  @POST(Constants.directCallReject)
  Future<CallActionResponse> rejectCall(@Path('sessionId') String sessionId);

  /// End a call (Both USER and EMPLOYEE roles)
  /// 
  /// Response:
  /// {
  ///   "message": "Call ended"
  /// }
  @POST(Constants.directCallEnd)
  Future<CallActionResponse> endCall(@Path('sessionId') String sessionId);

  /// Get pending calls (Employee role)
  /// 
  /// Response:
  /// [
  ///   {
  ///     "id": "session-uuid",
  ///     "roomName": "call-1234567890-abc123",
  ///     "status": "PENDING",
  ///     "callerId": "caller-uuid",
  ///     "receiverId": "employee-uuid",
  ///     "createdAt": "2024-01-01T12:00:00Z",
  ///     "caller": {
  ///       "id": "caller-uuid",
  ///       "name": "John Doe",
  ///       "phone": "+1234567890",
  ///       "email": "john@example.com"
  ///     }
  ///   }
  /// ]
  @GET(Constants.directCallPending)
  Future<List<PendingCall>> getPendingCalls();

  /// Get call details by session ID
  /// 
  /// Response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "id": "session-uuid",
  ///     "caller": {
  ///       "id": "caller-uuid",
  ///       "name": "John Doe",
  ///       "phone": "+1234567890",
  ///       "email": "john@example.com"
  ///     },
  ///     "receiver": {
  ///       "id": "receiver-uuid",
  ///       "name": "Jane Doe",
  ///       "phone": "+1234567891",
  ///       "email": "jane@example.com"
  ///     },
  ///     "roomName": "call-1234567890-abc123",
  ///     "status": "ACTIVE",
  ///     "startedAt": "2024-01-01T12:00:00Z",
  ///     "endedAt": null,
  ///     "createdAt": "2024-01-01T12:00:00Z",
  ///     "updatedAt": "2024-01-01T12:00:00Z"
  ///   },
  ///   "meta": { ... }
  /// }
  @GET(Constants.directCallDetails)
  Future<CallDetailsResponseWrapper> getCallDetails(@Path('sessionId') String sessionId);
}

