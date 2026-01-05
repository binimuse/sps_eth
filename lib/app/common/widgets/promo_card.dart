import 'package:flutter/material.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

class PromoCard extends StatelessWidget {
  const PromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 780,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F4A70), Color(0xFF0B3654)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Image.asset(Assets.images.sps.path),
                 
                    const Expanded(
                      child: Center(
                        child: Text(
                          'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.',
                          style: TextStyle(color: Colors.white70, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // carousel dots
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Ensures the dots are centered horizontally
                        children: List.generate(6, (i) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: i == 2 ? 12 : 8,
                            height: i == 2 ? 12 : 8,
                            decoration: BoxDecoration(
                              color: i == 2 ? const Color(0xFFF5D77E) : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // bottom image
            Container(
              height: 460,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                image: DecorationImage(
                  image: AssetImage(Assets.images.recent1.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
