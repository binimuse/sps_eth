# API Integration Rules & Patterns - SPS Ethiopia

## Project Structure Overview

This document outlines the standard patterns for implementing API integration in the SPS Ethiopia Flutter project. Follow these rules to ensure consistency and prevent errors.

## 1. Base Configuration

### Base URL
```dart
// lib/app/utils/constants.dart
static const baseUrl = "https://sps-admin.zorcloud.net/api/v1/";
```

### DioUtil Pattern
Always use `DioUtil().getDio(useAccessToken: true)` for authenticated endpoints:
```dart
final dio = DioUtil().getDio(useAccessToken: true);
```

## 2. Model Pattern

### File Location: `lib/app/modules/{feature}/models/{feature}_model.dart`

### Template:
```dart
import 'package:json_annotation/json_annotation.dart';

part '{feature}_model.g.dart';

@JsonSerializable()
class {Feature}Response {
  const {Feature}Response({
    this.message,
    this.data,
    this.status,
  });

  factory {Feature}Response.fromJson(Map<String, dynamic> json) =>
      _${Feature}ResponseFromJson(json);

  final String? message;
  final {Feature}? data; // or List<{Feature}>? for list responses
  final bool? status;

  Map<String, dynamic> toJson() => _${Feature}ResponseToJson(this);
}

@JsonSerializable()
class {Feature} {
  const {Feature}({
    this.id,
    this.name,
    // Add other fields as needed
  });

  factory {Feature}.fromJson(Map<String, dynamic> json) =>
      _${Feature}FromJson(json);

  final String? id;
  final String? name;
  // Add other fields

  // Computed properties (getters) if needed
  String? get imageUrl => imagePath != null
      ? 'https://sps-admin.zorcloud.net/$imagePath'
      : null;

  Map<String, dynamic> toJson() => _${Feature}ToJson(this);
}
```

### Example (LiveKit Token Response):
```dart
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
```

## 3. Service Pattern (Retrofit)

### File Location: `lib/app/modules/{feature}/services/{feature}_service.dart`

### Template:
```dart
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/{feature}/models/{feature}_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part '{feature}_service.g.dart';

@RestApi(baseUrl: Constants.baseUrl)
abstract class {Feature}Service {
  factory {Feature}Service(Dio dio) = _{Feature}Service;

  @GET(Constants.get{Feature}s)
  Future<{Feature}Response> get{Feature}s();

  @GET(Constants.get{Feature}ById)
  Future<{Feature}Response> get{Feature}ById(@Path('id') String id);

  @POST(Constants.create{Feature})
  Future<{Feature}Response> create{Feature}(@Body() Map<String, dynamic> data);

  @PUT(Constants.update{Feature})
  Future<{Feature}Response> update{Feature}(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @DELETE(Constants.delete{Feature})
  Future<void> delete{Feature}(@Path('id') String id);
}
```

### Example (LiveKit Service with Retrofit):
```dart
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/call_class/models/livekit_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part 'livekit_service.g.dart';

@RestApi(baseUrl: Constants.baseUrl)
abstract class LiveKitService {
  factory LiveKitService(Dio dio) = _LiveKitService;

  @POST(Constants.liveKitGetToken)
  Future<LiveKitTokenResponse> getAccessToken(@Body() Map<String, dynamic> data);

  @POST(Constants.liveKitCreateRoom)
  Future<LiveKitRoomResponse> createRoom(@Body() Map<String, dynamic> data);

  @DELETE(Constants.liveKitEndRoom)
  Future<void> endRoom(@Path('roomName') String roomName);

  @GET(Constants.liveKitGetRoomInfo)
  Future<LiveKitRoomInfoResponse> getRoomInfo(@Path('roomName') String roomName);
}
```

## 4. Constants Pattern

### File Location: `lib/app/utils/constants.dart`

### Template:
```dart
// Add these constants to the existing constants file
static const get{Feature}s = "/{feature}s";
static const get{Feature}ById = "/{feature}s/{id}";
static const create{Feature} = "/{feature}s";
static const update{Feature} = "/{feature}s/{id}";
static const delete{Feature} = "/{feature}s/{id}";
```

