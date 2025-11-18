# LiveKit Video Call Integration

This document describes the LiveKit video call integration for the SPS Ethiopia app.

## Overview

The video call functionality uses LiveKit for real-time video and audio communication. The integration is ready for backend REST API connection.

## Setup

### Dependencies

The following packages have been added:
- `livekit_client: ^2.3.0` - LiveKit Flutter SDK
- `permission_handler: ^11.3.1` - For camera and microphone permissions

### Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `CAMERA`
- `RECORD_AUDIO`
- `MODIFY_AUDIO_SETTINGS`

**iOS** (`ios/Runner/Info.plist`):
- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`

## Architecture

### Service Layer

**File**: `lib/app/modules/call_class/services/livekit_service.dart`

This service handles all backend API calls for LiveKit:

1. **`getAccessToken()`** - Gets LiveKit access token and server URL
   - Endpoint: `POST /api/v1/livekit/token`
   - Request body:
     ```json
     {
       "roomName": "room-123",
       "participantName": "John Doe",
       "participantIdentity": "user-123" // optional
     }
     ```
   - Response:
     ```json
     {
       "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
       "url": "wss://your-livekit-server.com"
     }
     ```

2. **`createRoom()`** - Creates a new LiveKit room
   - Endpoint: `POST /api/v1/livekit/room`
   - Request body:
     ```json
     {
       "roomName": "room-123",
       "maxParticipants": 10,
       "emptyTimeout": 300
     }
     ```

3. **`endRoom()`** - Ends/deletes a room
   - Endpoint: `DELETE /api/v1/livekit/room/{roomName}`

4. **`getRoomInfo()`** - Gets room information
   - Endpoint: `GET /api/v1/livekit/room/{roomName}`

### Controller Layer

**File**: `lib/app/modules/call_class/controllers/call_class_controller.dart`

The controller manages:
- Room connection/disconnection
- Video and audio track management
- Participant management
- Permission handling
- State management (connected, video enabled, audio enabled)

**Key Methods**:
- `connectToRoom(roomName, participantName)` - Connects to a LiveKit room
- `disconnectFromRoom()` - Disconnects from the room
- `toggleVideo()` - Enable/disable video
- `toggleAudio()` - Enable/disable audio
- `switchCamera()` - Switch between front/back camera

**Observable State**:
- `isConnected` - Connection status
- `isVideoEnabled` - Video enabled/disabled
- `isAudioEnabled` - Audio enabled/disabled
- `localVideoTrack` - Local participant's video track
- `remoteParticipants` - List of remote participants
- `connectionStatus` - Current connection status string

### View Layer

**File**: `lib/app/modules/call_class/views/call_class_view.dart`

The view displays:
- Main video area (remote participant)
- Picture-in-picture (local participant)
- Video controls (video toggle, audio toggle, end call)
- Connection status

## Usage

### Starting a Video Call

1. Navigate to the call screen (already integrated in your routing)
2. User confirms terms and conditions
3. The `confirmTerms()` method is called, which triggers `connectToRoom()`
4. The controller requests permissions and connects to LiveKit

### Customizing Room Connection

To customize when/how the call starts, modify the `confirmTerms()` method in the controller:

```dart
void confirmTerms() async {
  // Get roomName and participantName from your backend or navigation params
  final roomName = 'room-${DateTime.now().millisecondsSinceEpoch}';
  final participantName = 'Participant-${DateTime.now().millisecondsSinceEpoch}';
  
  await connectToRoom(
    roomName: roomName,
    participantName: participantName,
  );
}
```

### Passing Room Information

You can pass room information via GetX navigation:

```dart
Get.toNamed(
  Routes.CALL_CLASS,
  arguments: {
    'roomName': 'room-123',
    'participantName': 'John Doe',
  },
);
```

Then in the controller's `onInit()`:

```dart
@override
void onInit() {
  super.onInit();
  _loadInitialData();
  
  final args = Get.arguments;
  if (args != null) {
    _roomName = args['roomName'];
    _participantName = args['participantName'];
  }
}
```

## Backend API Requirements

Your backend should implement the following endpoints:

### 1. Get Access Token
**POST** `/api/v1/livekit/token`

Request:
```json
{
  "roomName": "string",
  "participantName": "string",
  "participantIdentity": "string" // optional
}
```

Response:
```json
{
  "accessToken": "string (JWT token)",
  "url": "string (WebSocket URL)"
}
```

### 2. Create Room (Optional)
**POST** `/api/v1/livekit/room`

Request:
```json
{
  "roomName": "string",
  "maxParticipants": 10,
  "emptyTimeout": 300
}
```

### 3. End Room (Optional)
**DELETE** `/api/v1/livekit/room/{roomName}`

### 4. Get Room Info (Optional)
**GET** `/api/v1/livekit/room/{roomName}`

## Testing

1. Ensure your LiveKit server is running
2. Update the base URL in `lib/app/utils/constants.dart` if needed
3. Implement the backend endpoints
4. Test with two devices/participants

## Troubleshooting

### Connection Issues
- Check LiveKit server URL and access token
- Verify network connectivity
- Check backend API responses

### Permission Issues
- Ensure permissions are granted in device settings
- Check AndroidManifest.xml and Info.plist

### Video/Audio Issues
- Verify camera and microphone permissions
- Check device hardware availability
- Review LiveKit server logs

## Next Steps

1. **Backend Integration**: Implement the REST API endpoints as described above
2. **Room Management**: Add room creation/deletion logic if needed
3. **Error Handling**: Enhance error handling and user feedback
4. **UI Enhancements**: Add loading states, connection indicators, etc.
5. **Testing**: Test with multiple participants and different network conditions

## Resources

- [LiveKit Flutter Documentation](https://docs.livekit.io/home/quickstarts/flutter/)
- [LiveKit Server Setup](https://docs.livekit.io/home/self-hosting/)
- [LiveKit Access Token Guide](https://docs.livekit.io/home/security/access-tokens/)

