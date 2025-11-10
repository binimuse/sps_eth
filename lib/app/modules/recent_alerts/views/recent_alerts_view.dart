import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';

import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/recent_alerts_controller.dart';

class RecentAlertsView extends GetView<RecentAlertsController> {
  const RecentAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
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
          );
        }),
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
      if (article == null) {
        return const SizedBox.shrink();
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top hero image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Image.asset(
                      Assets.images.recent2.path,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          tooltip: 'Back',
                          onPressed: Get.back,
                        ),
                      ),
                    ),
                  ],
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
                    Row(
                      children: [
                        Text(
                          article.author,
                          style: const TextStyle(color: Color(0xFF2E6A92)),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          controller.formattedArticleDate,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // article body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < article.sections.length; i++) ...[
                        Text(
                          article.sections[i],
                          style: const TextStyle(
                            height: 1.6,
                            color: Color(0xFF4F6B7E),
                          ),
                        ),
                        if (i != article.sections.length - 1)
                          const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Text(
                      'RECENT ALERTS',
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
                      itemBuilder: (context, index) =>
                          _AlertTile(alert: alerts[index]),
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
  const _AlertTile({required this.alert});

  final RecentAlertItem alert;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            alert.imagePath,
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
                alert.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4F6B7E)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
