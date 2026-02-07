import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';

import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/recent_alerts_controller.dart';
import '../models/blog_post_model.dart';

class RecentAlertsView extends GetView<RecentAlertsController> {
  const RecentAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (same as residency_type, language, etc.)
          Image.asset(
            Assets.images.logoBackground.path,
            fit: BoxFit.fitWidth,
          ),
          SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button (same as residence_service_detail_view - use Navigator to avoid GetX snackbar crash)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    side: const BorderSide(color: Color(0xFFCBDCE7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F3955)),
                  label: Text('Back'.tr, style: TextStyle(color: Color(0xFF0F3955))),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT PROMO CARD
                      const SizedBox(width: 340, child: PromoCard()),

                      const SizedBox(width: 24),

                      // CENTER ARTICLE
                      Expanded(flex: 2, child: _ArticlePanel(controller: controller)),

                      const SizedBox(width: 24),

                      // RIGHT SIDEBAR
                      SizedBox(
                        width: 320,
                        child: _RightSidebar(controller: controller),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
          ),
        ],
      ),
    );
  }
}

class _ArticlePanel extends StatelessWidget {
  const _ArticlePanel({required this.controller});

  final RecentAlertsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final article = controller.article.value;
      final isLoadingArticle = controller.isLoadingArticle.value;
      if (article == null) {
        return const SizedBox.shrink();
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: article.featuredImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: article.featuredImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Image.asset(
                                Assets.images.recent2.path,
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (_, __, ___) => Image.asset(
                                Assets.images.recent2.path,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              Assets.images.recent2.path,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        if (controller.formattedArticleDate.isNotEmpty)
                          Text(
                            controller.formattedArticleDate,
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Html(
                        
                        data: article.content,
                        shrinkWrap: true,
                        style: {
                          'body': Style(
                            fontSize: FontSize(15),
                            lineHeight: const LineHeight(1.6),
                            color: const Color(0xFF4F6B7E),
                            backgroundColor: Colors.transparent,
                          ),
                          'p': Style(
                            color: const Color(0xFF4F6B7E),
                            backgroundColor: Colors.transparent,
                          ),
                          'span': Style(
                            color: const Color(0xFF4F6B7E),
                            backgroundColor: Colors.transparent,
                          ),
                          '*': Style(
                            backgroundColor: Colors.transparent,
                          ),
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoadingArticle)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _RightSidebar extends StatelessWidget {
  const _RightSidebar({required this.controller});

  final RecentAlertsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final alerts = controller.alerts;
      return Column(
        children: [
          // Clock box

          // Recent Alerts card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      Assets.images.news.path,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                   Padding(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Text(
                      'RECENT ALERTS'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F3955),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: alerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _AlertTile(
                        controller: controller,
                        alert: alerts[index],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nearby Police Stations card
        ],
      );
    });
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.controller,
    required this.alert,
  });

  final RecentAlertsController controller;
  final BlogPostListItem alert;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectPost(alert.id),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: alert.featuredImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: alert.featuredImageUrl!,
                    width: 72,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Image.asset(
                      Assets.images.news.path,
                      width: 72,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (_, __, ___) => Image.asset(
                      Assets.images.news.path,
                      width: 72,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    Assets.images.news.path,
                    width: 72,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F3955),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4F6B7E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
