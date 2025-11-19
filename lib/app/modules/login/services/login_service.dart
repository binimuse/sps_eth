import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/login/models/login_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part 'login_service.g.dart';

/// Service for Login API integration using Retrofit
/// Follows the project's standard API integration pattern
@RestApi(baseUrl: Constants.baseUrl)
abstract class LoginService {
  factory LoginService(Dio dio) = _LoginService;

  /// Login with phone and password
  /// 
  /// Request body:
  /// {
  ///   "phone": "+251900000000",
  ///   "password": "Admin123!"
  /// }
  /// 
  /// Expected backend response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  ///     "refreshToken": "323f0996935c3a2291751e8d7ff55d9dbfbc455e0fd0a7defa1fd1bafcbcc2e8",
  ///     "user": {
  ///       "id": "60de9eaa-34ac-4133-ad17-35c4ca3df1ee",
  ///       "phone": "+251900000000",
  ///       "email": "admin@example.com",
  ///       "name": "System Administrator",
  ///       "role": {
  ///         "id": "3cc8f9e9-2aa7-4fc6-a053-aefd1a98b9e1",
  ///         "name": "ADMIN"
  ///       },
  ///       "is2faEnabled": false
  ///     }
  ///   },
  ///   "meta": {
  ///     "timestamp": "2025-11-19T08:17:17.690Z",
  ///     "requestId": "bba4e51c-919c-43ff-927f-3fcf027f7046"
  ///   }
  /// }
  @POST(Constants.loginUrl)
  Future<LoginResponse> login(@Body() Map<String, dynamic> data);
}

