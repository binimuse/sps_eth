import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

class RecentAlertsController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<RecentArticle?> article = Rx<RecentArticle?>(null);
  final RxList<RecentAlertItem> alerts = <RecentAlertItem>[].obs;

  String get formattedArticleDate {
    final value = article.value;
    if (value == null) return '';
    return DateFormat('EEEE, MMM d').format(value.publishedAt);
  }

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  Future<void> loadContent() async {
    isLoading.value = true;
    try {
      final articleSections = [
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.',
        'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur.',
      ];

      article.value = RecentArticle(
        title: '116th ETHIOPIAN POLICE DAY',
        author: 'Written by Alemayehu Eshete',
        publishedAt: DateTime.now(),
        sections: articleSections,
      );

      final alertItems = List.generate(
        5,
        (index) => RecentAlertItem(
          title: 'Alert headline ${index + 1}',
          summary: 'managing marketing campaigns that Loreim re in charge of',
          imagePath: Assets.images.news.path,
        ),
      );
      alerts.assignAll(alertItems);
    } finally {
      isLoading.value = false;
    }
  }
}

class RecentArticle {
  const RecentArticle({
    required this.title,
    required this.author,
    required this.publishedAt,
    required this.sections,
  });

  final String title;
  final String author;
  final DateTime publishedAt;
  final List<String> sections;
}

class RecentAlertItem {
  const RecentAlertItem({
    required this.title,
    required this.summary,
    required this.imagePath,
  });

  final String title;
  final String summary;
  final String imagePath;
}
