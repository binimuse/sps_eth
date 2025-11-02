import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/residence_id_controller.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';

class ResidenceIdView extends GetView<ResidenceIdController> {
  const ResidenceIdView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container( 
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.back1.path),
          fit: BoxFit.contain,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LEFT PROMO CARD
                SizedBox(
                  width: 300,
                  child: PromoCard(
                  ),
                ),

                const SizedBox(width: 24),

                // CENTER CONTENT
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    final isFinding = controller.isFinding.value;
                    return Container(
                      height: isFinding ? 70.h : 50.h, // Adjust height dynamically
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            Assets.images.card.path,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Scanning For ID ....',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Insert ID Number Here',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              controller.isFinding.value = true;
                            },
                            child: const Text('Find'),
                          ),
                          if (isFinding) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'ID Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Name Information: Abeba Shimeles Adera'),
                                  Text('Birth Date: Aug 12, 2024'),
                                  Text('Email: abeba@gmail.com'),
                                  Text('Phone Number: 0913427553'),
                                  Text('Residence Address: -'),
                                  SizedBox(height: 16),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     ElevatedButton(
                                  //       style: ElevatedButton.styleFrom(
                                  //         backgroundColor: Colors.grey,
                                  //         foregroundColor: Colors.white,
                                  //         padding: const EdgeInsets.symmetric(
                                  //             horizontal: 24, vertical: 12),
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(12),
                                  //         ),
                                  //       ),
                                  //       onPressed: () {
                                  //         controller.isFinding.value = false;
                                  //       },
                                  //       child: const Text('Cancel'),
                                  //     ),
                                  //     ElevatedButton(
                                  //       style: ElevatedButton.styleFrom(
                                  //         backgroundColor: Colors.blueAccent,
                                  //         foregroundColor: Colors.white,
                                  //         padding: const EdgeInsets.symmetric(
                                  //             horizontal: 24, vertical: 12),
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(12),
                                  //         ),
                                  //       ),
                                  //       onPressed: () {
                                  //         // Confirm action
                                  //       },
                                  //       child: const Text('Confirm'),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 24),

                // RIGHT SIDEBAR
                if(!controller.isFinding.value) Image.asset(
                  Assets.images.machine.path,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
