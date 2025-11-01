import 'package:dio/dio.dart' as dio;

import 'package:sps_eth_app/app/utils/auth_util.dart';



class DioUtil {
  static final DioUtil _instance = DioUtil._internal();
  factory DioUtil() => _instance;
  DioUtil._internal() {
    _initializeTokenCache();
  }

  static const int _timeoutInSeconds = 30;
  static const String _contentTypeJson = 'application/json';

  // Add a flag to prevent multiple simultaneous token refresh attempts

  // Clear token cache on initialization to ensure clean state
  void _initializeTokenCache() {
  }

  dio.Dio getDio({bool? useAccessToken, bool? forFileUpload}) {
    dio.BaseOptions options = dio.BaseOptions(
      connectTimeout: forFileUpload == true
          ? const Duration(seconds: _timeoutInSeconds)
          : null,
      receiveTimeout: forFileUpload == true
          ? const Duration(seconds: _timeoutInSeconds)
          : null,
      headers: {'Content-Type': _contentTypeJson},
    );
    dio.Dio dioInstance = dio.Dio(options);

    dioInstance.interceptors.add(
      dio.LogInterceptor(
        responseBody: true,
        request: true,
        requestHeader: true,
      ),
    );

    // Always add the error interceptor to handle 401 errors
    dioInstance.interceptors.add(_errorInterceptor());

    if (useAccessToken == true) {
      dioInstance.interceptors.add(_accessTokenInterceptor());
    }

    return dioInstance;
  }

  dio.InterceptorsWrapper _errorInterceptor() {
    return dio.InterceptorsWrapper(
      onError: (dio.DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await _handleLogout();
          return handler.next(e);
        }
        return handler.next(e);
      },
    );
  }

  dio.InterceptorsWrapper _accessTokenInterceptor() {
    return dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Validate tokens before making request
        bool isAuthenticated = await AuthUtil().isFullyAuthenticated();
        if (!isAuthenticated) {
          await _handleLogout();
          return handler.reject(
            dio.DioException(
              requestOptions: options,
              error: 'Authentication tokens are invalid',
            ),
          );
        }

        String? accessToken = await AuthUtil().getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
          print(
            'Added Authorization header with token: ${accessToken.substring(0, 20)}...',
          );
        } else {
          print('No access token available, logging out user');
          await _handleLogout();
          return handler.reject(
            dio.DioException(
              requestOptions: options,
              error: 'No access token available',
            ),
          );
        }

        return handler.next(options);
      },
      onError: (dio.DioException e, handler) async {
        // This part is now handled by _errorInterceptor for 401
        return handler.next(e);
      },
    );
  }


  // Future<String?> _refreshTokenSafely() async {
  //   // If already refreshing, wait for the result
  //   if (_isRefreshing) {
  //     print('Token refresh already in progress, waiting...');
  //     while (_isRefreshing) {
  //       await Future.delayed(const Duration(milliseconds: 100));
  //     }
  //     print('Token refresh completed, returning cached token');
  //     return _cachedToken;
  //   }

  //   _isRefreshing = true;
  //   print('Starting token refresh...');

  //   try {
  //     String? refreshToken = await AuthUtil().getRefreshToken();
  //     print(
  //       'Retrieved refresh token: ${refreshToken != null ? "exists" : "null"}',
  //     );

  //     if (refreshToken == null || refreshToken.isEmpty) {
  //       print('Refresh token is null or empty, logging out user');
  //       await _handleLogout();
  //       return null;
  //     }

  //     print('Refresh token found, making refresh request...');

  //     // Create a Dio instance without interceptors for the refresh token call
  //     dio.Dio refreshDio = dio.Dio();
  //     refreshDio.options.baseUrl = 'http://5.75.142.45:4000';
  //     refreshDio.options.headers['Content-Type'] = 'application/json';
  //     refreshDio.options.connectTimeout = const Duration(seconds: 10);
  //     refreshDio.options.receiveTimeout = const Duration(seconds: 10);

  //     TokenRefreshResponse tokenRefreshResponse = await LoginSignupService(
  //       refreshDio,
  //     ).refreshToken(refreshToken: "Bearer $refreshToken");

  //     if (tokenRefreshResponse.refreshToken == null ||
  //         tokenRefreshResponse.accessToken.isEmpty ||
  //         tokenRefreshResponse.refreshToken.isEmpty) {
  //       print(
  //         'Invalid token response received - accessToken: ${tokenRefreshResponse.accessToken != null}, refreshToken: ${tokenRefreshResponse.refreshToken != null}',
  //       );
  //       await _handleLogout();
  //       return null;
  //     }

  //     // Save the new tokens and user information
  //     await AuthUtil().saveTokenAndUserInfo(
  //       accessToken: tokenRefreshResponse.accessToken,
  //       refreshToken: tokenRefreshResponse.refreshToken,
  //       user: tokenRefreshResponse.user.toJson(),
  //     );

  //     _cachedToken = tokenRefreshResponse.accessToken;
  //     print('Token refresh successful');
  //     return tokenRefreshResponse.accessToken;
  //   } catch (e) {
  //     print('Token refresh failed: $e');
  //     // Debug token status before logout
  //     await AuthUtil().debugTokenStatus();
  //     await _handleLogout();
  //     return null;
  //   } finally {
  //     _isRefreshing = false;
  //     print('Token refresh process completed');
  //   }
  // }

  Future<void> _handleLogout() async {
    // Clear the cached token and refresh state

    await AuthUtil().logOut();
   // Get.offAllNamed(Routes.LOGIN);
  }

  // Method to manually clear the token cache (useful for testing or manual logout)
  void clearTokenCache() {
  }

  Future<List?> handleDioError(dio.DioException error) async {
    final response = error.response;
    if (response != null) {
      try {
        final message = response.data['message'];
        final code = response.statusCode;
        return [code, message];
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Future<void> getUserInfo() async {
  //   try {
  //     UserMeResponse userMeResponse =
  //         await LoginSignupService(getDio(useAccessToken: true)).me();

  //     String? accessToken = await AuthUtil().getAccessToken();
  //     String? refreshToken = await AuthUtil().getRefreshToken();

  //     if (accessToken == null || refreshToken == null) {
  //       throw Exception("Access token or refresh token is null");
  //     }

  //     await AuthUtil().saveTokenAndUserInfo(
  //       accessToken: accessToken,
  //       refreshToken: refreshToken,
  //       user: userMeResponse.toJson(),
  //     );
  //   } catch (e) {
  //     ValidatorUtil.handleError(e);
  //   }
  // }
}
