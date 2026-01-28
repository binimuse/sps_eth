import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/nearby_police/models/branch_location_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part 'nearby_police_service.g.dart';

/// Service for Nearby Police Stations API integration using Retrofit
@RestApi(baseUrl: Constants.baseUrl)
abstract class NearbyPoliceService {
  factory NearbyPoliceService(Dio dio) = _NearbyPoliceService;

  /// Get nearby police station branches by location
  /// 
  /// Query parameters:
  /// - lat: Latitude of the device location
  /// - lng: Longitude of the device location
  /// 
  /// Response:
  /// {
  ///   "success": true,
  ///   "data": [
  ///     {
  ///       "id": "...",
  ///       "name": "...",
  ///       "lat": 9.028696,
  ///       "lng": 38.720798,
  ///       "distance": 1.560665148452356,
  ///       ...
  ///     }
  ///   ],
  ///   "meta": { ... }
  /// }
  @GET("/branches/public-location")
  Future<BranchLocationResponseWrapper> getNearbyBranches(
    @Query("lat") double latitude,
    @Query("lng") double longitude,
  );
}
