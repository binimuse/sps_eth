import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/Residence_id/models/auth_model.dart';
import 'package:sps_eth_app/app/modules/login/models/login_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part 'auth_service.g.dart';

/// Service for Authentication API integration using Retrofit
/// Follows the project's standard API integration pattern
@RestApi(baseUrl: Constants.baseUrl)
abstract class AuthService {
  factory AuthService(Dio dio) = _AuthService;

  /// Register a new user account
  /// 
  /// Request body:
  /// {
  ///   "id": "1231235163", // Fayda ID
  ///   "phone": "+251923798638",
  ///   "name": "John Doe" // optional, can be extracted from ID lookup
  /// }
  /// 
  /// Expected backend response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "success": true,
  ///     "message": "Account created successfully. Please login with OTP.",
  ///     "user": {
  ///       "id": "8e1b691f-7512-4525-87cf-3dbde273a6eb",
  ///       "phone": "+251923798638",
  ///       "name": "John Doe"
  ///     }
  ///   },
  ///   "meta": {
  ///     "timestamp": "2025-11-18T17:20:43.257Z",
  ///     "requestId": "18969329-32bf-4c62-b68b-dfcfb36d0abf"
  ///   }
  /// }
  @POST(Constants.signupUrl)
  Future<SignupResponse> signup(@Body() Map<String, dynamic> data);

  /// Request OTP for phone verification
  /// 
  /// Request body:
  /// {
  ///   "phone": "+251923798638"
  /// }
  /// 
  /// Expected backend response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "success": true,
  ///     "message": "OTP sent successfully"
  ///   },
  ///   "meta": {
  ///     "timestamp": "2025-11-18T17:34:14.552Z",
  ///     "requestId": "269b0c99-3baa-4d24-885c-1ed2b936773c"
  ///   }
  /// }
  @POST(Constants.requestOtpUrl)
  Future<RequestOtpResponse> requestOtp(@Body() Map<String, dynamic> data);

  /// Verify OTP code
  /// 
  /// Request body:
  /// {
  ///   "phone": "+251923798638",
  ///   "code": "123456"
  /// }
  /// 
  /// Expected backend response (success):
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "success": true,
  ///     "message": "OTP verified successfully",
  ///     "accessToken": "...",
  ///     "refreshToken": "...",
  ///     "user": { ... }
  ///   }
  /// }
  /// 
  /// Expected backend response (error):
  /// {
  ///   "success": false,
  ///   "error": {
  ///     "code": "BadRequestException",
  ///     "message": "Invalid OTP code"
  ///   }
  /// }
  @POST(Constants.verifyOtpUrl)
  Future<VerifyOtpResponse> verifyOtp(@Body() Map<String, dynamic> data);

  /// Anonymous login for video calls
  /// 
  /// Request body:
  /// {
  ///   "deviceId": "device-12345-abcdef"
  /// }
  /// 
  /// Expected backend response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  ///     "user": {
  ///       "id": "3a52c97b-2bdc-4753-90c1-12447fa60c88",
  ///       "phone": null,
  ///       "email": null,
  ///       "name": "Guest-1764012403693-5757",
  ///       "role": {
  ///         "id": "293b3459-ded3-4f81-bca8-ea602ffad049",
  ///         "name": "USER"
  ///       },
  ///       "is2faEnabled": false,
  ///       "isGuest": true
  ///     }
  ///   },
  ///   "meta": {
  ///     "timestamp": "2025-11-24T19:26:43.704Z",
  ///     "requestId": "ee3ead3e-03ff-40f2-8063-37f1f4f8a3a8"
  ///   }
  /// }
  @POST(Constants.anonymousLoginUrl)
  Future<LoginResponse> anonymousLogin(@Body() Map<String, dynamic> data);
}

