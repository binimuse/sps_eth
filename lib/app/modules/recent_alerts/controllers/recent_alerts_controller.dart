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
        'Section 1.10.32 of "de Finibus Bonorum et Malorum", written by Cicero in 45 BC\n'
            '"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium '
            'doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore '
            'veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim '
            'ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia '
            'consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. '
            'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, '
            'adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et '
            'dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum '
            'exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea '
            'commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate '
            'velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat '
            'quo voluptas nulla pariatur?"',
        '1914 translation by H. Rackham\n'
            '"But I must explain to you how all this mistaken idea of denouncing pleasure '
            'and praising pain was born and I will give you a complete account of the system, '
            'and expound the actual teachings of the great explorer of the truth, the '
            'master-builder of human happiness. No one rejects, dislikes, or avoids pleasure '
            'itself, because it is pleasure, but because those who do not know how to pursue '
            'pleasure rationally encounter consequences that are extremely painful. Nor again '
            'is there anyone who loves or pursues or desires to obtain pain of itself, because '
            'it is pain, but because occasionally circumstances occur in which toil and pain '
            'can procure him some great pleasure. To take a trivial example, which of us ever '
            'undertakes laborious physical exercise, except to obtain some advantage from it? '
            'But who has any right to find fault with a man who chooses to enjoy a pleasure that '
            'has no annoying consequences, or one who avoids a pain that produces no resultant '
            'pleasure?"',
        'Section 1.10.33 of "de Finibus Bonorum et Malorum"\n'
            '"At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis '
            'praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias '
            'excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui '
            'officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem '
            'rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est '
            'eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, '
            'omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et '
            'aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae '
            'sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, '
            'ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus '
            'asperiores repellat."',
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