### Example:
```dart
// LiveKit video call endpoints
static const liveKitGetToken = "/livekit/token";
static const liveKitCreateRoom = "/livekit/room";
static const liveKitEndRoom = "/livekit/room/{roomName}";
static const liveKitGetRoomInfo = "/livekit/room/{roomName}";
```

## 5. Controller Pattern

### File Location: `lib/app/modules/{feature}/controllers/{feature}_controller.dart`

### Template:
```dart
import 'package:get/get.dart';
import 'package:sps_eth_app/app/modules/{feature}/models/{feature}_model.dart';
import 'package:sps_eth_app/app/modules/{feature}/services/{feature}_service.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';

class {Feature}Controller extends GetxController {
  // Network status
  final Rx<NetworkStatus> networkStatus = NetworkStatus.IDLE.obs;

  // Data lists
  final RxList<{Feature}> {feature}s = <{Feature}>[].obs;

  // Selected item
  final Rx<{Feature}?> selected{Feature} = Rx<{Feature}?>(null);

  @override
  void onInit() {
    super.onInit();
    _load{Feature}s();
  }

  void _load{Feature}s() async {
    networkStatus.value = NetworkStatus.LOADING;

    try {
      final response = await {Feature}Service(
        DioUtil().getDio(useAccessToken: true),
      ).get{Feature}s();

      if (response.status == true && response.data != null) {
        // For list responses
        if (response.data is List) {
          {feature}s.assignAll(response.data as List<{Feature}>);
        } else {
          // For single object responses
          {feature}s.assignAll([response.data as {Feature}]);
        }
        networkStatus.value = NetworkStatus.SUCCESS;
      } else {
        networkStatus.value = NetworkStatus.ERROR;
        AppToasts.showError(response.message ?? 'Failed to load {feature}s');
      }
    } catch (e, s) {
      print('Error loading {feature}s: $e');
      print('Stack trace: $s');
      networkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError('Failed to load {feature}s');
    }
  }

  void select{Feature}({Feature} {feature}) {
    selected{Feature}.value = {feature};
  }

  void create{Feature}(Map<String, dynamic> data) async {
    networkStatus.value = NetworkStatus.LOADING;

    try {
      final response = await {Feature}Service(
        DioUtil().getDio(useAccessToken: true),
      ).create{Feature}(data);

      if (response.status == true && response.data != null) {
        {feature}s.add(response.data!);
        networkStatus.value = NetworkStatus.SUCCESS;
        AppToasts.showSuccess(response.message ?? '{Feature} created successfully');
      } else {
        networkStatus.value = NetworkStatus.ERROR;
        AppToasts.showError(response.message ?? 'Failed to create {feature}');
      }
    } catch (e, s) {
      print('Error creating {feature}: $e');
      print('Stack trace: $s');
      networkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError('Failed to create {feature}');
    }
  }

  void update{Feature}(String id, Map<String, dynamic> data) async {
    networkStatus.value = NetworkStatus.LOADING;

    try {
      final response = await {Feature}Service(
        DioUtil().getDio(useAccessToken: true),
      ).update{Feature}(id, data);

      if (response.status == true && response.data != null) {
        final index = {feature}s.indexWhere((item) => item.id == id);
        if (index != -1) {
          {feature}s[index] = response.data!;
        }
        networkStatus.value = NetworkStatus.SUCCESS;
        AppToasts.showSuccess(response.message ?? '{Feature} updated successfully');
      } else {
        networkStatus.value = NetworkStatus.ERROR;
        AppToasts.showError(response.message ?? 'Failed to update {feature}');
      }
    } catch (e, s) {
      print('Error updating {feature}: $e');
      print('Stack trace: $s');
      networkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError('Failed to update {feature}');
    }
  }

  void delete{Feature}(String id) async {
    networkStatus.value = NetworkStatus.LOADING;

    try {
      await {Feature}Service(
        DioUtil().getDio(useAccessToken: true),
      ).delete{Feature}(id);

      {feature}s.removeWhere((item) => item.id == id);
      networkStatus.value = NetworkStatus.SUCCESS;
      AppToasts.showSuccess('{Feature} deleted successfully');
    } catch (e, s) {
      print('Error deleting {feature}: $e');
      print('Stack trace: $s');
      networkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError('Failed to delete {feature}');
    }
  }
}
```

