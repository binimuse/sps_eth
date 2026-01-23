import 'package:flutter/material.dart';

/// A pulsing logo loader widget with animated waves
/// Used for call loading states
class PulsingLogoLoader extends StatefulWidget {
  /// Path to the logo image asset
  final String logoPath;
  
  /// Size of the logo (diameter)
  final double logoSize;
  
  /// Color of the pulsing waves
  final Color waveColor;
  
  /// Background color of the logo container
  final Color logoBackgroundColor;
  
  /// Border color of the logo container
  final Color logoBorderColor;
  
  /// Number of wave rings to display
  final int waveCount;
  
  /// Base radius of the waves (will expand from this)
  final double baseRadius;

  const PulsingLogoLoader({
    super.key,
    required this.logoPath,
    this.logoSize = 160.0,
    this.waveColor = Colors.white,
    this.logoBackgroundColor = Colors.white,
    this.logoBorderColor = Colors.white,
    this.waveCount = 3,
    this.baseRadius = 100.0,
  });

  @override
  State<PulsingLogoLoader> createState() => _PulsingLogoLoaderState();
}

class _PulsingLogoLoaderState extends State<PulsingLogoLoader>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _logoPulseController;

  @override
  void initState() {
    super.initState();
    
    // Wave animation: continuous loop
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    // Logo pulse animation: continuous loop
    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.baseRadius * 2 + (widget.waveCount * 60),
        height: widget.baseRadius * 2 + (widget.waveCount * 60),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Wave rings
            ...List.generate(widget.waveCount, (index) {
              return AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return _buildWave(index);
                },
              );
            }),
            // Logo in center
            AnimatedBuilder(
              animation: _logoPulseController,
              builder: (context, child) {
                return _buildLogo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWave(int index) {
    // Calculate delay for each wave (staggered effect)
    final delay = index / widget.waveCount;
    final animationValue = (_waveController.value + delay) % 1.0;
    
    // Wave expands from baseRadius to baseRadius + expansion
    final expansion = 60.0;
    final currentRadius = widget.baseRadius + (animationValue * expansion);
    
    // Opacity fades out as wave expands
    final baseOpacity = 0.6;
    final opacity = baseOpacity * (1.0 - animationValue);
    
    // Scale animation
    final scale = currentRadius / widget.baseRadius;

    return Positioned(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: widget.baseRadius * 2,
          height: widget.baseRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.waveColor.withOpacity(0.25 * opacity / baseOpacity),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Logo scale animation: 1 -> 1.08 -> 1
    final logoAnimationValue = _logoPulseController.value;
    final logoScaleProgress = logoAnimationValue < 0.5
        ? logoAnimationValue * 2
        : 2 - (logoAnimationValue * 2);
    final logoScale = 1.0 + 0.08 * logoScaleProgress;

    // Shadow intensity animation
    final shadowIntensity = 0.3 + (0.1 * logoScaleProgress);

    return Transform.scale(
      scale: logoScale,
      child: Container(
        width: widget.logoSize,
        height: widget.logoSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.logoBackgroundColor,
          border: Border.all(
            color: widget.logoBorderColor.withOpacity(0.3),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(shadowIntensity),
              blurRadius: 60,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            widget.logoPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

