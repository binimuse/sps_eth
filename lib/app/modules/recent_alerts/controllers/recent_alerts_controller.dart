import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/blog_post_model.dart';
import '../services/blog_post_service.dart';

class RecentAlertsController extends GetxController {
  final RxBool isLoading = true.obs;
  /// True while fetching a single article (e.g. when user taps sidebar).
  final RxBool isLoadingArticle = false.obs;
  final Rx<BlogPostDetail?> article = Rx<BlogPostDetail?>(null);
  final RxList<BlogPostListItem> alerts = <BlogPostListItem>[].obs;

  final BlogPostService _blogPostService = BlogPostService();

  String get formattedArticleDate {
    final value = article.value;
    if (value?.publishedAt == null) return '';
    return DateFormat('EEEE, MMM d').format(value!.publishedAt!);
  }

  @override
  void onInit() {
    super.onInit();
    final blogPostId = Get.arguments as String?;
    loadContent(selectedId: blogPostId);
  }

  Future<void> loadContent({String? selectedId}) async {
    isLoading.value = true;
    try {
      final listResponse = await _blogPostService.getPublicPosts(page: 1, limit: 10);
      if (listResponse.success && listResponse.data.isNotEmpty) {
        alerts.assignAll(listResponse.data);

        if (selectedId != null && selectedId.isNotEmpty) {
          final detailResponse = await _blogPostService.getPostById(selectedId);
          if (detailResponse.success && detailResponse.data != null) {
            article.value = detailResponse.data;
            return;
          }
        }
        // No selected id or detail failed: show first from list
        final firstId = listResponse.data.first.id;
        final detailResponse = await _blogPostService.getPostById(firstId);
        if (detailResponse.success && detailResponse.data != null) {
          article.value = detailResponse.data;
        }
      }
    } catch (_) {
      // Keep article and alerts as-is (empty)
    } finally {
      isLoading.value = false;
    }
  }

  /// When user taps a post in the sidebar, load that post as the main article.
  Future<void> selectPost(String id) async {
    isLoadingArticle.value = true;
    try {
      final response = await _blogPostService.getPostById(id);
      if (response.success && response.data != null) {
        article.value = response.data;
      }
    } catch (_) {}
    finally {
      isLoadingArticle.value = false;
    }
  }
}
