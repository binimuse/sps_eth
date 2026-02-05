
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:sps_eth_app/app/utils/connectivity_util.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          await controller.onWillPop();
        }
      },
      child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // No internet banner (top overlay)
          Obx(() {
            if (ConnectivityUtil().isOnline.value) return const SizedBox.shrink();
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.red.shade700,
                elevation: 4,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No internet connected'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          // Background image
          Image.asset(
            Assets.images.homeBackground.path,
            fit: BoxFit.fill,
          ),
          // Content
          LayoutBuilder(
            builder: (context, constraints) {
              // Main tablet landscape canvas
              return Row(
            children: [
              // LEFT COLUMN: hero then contact+call card
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(child: _HeroPanel(controller: controller)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 210,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _ContactCallCard(controller: controller),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _StartFillingCard(
                                controller: controller,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // RIGHT COLUMN: clock + full-height alerts
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 16,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    children: [
                      _ClockPanel(controller: controller),
                      const SizedBox(height: 16),
                      Expanded(child: _AlertsPanel(controller: controller)),
                      const SizedBox(height: 16),
                      _NearbyPoliceStationsCard(controller: controller),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
        ],
      ),
      ),
    );
  }
}

class _HeroPanel extends StatefulWidget {
  const _HeroPanel({required this.controller});

  final HomeController controller;

  @override
  State<_HeroPanel> createState() => _HeroPanelState();
}

class _HeroPanelState extends State<_HeroPanel> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image carousel slider
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: widget.controller.heroImages.length,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return Image.asset(
                widget.controller.heroImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
          // Dark overlay
          Container(color: Colors.black.withOpacity(0.25)),
          // SPS Logo
          Positioned(
            top: 16,
            left: 16,
            child: SizedBox(
              width: 172,
              child: Image.asset(Assets.images.sps.path, fit: BoxFit.contain),
            ),
          ),
          // Carousel indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.controller.heroImages.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: Container(
                    width: _currentIndex == entry.key ? 24.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == entry.key
                          ? AppColors.secondary
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Center content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => _VideoPlayerDialog(
                          videoUrl: widget.controller.heroVideoUrl,
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.secondary,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SPS'.tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontFamily: GoogleFonts.sintony().fontFamily,
                            color: AppColors.secondary,
                            letterSpacing: 4,
                            fontSize: 29.sp,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockPanel extends StatelessWidget {
  const _ClockPanel({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient:  LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() {
                  return Text(
                    controller.formattedDate,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  );
                }),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: _DigitalClock(controller: controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitalClock extends StatelessWidget {
  const _DigitalClock({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Text(
        controller.formattedTime,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.sintony().fontFamily,
          color: const Color.fromARGB(255, 250, 250, 250),
        ),
      );
    });
  }
}

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'RECENT ALERTS'.tr,
              style: TextStyle(
                fontFamily: GoogleFonts.montserrat().fontFamily,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F3955),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              Assets.images.recent.path,
              height: 120, // Minimized height
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Expanded(
            child: Obx(() {
              final alerts = controller.alerts;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _AlertTile(
                    title: alerts[index],
                    onTap: controller.openRecentAlerts,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _AlertTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F3955),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.'.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Color(0xFF4F6B7E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Removed old bottom actions bar and info card; replaced by _ContactCallCard

class _SwipeToCall extends StatefulWidget {
  final Future<void> Function() onComplete;
  const _SwipeToCall({required this.onComplete});

  @override
  State<_SwipeToCall> createState() => _SwipeToCallState();
}

class _SwipeToCallState extends State<_SwipeToCall> {
  double _dragX = 0;

  @override
  Widget build(BuildContext context) {
    final barHeight = 64.0;
    final knobWidth = 140.0;
    final knobHeight = 56.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth - 64; // based on actual width
        return Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF1FAFF),
            borderRadius: BorderRadius.circular(44),
          ),
          child: Stack(
            children: [
              // Center chevrons
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.chevron_right,
                      size: 36,
                      color: Color(0xFF9DB3C1),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 36,
                      color: Color(0xFF9DB3C1),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 36,
                      color: Color(0xFF9DB3C1),
                    ),
                  ],
                ),
              ),
              // Right target pill
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 160,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFFB9D3E2),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Draggable green knob with label
              Positioned(
                left: 8 + _dragX,
                top: (barHeight - knobHeight) / 2,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    setState(() {
                      _dragX = (_dragX + d.delta.dx).clamp(
                        0.0,
                        trackWidth - knobWidth,
                      );
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    final isComplete = _dragX > (trackWidth - knobWidth) * 0.85;
                    if (isComplete) {
                      widget.onComplete().whenComplete(() {
                        if (mounted) {
                          setState(() => _dragX = 0);
                        }
                      });
                    } else {
                      setState(() => _dragX = 0);
                    }
                  },
                  child: Container(
                    width: knobWidth,
                    height: knobHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ED158),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Colors.white, size: 28),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Swipe to Call'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerDialog({required this.videoUrl});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  YoutubePlayerController? _controller;
  bool _initialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Extract video ID from YouTube URL
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
        ),
      );
      setState(() {
        _initialized = true;
      });
    } else {
      setState(() {
        _errorMessage = 'Invalid YouTube URL';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'.tr, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized || _controller == null) {
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final controller = _controller!;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.secondary,
              progressColors: ProgressBarColors(
                playedColor: AppColors.secondary,
                handleColor: AppColors.secondaryDark,
              ),
            ),
            // Close button (top-right)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: 'Close'.tr,
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCallCard extends StatelessWidget {
  const _ContactCallCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:  LinearGradient(
          colors: [
            AppColors.primaryLight,
            AppColors.primaryLighter,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Left: help/contact
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            Assets.images.contact.path,
                            height: 120, // Minimized height
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Direct Call for Service'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.whiteOff,
                                  fontSize: 15.sp,
                                ),
                              ),
                              Text(
                                'These are the terms and conditions for in charge of planning'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.whiteOff,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right: voice call small card
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Embedded swipe-to-call control
          SizedBox(
            height: 64,
            child: _SwipeToCall(onComplete: controller.onSwipeToCallComplete),
          ),
        ],
      ),
    );
  }
}

class _StartFillingCard extends StatelessWidget {
  const _StartFillingCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.openLanguageSelection,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image.asset(
                    Assets.images.insertcard.path,
                    height: 120, // Minimized height
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start Filling and Insert ID'.tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'These are the terms and conditions for in charge of planning'.tr,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 12, color: Color(0xFF4F6B7E)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyPoliceStationsCard extends StatelessWidget {
  const _NearbyPoliceStationsCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.openNearbyPoliceStations,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            Assets.images.near.path,
            width: double.infinity,
      
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
