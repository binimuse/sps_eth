/// List item from GET /blog-post/public
class BlogPostListItem {
  const BlogPostListItem({
    required this.id,
    required this.title,
    required this.excerpt,
    this.featuredImageUrl,
    this.publishedAt,
  });

  factory BlogPostListItem.fromJson(Map<String, dynamic> json) {
    return BlogPostListItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      featuredImageUrl: json['featuredImageUrl'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }

  final String id;
  final String title;
  final String excerpt;
  final String? featuredImageUrl;
  final DateTime? publishedAt;
}

/// Single post from GET /blog-post/:id
class BlogPostDetail {
  const BlogPostDetail({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    this.featuredImageUrl,
    this.publishedAt,
  });

  factory BlogPostDetail.fromJson(Map<String, dynamic> json) {
    return BlogPostDetail(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      featuredImageUrl: json['featuredImageUrl'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }

  final String id;
  final String title;
  final String content;
  final String? excerpt;
  final String? featuredImageUrl;
  final DateTime? publishedAt;
}

/// Wrapper for list API: { success, data: [...], meta }
class BlogPostListResponse {
  const BlogPostListResponse({
    this.success = false,
    this.data = const [],
    this.meta,
  });

  factory BlogPostListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    return BlogPostListResponse(
      success: json['success'] as bool? ?? false,
      data: list is List
          ? (list)
              .map((e) => BlogPostListItem.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : <BlogPostListItem>[],
      meta: json['meta'] != null
          ? BlogPostMeta.fromJson(
              Map<String, dynamic>.from(json['meta'] as Map))
          : null,
    );
  }

  final bool success;
  final List<BlogPostListItem> data;
  final BlogPostMeta? meta;
}

class BlogPostMeta {
  const BlogPostMeta({this.timestamp, this.requestId});

  factory BlogPostMeta.fromJson(Map<String, dynamic> json) {
    return BlogPostMeta(
      timestamp: json['timestamp'] as String?,
      requestId: json['requestId'] as String?,
    );
  }

  final String? timestamp;
  final String? requestId;
}

/// Wrapper for detail API: { success, data: { ... } }
class BlogPostDetailResponse {
  const BlogPostDetailResponse({
    this.success = false,
    this.data,
  });

  factory BlogPostDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return BlogPostDetailResponse(
      success: json['success'] as bool? ?? false,
      data: data is Map
          ? BlogPostDetail.fromJson(Map<String, dynamic>.from(data))
          : null,
    );
  }

  final bool success;
  final BlogPostDetail? data;
}
