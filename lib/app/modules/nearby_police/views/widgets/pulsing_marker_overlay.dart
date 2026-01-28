// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// /// GIF marker overlay for map markers
// /// Displays animated GIF at marker positions
// class GifMarkerOverlay extends StatefulWidget {
//   final GoogleMapController? mapController;
//   final List<LatLng> markerPositions;
//   final double markerSize;

//   const GifMarkerOverlay({
//     super.key,
//     required this.mapController,
//     required this.markerPositions,
//     this.markerSize = 60.0, // Default GIF size
//   });

//   @override
//   State<GifMarkerOverlay> createState() => _GifMarkerOverlayState();
// }

// class _GifMarkerOverlayState extends State<GifMarkerOverlay> {
//   Timer? _updateTimer;
//   final Map<LatLng, Offset> _positionCache = {};

//   @override
//   void initState() {
//     super.initState();
    
//     // Update positions periodically to keep GIFs aligned with map movements
//     _updateTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
//       if (mounted && widget.mapController != null) {
//         _updatePositions();
//       }
//     });
    
//     // Initial position update with delay to ensure map is ready
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (mounted) {
//           _updatePositions();
//         }
//       });
//     });
//   }

//   @override
//   void didUpdateWidget(GifMarkerOverlay oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Update positions when marker positions change
//     if (oldWidget.markerPositions.length != widget.markerPositions.length ||
//         oldWidget.mapController != widget.mapController) {
//       _updatePositions();
//     }
//   }

//   @override
//   void dispose() {
//     _updateTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _updatePositions() async {
//     if (widget.mapController == null || widget.markerPositions.isEmpty) return;
    
//     final Map<LatLng, Offset> newPositions = {};
//     for (var position in widget.markerPositions) {
//       try {
//         final screenCoord = await widget.mapController!
//             .getScreenCoordinate(position);
//         final offset = Offset(
//           screenCoord.x.toDouble(),
//           screenCoord.y.toDouble(),
//         );
//         newPositions[position] = offset;
//         print('📍 [GIF OVERLAY] Position ${position.latitude}, ${position.longitude} -> Screen ${offset.dx}, ${offset.dy}');
//       } catch (e) {
//         print('⚠️ [GIF OVERLAY] Error getting screen coordinate: $e');
//         // Ignore errors - position might not be visible or map not ready
//       }
//     }
    
//     if (mounted) {
//       setState(() {
//         _positionCache.clear();
//         _positionCache.addAll(newPositions);
//       });
//       print('✅ [GIF OVERLAY] Updated ${newPositions.length} positions');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.markerPositions.isEmpty || widget.mapController == null) {
//       return const SizedBox.shrink();
//     }

//     // Show overlay even if cache is empty (will update soon)
//     return IgnorePointer(
//       // Allow touches to pass through to the map
//       ignoring: true,
//       child: Builder(
//         builder: (context) {
//           if (_positionCache.isEmpty) {
//             // Return empty but trigger position update
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _updatePositions();
//             });
//             return const SizedBox.shrink();
//           }
          
//           return Stack(
//             clipBehavior: Clip.none,
//             children: _positionCache.entries.map((entry) {
//               return _buildGifMarker(entry.value);
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildGifMarker(Offset position) {
//     // Center the GIF on the marker position
//     // The position from getScreenCoordinate is relative to the map widget
//     final halfSize = widget.markerSize / 2;
//     return Positioned(
//       left: position.dx - halfSize,
//       top: position.dy - halfSize,
//       child: SizedBox(
//         width: widget.markerSize,
//         height: widget.markerSize,
//         child: Image.asset(
//           'assets/images/google.gif',
//           fit: BoxFit.contain,
//           errorBuilder: (context, error, stackTrace) {
//             print('⚠️ [GIF OVERLAY] Error loading GIF: $error');
//             // Fallback to a simple colored circle if GIF fails to load
//             return Container(
//               width: widget.markerSize,
//               height: widget.markerSize,
//               decoration: const BoxDecoration(
//                 color: Colors.blue,
//                 shape: BoxShape.circle,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
