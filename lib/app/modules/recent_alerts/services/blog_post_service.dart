import 'package:dio/dio.dart';

import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';

import '../models/blog_post_model.dart';

/// Fetches public blog posts (no auth). Uses Dio without access token.
class BlogPostService {
  static String get _baseUrl => Constants.baseUrl;

  Dio get _dio {
    final dio = DioUtil().getDio(useAccessToken: false);
    dio.options.baseUrl = _baseUrl;
    return dio;
  }

  /// GET /blog-post/public?page=1&limit=10
  Future<BlogPostListResponse> getPublicPosts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Constants.blogPostPublic,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    if (data == null) {
      return const BlogPostListResponse(success: false, data: []);
    }
    return BlogPostListResponse.fromJson(data);
  }

  /// GET /blog-post/:id
  Future<BlogPostDetailResponse> getPostById(String id) async {
    final path = Constants.blogPostById.replaceFirst('{id}', id);
    final response = await _dio.get<Map<String, dynamic>>(path);
    final data = response.data;
    if (data == null) {
      return const BlogPostDetailResponse(success: false);
    }
    return BlogPostDetailResponse.fromJson(data);
  }
}
