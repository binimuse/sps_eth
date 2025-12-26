
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:video_player/video_player.dart';

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
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              Assets.images.homeBackground.path,
              fit: BoxFit.fitWidth,
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
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Assets.images.news.path, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.25)),
          Positioned(
            top: 16,
            left: 16,
            child: SizedBox(
              width: 172,
              child: Image.asset(Assets.images.sps.path, fit: BoxFit.contain),
            ),
          ),

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
                          videoUrl: controller.heroVideoUrl,
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
                  Text(
                    'SPS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFamily: GoogleFonts.sintony().fontFamily,
                      color: AppColors.secondary,
                      letterSpacing: 4,
                      fontSize: 29.sp,
                    ),
                  ),
                  Text(
                    'Loreim re in charge of planning and managing marketing\n'
                    'campaigns that promote a company\'s brand. marketing\n'
                    'campaigns that promote a company\'s brand.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
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
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 157, 205, 239), Color(0xFF5078A0)],
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
              'RECENT ALERTS',
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
                const Text(
                  'managing marketing campaigns that Loreim re in charge of',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Swipe to Call',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.black,
      child: AspectRatio(
        aspectRatio: _initialized ? _controller.value.aspectRatio : 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_initialized)
              VideoPlayer(_controller)
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            // Close button (top-right)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: IconButton(
                color: Colors.white,
                iconSize: 28,
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
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
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 126, 196, 246),
            Color.fromARGB(255, 232, 235, 238),
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
                                'Direct Call for Service',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontSize: 13.sp,
                                ),
                              ),
                              Text(
                                'These are the terms and conditions for in charge of planning ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4F6B7E),
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
            color: const Color(0xFFEAF3FF),
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
                'Start Filling and Insert ID',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'These are the terms and conditions for in charge of planning',
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
            height: 200, // Adjust height as needed
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