### Example (LiveKit Controller):
```dart
import 'package:get/get.dart';
import 'package:sps_eth_app/app/modules/call_class/models/livekit_model.dart';
import 'package:sps_eth_app/app/modules/call_class/services/livekit_service.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';

class CallClassController extends GetxController {
  // Network status
  final Rx<NetworkStatus> networkStatus = NetworkStatus.IDLE.obs;

  // LiveKit token
  final Rx<LiveKitTokenData?> liveKitToken = Rx<LiveKitTokenData?>(null);

  Future<void> getLiveKitToken({
    required String roomName,
    required String participantName,
  }) async {
    networkStatus.value = NetworkStatus.LOADING;

    try {
      final response = await LiveKitService(
        DioUtil().getDio(useAccessToken: true),
      ).getAccessToken({
        'roomName': roomName,
        'participantName': participantName,
      });

      if (response.status == true && response.data != null) {
        liveKitToken.value = response.data;
        networkStatus.value = NetworkStatus.SUCCESS;
      } else {
        networkStatus.value = NetworkStatus.ERROR;
        AppToasts.showError(response.message ?? 'Failed to get LiveKit token');
      }
    } catch (e, s) {
      print('Error getting LiveKit token: $e');
      print('Stack trace: $s');
      networkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError('Failed to get LiveKit token');
    }
  }
}
```

## 6. View Pattern

### File Location: `lib/app/modules/{feature}/views/{feature}_view.dart`

### Template:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/common/widgets/custom_loading_widget.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import '../controllers/{feature}_controller.dart';

