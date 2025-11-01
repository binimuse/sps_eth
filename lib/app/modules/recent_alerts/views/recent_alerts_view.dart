import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PROMO CARD
              SizedBox(
                width: 340,
                child: PromoCard(
                
                ),
              ),

              const SizedBox(width: 24),

              // CENTER ARTICLE
              Expanded(
                flex: 2,
                child: _ArticlePanel(),
              ),

              const SizedBox(width: 24),

              // RIGHT SIDEBAR
              SizedBox(
                width: 320,
                child: _RightSidebar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ArticlePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top hero image
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Image.asset(
                Assets.images.recent2.path,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('116th ETHIOPIAN POLICE DAY',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Written by Alemayehu Eshete', style: TextStyle(color: Color(0xFF2E6A92))),
                      const SizedBox(width: 16),
                      Text(DateFormat('EEEE, MMM d').format(now), style: const TextStyle(color: Colors.grey)),
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
                  children: const [
                    Text(
                      'Section 1.10.32 of "de Finibus Bonorum et Malorum", written by Cicero in 45 BC\n"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"',
                      style: TextStyle(height: 1.6, color: Color(0xFF4F6B7E)),
                    ),
                    SizedBox(height: 14),
                    Text(
                      '1914 translation by H. Rackham\n"But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?"',
                      style: TextStyle(height: 1.6, color: Color(0xFF4F6B7E)),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Section 1.10.33 of "de Finibus Bonorum et Malorum"\n"At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."',
                      style: TextStyle(height: 1.6, color: Color(0xFF4F6B7E)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightSidebar extends StatelessWidget {
  const _RightSidebar();

  @override
  Widget build(BuildContext context) {
    final alerts = List.generate(5, (i) => 'Alert headline ${i + 1}');
    return Column(
      children: [
        // Clock box
        

        // Recent Alerts card
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  child: Image.asset(Assets.images.news.path, height: 120, width: double.infinity, fit: BoxFit.cover),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Text('RECENT ALERTS', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F3955))),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _AlertTile(title: alerts[index]),
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
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  const _AlertTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(Assets.images.news.path, width: 72, height: 56, fit: BoxFit.cover)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F3955))),
              const SizedBox(height: 4),
              const Text('managing marketing campaigns that Loreim re in charge of', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Color(0xFF4F6B7E))),
            ],
          ),
        ),
      ],
    );
  }
}

