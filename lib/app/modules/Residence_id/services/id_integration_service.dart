import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/Residence_id/models/id_integration_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part 'id_integration_service.g.dart';

/// Service for ID Integration API (Fayda ID) using Retrofit
/// Uses a different base URL than the main API
@RestApi(baseUrl: Constants.baseUrl)
abstract class IdIntegrationService {
  factory IdIntegrationService(Dio dio) = _IdIntegrationService;

  /// Request OTP for Fayda ID verification
  /// 
  /// Request body:
  /// {
  ///   "individualId": "602571859769"
  /// }
  /// 
  /// Success response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "id": "uhdms",
  ///     "version": "1.0",
  ///     "responseTime": "2026-01-23T18:38:46.649",
  ///     "transactionID": "60029197-7950-4b95-b292-14774567e6d8",
  ///     "response": {
  ///       "maskedMobile": "09xxxxxx40",
  ///       "maskedEmail": ""
  ///     },
  ///     "errors": null
  ///   },
  ///   "meta": {
  ///     "timestamp": "2026-01-23T18:38:48.574Z",
  ///     "requestId": "24a86ffc-ef5f-4b14-b02a-c336d44a1e7e"
  ///   }
  /// }
  /// 
  /// Error response:
  /// {
  ///   "statusCode": 400,
  ///   "message": "Bad Request",
  ///   "error": "Invalid input parameters",
  ///   "timestamp": "2024-01-15T10:30:00.000Z"
  /// }
  @POST("id-integration/nid/request-otp")
  Future<FaydaOtpResponse> requestOtp(@Body() FaydaOtpRequest request);

  /// Verify OTP and get user data
  /// 
  /// Request body:
  /// {
  ///   "individualId": "602571859769",
  ///   "transactionID": "550e8400-e29b-41d4-a716-446655440000",
  ///   "otp": "123456"
  /// }
  /// 
  /// Success response:
  /// {
  ///   "individualId": "602571859769",
  ///   "name": "John Doe",
  ///   "dateOfBirth": "1990-01-01",
  ///   "status": "verified",
  ///   "nationality": "Ethiopian",
  ///   "gender": "Male"
  /// }
  /// 
  /// Error response:
  /// {
  ///   "statusCode": 400,
  ///   "message": "Bad Request",
  ///   "error": "Invalid input parameters",
  ///   "timestamp": "2024-01-15T10:30:00.000Z"
  /// }
  @POST("id-integration/nid/get-data")
  Future<FaydaVerifyResponse> verifyOtp(@Body() FaydaVerifyRequest request);

  /// Get Residence ID registration data
  /// 
  /// Query parameter:
  /// registrationId: Residence ID (e.g., "AA00004****")
  /// 
  /// Success response:
  /// {
  ///   "success": true,
  ///   "data": [
  ///     {
  ///       "MemberType": "Resisdent",
  ///       "LOCID": "SC10/W06",
  ///       "FirstName": "MERWAN",
  ///       "LastName": "MUKTAR",
  ///       ...
  ///     }
  ///   ],
  ///   "meta": {
  ///     "timestamp": "2026-01-28T17:38:34.106Z",
  ///     "requestId": "50179184-3b21-4404-9ac7-df0594b2c6ef"
  ///   }
  /// }
  /// 
  /// Error response:
  /// {
  ///   "statusCode": 400,
  ///   "message": "Bad Request",
  ///   "error": "Invalid input parameters",
  ///   "timestamp": "2024-01-15T10:30:00.000Z"
  /// }
  @GET("id-integration/crrsa/registration")
  Future<ResidenceRegistrationResponse> getResidenceRegistration(
    @Query("registrationId") String registrationId,
  );

  /// Get TIN taxpayer data
  /// 
  /// Query parameter:
  /// tin: TIN Number (e.g., "0078843311")
  /// 
  /// Success response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "status": "success",
  ///     "taxPayerDetails": {
  ///       "CMP_TIN": "0078843311",
  ///       "FIRST_NAME": "BINIYAM",
  ///       "MIDDLE_NAME": "MUSEMA",
  ///       "LAST_NAME": "HASHIM",
  ///       ...
  ///     }
  ///   },
  ///   "meta": {
  ///     "timestamp": "2026-01-28T17:55:23.307Z",
  ///     "requestId": "461dfb2f-b2f2-429c-b390-d6061b34209b"
  ///   }
  /// }
  /// 
  /// Error response:
  /// {
  ///   "statusCode": 400,
  ///   "message": "Bad Request",
  ///   "error": "Invalid input parameters",
  ///   "timestamp": "2024-01-15T10:30:00.000Z"
  /// }
  @GET("id-integration/mor/taxpayer")
  Future<TinTaxpayerResponse> getTaxpayer(
    @Query("tin") String tin,
  );
}