class {Feature}View extends GetView<{Feature}Controller> {
  const {Feature}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main content
          Obx(() {
            if (controller.networkStatus.value == NetworkStatus.LOADING) {
              return const Center(child: CustomLoadingWidget());
            }

            if (controller.{feature}s.isEmpty) {
              return Center(
                child: Text(
                  'No {feature}s available',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grayDark,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.{feature}s.length,
              itemBuilder: (context, index) {
                final {feature} = controller.{feature}s[index];
                return _build{Feature}Card({feature});
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _build{Feature}Card({Feature} {feature}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text({feature}.name ?? ''),
        onTap: () => controller.select{Feature}({feature}),
      ),
    );
  }
}
```

## 7. DioUtil Authentication Pattern

### Always use this pattern for API calls:

```dart
// For authenticated endpoints
DioUtil().getDio(useAccessToken: true)

// For public endpoints (if any)
DioUtil().getDio(useAccessToken: false)
```

## 8. Error Handling Pattern

### Always include these in controllers:
```dart
try {
  // API call
  if (response.status == true && response.data != null) {
    // Handle success
    networkStatus.value = NetworkStatus.SUCCESS;
  } else {
    // Handle API error response
    networkStatus.value = NetworkStatus.ERROR;
    AppToasts.showError(response.message ?? 'Operation failed');
  }
} catch (e, s) {
  print('Error: $e');
  print('Stack trace: $s');
  networkStatus.value = NetworkStatus.ERROR;
  AppToasts.showError('Operation failed');
}
```

## 9. Loading State Pattern

### Always use this in views:
```dart
Stack(
  children: [
    // Main content
    YourContent(),
    
    // Loading overlay
    Obx(
      () => controller.networkStatus.value == NetworkStatus.LOADING
          ? const Center(child: CustomLoadingWidget())
          : const SizedBox(),
    ),
  ],
)
```

## 10. Code Generation Commands

### After creating models and services, run:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### For continuous generation:
```bash
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

## 11. File Naming Conventions

- Models: `{feature}_model.dart` in `lib/app/modules/{feature}/models/`
- Services: `{feature}_service.dart` in `lib/app/modules/{feature}/services/`
- Controllers: `{feature}_controller.dart` in `lib/app/modules/{feature}/controllers/`
- Views: `{feature}_view.dart` in `lib/app/modules/{feature}/views/`
- Generated files: `{feature}_model.g.dart`, `{feature}_service.g.dart`

## 12. Import Patterns

### Standard imports for models:
```dart
import 'package:json_annotation/json_annotation.dart';
```

### Standard imports for services:
```dart
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/utils/constants.dart';
```

### Standard imports for controllers:
```dart
import 'package:get/get.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';
```

### Standard imports for views:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/common/widgets/custom_loading_widget.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
```

## 13. API Base URLs

- Main API: `https://sps-admin.zorcloud.net/api/v1/`
- Image Server: Update based on your backend configuration

## 14. Authentication Headers

### The DioUtil automatically adds:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

## 15. Response Handling

### Standard API Response Structure:
```json
{
  "status": true,
  "message": "Success message",
  "data": { ... } // or [ ... ] for lists
}
```

### For list responses:
```dart
final response = await Service(DioUtil().getDio(useAccessToken: true)).getItems();
if (response.status == true && response.data != null) {
  items.assignAll(response.data as List<Item>);
}
```

### For single object responses:
```dart
final response = await Service(DioUtil().getDio(useAccessToken: true)).getItem(id);
if (response.status == true && response.data != null) {
  item.value = response.data;
}
```

## 16. Validation Checklist

Before implementing any API integration:

1. ✅ Model has proper JSON annotations
2. ✅ Service has correct Retrofit annotations
3. ✅ Constants are added to constants.dart
4. ✅ Controller handles loading states
5. ✅ View shows loading overlay
6. ✅ Error handling is implemented
7. ✅ Code generation is run
8. ✅ Authentication is properly configured
9. ✅ Image URLs are constructed correctly (if needed)
10. ✅ Navigation is implemented (if needed)

## 17. Common Mistakes to Avoid

1. ❌ Forgetting to run `build_runner build --delete-conflicting-outputs`
2. ❌ Not handling loading states
3. ❌ Missing error handling
4. ❌ Incorrect authentication headers
5. ❌ Wrong API base URL
6. ❌ Missing image URL construction
7. ❌ Not using Obx for reactive UI
8. ❌ Forgetting to dispose controllers
9. ❌ Not checking `response.status` before accessing `response.data`
10. ❌ Not handling null responses

## 18. Testing Checklist

After implementation:

1. ✅ API calls work with authentication
2. ✅ Loading states display correctly
3. ✅ Error states handle gracefully
4. ✅ Images load properly (if applicable)
5. ✅ Navigation works as expected
6. ✅ No console errors
7. ✅ UI is responsive
8. ✅ Data persists correctly
9. ✅ Network errors are handled
10. ✅ Empty states are displayed

## 19. Project-Specific Notes

### Module Structure:
```
lib/app/modules/{feature}/
  ├── models/
  │   └── {feature}_model.dart
  ├── services/
  │   └── {feature}_service.dart
  ├── controllers/
  │   └── {feature}_controller.dart
  ├── views/
  │   └── {feature}_view.dart
  └── bindings/
      └── {feature}_binding.dart
```

### Toast Messages:
Use `AppToasts.showSuccess()`, `AppToasts.showError()`, or `AppToasts.showWarning()`

### Loading Widget:
Use `CustomLoadingWidget()` from `lib/app/common/widgets/custom_loading_widget.dart`

### Network Status:
Use `NetworkStatus` enum from `lib/app/utils/enums.dart`:
- `NetworkStatus.IDLE`
- `NetworkStatus.LOADING`
- `NetworkStatus.SUCCESS`
- `NetworkStatus.ERROR`

---

**Remember**: Always follow these patterns exactly to ensure consistency and prevent errors. This document should be referenced before implementing any new API integration.

