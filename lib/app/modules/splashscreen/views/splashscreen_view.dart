import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kissan_connect/app/modules/home/views/home_view.dart';
import 'package:kissan_connect/app/modules/selectlanguage/views/selectlanguage_view.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> 
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _breatheController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller (4 seconds)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Logo scale animation controller - Slower animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Increased from 1500 to 2500ms
    )..forward();

    // Particle effect controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Slower breathing effect for subtle pulsing
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Slowed down from 3000ms
    )..repeat(reverse: true);

    // Slower scale up animation for logo with smooth curve
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic, // Changed from elasticOut to easeOutCubic for smoother motion
      ),
    );

    // Fade in animation
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    // Simple rotation (subtle)
    _logoRotateAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Simple slide up
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    // Glow pulse animation
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOut,
      ),
    );

    // Breathing scale animation
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _mainController.forward();
    
    // Navigate to home after 4 seconds
    Timer(const Duration(seconds: 5), () {
      Get.offAll(
        () => SelectlanguageView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 1000),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE8F5E9),
              const Color(0xFFFFF8E1),
              const Color(0xFFE0F2F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particle background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticlePainter(
                      animationValue: _particleController.value,
                    ),
                  );
                },
              ),
            ),

            // Animated gradient orbs
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return Stack(
                  children: [
                    _buildFloatingOrb(
                      top: 100 + (50 * sin(_particleController.value * 2 * pi)),
                      left: 50 + (30 * cos(_particleController.value * 2 * pi)),
                      size: 150,
                      color: Colors.green.withOpacity(0.1),
                    ),
                    _buildFloatingOrb(
                      bottom: 150 + (40 * sin(_particleController.value * 2 * pi + pi)),
                      right: 60 + (25 * cos(_particleController.value * 2 * pi + pi)),
                      size: 120,
                      color: Colors.amber.withOpacity(0.1),
                    ),
                  ],
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Simple Growing Circle Animation
                  ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing outer circle
                          AnimatedBuilder(
                            animation: _breatheController,
                            builder: (context, child) {
                              final scale = 1.0 + (0.1 * _breatheController.value);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.green.withOpacity(0.1),
                                        Colors.green.withOpacity(0.0),
                                      ],
                                      stops: const [0.0, 0.8],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Main logo with subtle scale animation
                          Hero(
                            tag: 'app-logo',
                            child: Container(
                              width: 180,
                              height: 180,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/applogo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // App Name with fade and slide
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: Column(
                        children: [
                          // App Name with letter animation
                          AnimatedBuilder(
                            animation: _mainController,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: const [
                                      Color(0xFF1B5E20),
                                      Color(0xFF2E7D32),
                                      Color(0xFF43A047),
                                      Color(0xFF2E7D32),
                                    ],
                                    stops: [
                                      0.0,
                                      max(0.0, _mainController.value - 0.3),
                                      min(1.0, _mainController.value + 0.3),
                                      1.0,
                                    ],
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  'Kissan Connect',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Tagline with shimmer
                          AnimatedBuilder(
                            animation: _mainController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _mainController.value > 0.5 
                                    ? (((_mainController.value - 0.5) * 2).clamp(0.0, 1.0))
                                    : 0.0,
                                child: const Text(
                                  'Cultivating Connections, Growing Together',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF388E3C),
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Removed the bottom three dots loading indicator
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  final Random random = Random(42);
  final List<Offset> particlePositions = [];
  final List<double> particleSpeeds = [];
  final List<double> particleRadii = [];
  final List<Color> particleColors = [];

  ParticlePainter({required this.animationValue}) {
    if (particlePositions.isEmpty) {
      // Initialize particles only once
      for (int i = 0; i < 30; i++) {
        particlePositions.add(Offset.zero);
        particleSpeeds.add(0.5 + random.nextDouble() * 2.0);
        particleRadii.add(1.0 + random.nextDouble() * 2.0);
        particleColors.add(
          (i % 2 == 0 ? Colors.green : Colors.amber).withOpacity(0.1 + random.nextDouble() * 0.3),
        );
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < 30; i++) {
      // Calculate particle position based on animation value and speed
      final progress = (animationValue * particleSpeeds[i]) % 1.0;
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + 
          progress * size.height * 0.5) % size.height;
      
      // Update particle position
      particlePositions[i] = Offset(x, y);
      
      // Calculate opacity based on animation
      final opacity = 0.1 + (0.3 * sin(progress * pi));
      
      // Draw particle
      paint.color = particleColors[i].withOpacity(
        particleColors[i].opacity * opacity,
      );
      
      canvas.drawCircle(
        particlePositions[i],
        particleRadii[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}