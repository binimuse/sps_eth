import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:sps_eth_app/app/modules/call_class/models/report_draft_model.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

part 'report_service.g.dart';

/// Service for Report API integration using Retrofit
/// Follows the project's standard API integration pattern
@RestApi(baseUrl: Constants.baseUrl)
abstract class ReportService {
  factory ReportService(Dio dio) = _ReportService;
  

  /// Get draft report for a call session
  /// 
  /// Request:
  /// - Method: GET
  /// - Headers: Authorization: Bearer <token>
  /// - URL Parameter: callSessionId (from call request response)
  /// 
  /// Response:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "callSessionId": "call-session-uuid",
  ///     "formData": {
  ///       "fullName": "John Doe",
  ///       "age": 35,
  ///       "phoneMobile": "+251911234567",
  ///       "statement": "Incident description..."
  ///     },
  ///     "lastUpdated": "2024-01-15T14:30:00Z",
  ///     "hasUpdates": true,
  ///     "reportSubmitted": false
  ///   },
  ///   "meta": {
  ///     "timestamp": "2024-01-15T14:30:00Z",
  ///     "requestId": "request-uuid"
  ///   }
  /// }
  /// 
  /// Response when report is submitted:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "callSessionId": "call-session-uuid",
  ///     "reportSubmitted": true,
  ///     "reportId": "report-uuid",
  ///     "caseNumber": "CASE-2024-001"
  ///   }
  /// }
  @GET(Constants.reportDraft)
  Future<ReportDraftResponseWrapper> getDraft(@Path('callSessionId') String callSessionId);
}

