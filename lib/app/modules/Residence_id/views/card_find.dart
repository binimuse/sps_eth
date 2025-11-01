// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:sps_eth_app/gen/assets.gen.dart';

// import '../controllers/residence_id_controller.dart';
// import 'package:sps_eth_app/app/common/widgets/promo_card.dart';

// class CardFind extends GetView<ResidenceIdController> {
//   const CardFind({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white.withOpacity(0.9),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // LEFT PROMO CARD
//               SizedBox(
//                 width: 340,
//                 child: PromoCard(
//                 ),
//               ),
    
//               const SizedBox(width: 24),
    
//               // CENTER CONTENT
//               Expanded(
//                 flex: 2,
//                 child: Container(
//                   height: 50.h, // Reduced width to minimize card size
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset(
//                         Assets.images.card.path,
//                         fit: BoxFit.cover,
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Scanning For ID ....',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black54,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Insert ID Number Here',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueAccent,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () {},
//                         child: const Text('Find'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
    
            
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Column(
//   children: [
//     // ...existing code...
//     const SizedBox(height: 24),
//     Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'ID Information',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: const [
//               Text('1231235163',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black54,
//                   )),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Name Information',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Abeba Shimeles Adera',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Birth Date',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Aug 12, 2024',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Email',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'abeba@gmail.com',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Phone Number',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             '0913427553',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Residence Address',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             '-',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               OutlinedButton(
//                 onPressed: () {},
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 24, vertical: 12),
//                   side: const BorderSide(color: Colors.grey),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                       color: Colors.black,
//                     )),
//               ),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 24, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Confirm'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   ],
// ),
