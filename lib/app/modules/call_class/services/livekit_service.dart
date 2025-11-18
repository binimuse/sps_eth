import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/call_class/models/livekit_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part 'livekit_service.g.dart';

/// Service for LiveKit API integration using Retrofit
/// Follows the project's standard API integration pattern
@RestApi(baseUrl: Constants.baseUrl)
abstract class LiveKitService {
  factory LiveKitService(Dio dio) = _LiveKitService;

  /// Get access token for LiveKit room
  /// 
  /// Request body:
  /// {
  ///   "roomName": "room-123",
  ///   "participantName": "John Doe",
  ///   "participantIdentity": "user-123" // optional
  /// }
  /// 
  /// Expected backend response:
  /// {
  ///   "status": true,
  ///   "message": "Token generated successfully",
  ///   "data": {
  ///     "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  ///     "url": "wss://your-livekit-server.com"
  ///   }
  /// }
  @POST(Constants.liveKitGetToken)
  Future<LiveKitTokenResponse> getAccessToken(@Body() Map<String, dynamic> data);

  /// Create a new room
  /// 
  /// Request body:
  /// {
  ///   "roomName": "room-123",
  ///   "maxParticipants": 10,
  ///   "emptyTimeout": 300
  /// }
  /// 
  /// Expected backend response:
  /// {
  ///   "status": true,
  ///   "message": "Room created successfully",
  ///   "data": {
  ///     "roomName": "room-123",
  ///     "roomId": "room-123",
  ///     "createdAt": "2024-01-01T00:00:00Z"
  ///   }
  /// }
  @POST(Constants.liveKitCreateRoom)
  Future<LiveKitRoomResponse> createRoom(@Body() Map<String, dynamic> data);

  /// End/Delete a room
  /// 
  /// Expected backend response:
  /// {
  ///   "status": true,
  ///   "message": "Room ended successfully"
  /// }
  @DELETE(Constants.liveKitEndRoom)
  Future<void> endRoom(@Path('roomName') String roomName);

  /// Get room information
  /// 
  /// Expected backend response:
  /// {
  ///   "status": true,
  ///   "message": "Room info retrieved successfully",
  ///   "data": {
  ///     "roomName": "room-123",
  ///     "numParticipants": 2,
  ///     "isActive": true
  ///   }
  /// }
  @GET(Constants.liveKitGetRoomInfo)
  Future<LiveKitRoomInfoResponse> getRoomInfo(@Path('roomName') String roomName);
}

