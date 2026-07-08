import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _LoginNavigationHelper {
  static bool navigated = false;
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  
  Timer? _progressTimer;
  Timer? _messageTimer;
  double _loadingProgress = 0.0;
  int _currentMessageIndex = 0;

  final List<String> _bootMessages = [
    "Initializing AI Core...",
    "Loading Robot Models...",
    "Connecting Simulation Engine...",
    "Loading Navigation Mesh...",
    "Synchronizing Sensors...",
    "Calibrating Motors...",
    "Simulation Ready"
  ];

  @override
  void initState() {
    super.initState();
    _LoginNavigationHelper.navigated = false;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
    _rotateController.repeat();

    // Smooth progress simulation (3.6 seconds total)
    const int totalDurationMs = 3600;
    const int stepMs = 30;
    const double increment = stepMs / totalDurationMs;

    _progressTimer = Timer.periodic(const Duration(milliseconds: stepMs), (timer) {
      if (mounted) {
        setState(() {
          if (_loadingProgress < 1.0) {
            _loadingProgress += increment;
          } else {
            _loadingProgress = 1.0;
            _progressTimer?.cancel();
            
            // Glitch zoom effect delay, then navigate
            Future.delayed(const Duration(milliseconds: 600), () {
              _navigateToLogin();
            });
          }
        });
      }
    });

    // Message change simulation (every 500ms)
    _messageTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          if (_currentMessageIndex < _bootMessages.length - 1) {
            _currentMessageIndex++;
          } else {
            _messageTimer?.cancel();
          }
        });
      }
    });
  }

  void _navigateToLogin() {
    if (_LoginNavigationHelper.navigated) return;
    _LoginNavigationHelper.navigated = true;
    
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotateController.dispose();
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff55E8FF); // Electric Blue
    const darkBg = Color(0xff090A0F); // Dark Space Bg
    const greenStatus = Color(0xff00FF66); // Neon Green

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: darkBg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToLogin,
        child: Stack(
          children: [
            // Full Screen Background Image (Robot torso)
            Positioned.fill(
              child: Image.asset(
                'assets/robot_splash.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // Dark Radial Overlay Gradient to make UI readable and focus on center
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.3,
                    colors: [
                      darkBg.withOpacity(0.4),
                      darkBg.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),

            // Animated Rotating HUD Rings behind and around the center
            Center(
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return SizedBox(
                    width: math.min(screenWidth * 0.85, 340),
                    height: math.min(screenWidth * 0.85, 340),
                    child: CustomPaint(
                      painter: HudRingPainter(
                        rotationAngle: _rotateController.value * 2 * math.pi,
                        color: primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),

            // MAIN CONTENT OVERLAY
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // 1. BRAND HEADER SECTION
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Custom blucursor logo image
                        Image.asset(
                          'assets/logo_blucursor.png',
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                        // Titles
                        Text(
                          'BLUCURSOR',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 5.0,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'FLEET INTELLIGENCE SYSTEM',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tagline with bracket lines
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 1,
                              color: primaryColor.withOpacity(0.3),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Simulate. Analyze. Optimize.',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 30,
                              height: 1,
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Push the Connecting Card slightly down from the header
                  const Spacer(flex: 3),

                  // 3. CONNECTING STATUS CARD (Lower Middle, moved slightly up)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: math.min(screenWidth * 0.85, 340),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: darkBg.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CONNECTING',
                            style: GoogleFonts.outfit(
                              color: primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _bootMessages[_currentMessageIndex].toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Loading Bar & Percentage
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 4.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _loadingProgress,
                                      backgroundColor: Colors.transparent,
                                      valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(_loadingProgress * 100).toInt()}%',
                                style: GoogleFonts.jetBrainsMono(
                                  color: primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Establishing secure link...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Connected row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: greenStatus,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI NODE CONNECTED // ACTIVE MODE',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Flex spacer between Connecting Card and Bottom Action Tiles
                  const Spacer(flex: 2),

                  // 4. BOTTOM ACTION TILES GRID/ROW
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionTile(
                            icon: Icons.smart_toy_outlined,
                            title: 'SIMULATE',
                            subtitle: 'Virtual Environments',
                            onTap: _navigateToLogin,
                          ),
                          _buildActionTile(
                            icon: Icons.track_changes_outlined,
                            title: 'CONTROL',
                            subtitle: 'Robot Operations',
                            onTap: _navigateToLogin,
                          ),
                          _buildActionTile(
                            icon: Icons.bar_chart_outlined,
                            title: 'ANALYZE',
                            subtitle: 'Data Insights',
                            onTap: _navigateToLogin,
                          ),
                          _buildActionTile(
                            icon: Icons.build_circle_outlined,
                            title: 'OPTIMIZE',
                            subtitle: 'Performance Boost',
                            onTap: _navigateToLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom action tile builder
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: 72,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff141822).withOpacity(0.65),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xff55E8FF).withOpacity(0.18),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xff55E8FF), size: 18),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 8.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 6.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom HUD Ring Painter
class HudRingPainter extends CustomPainter {
  final double rotationAngle;
  final Color color;
  
  HudRingPainter({required this.rotationAngle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Outer solid ring
    final outerPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, outerPaint);

    // Mid dashed rotating ring
    final dashedPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    final double dashWidth = 8;
    final double spaceWidth = 12;
    final double circumference = 2 * math.pi * (radius - 12);
    final int dashCount = (circumference / (dashWidth + spaceWidth)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final double angle = rotationAngle + (i * (dashWidth + spaceWidth) * 2 * math.pi / circumference);
      final double sweepAngle = dashWidth * 2 * math.pi / circumference;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 12),
        angle,
        sweepAngle,
        false,
        dashedPaint,
      );
    }
    
    // Inner ticks rotating counter-clockwise
    final innerDashedPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    const int innerDashCount = 10;
    for (int i = 0; i < innerDashCount; i++) {
      final double angle = -rotationAngle * 1.3 + (i * 2 * math.pi / innerDashCount);
      const double sweepAngle = 0.15; // small tick arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 26),
        angle,
        sweepAngle,
        false,
        innerDashedPaint,
      );
    }
    
    // Core boundary circle
    final corePaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(
      center,
      radius - 40,
      corePaint,
    );
  }

  @override
  bool shouldRepaint(covariant HudRingPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle || oldDelegate.color != color;
  }
}
