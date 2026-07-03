import 'dart:async';
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
    final theme = Theme.of(context);
    const primaryColor = Color(0xff55E8FF); // Electric Blue
    const darkSurface = Color(0xff141822); // Obsidian Surface

    return Scaffold(
      backgroundColor: const Color(0xff090A0F), // Dark Space Bg
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToLogin,
        child: Stack(
          children: [
            // Full Screen Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/robot_splash.png',
                fit: BoxFit.cover,
              ),
            ),
            // Dark Radial Overlay Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      const Color(0xff090A0F).withOpacity(0.35),
                      const Color(0xff090A0F).withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),
            // Frosted Glass container wrapping all texts in Center
            Align(
              alignment: const Alignment(0.0, 0.65),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      decoration: BoxDecoration(
                        color: darkSurface.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.55),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: primaryColor.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top HUD brand header
                          Text(
                            'BLUCURSOR',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'FLEET INTELLIGENCE SYSTEM',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: theme.colorScheme.onBackground.withOpacity(0.5),
                            ),
                          ),
                          
                          const SizedBox(height: 36),
                          
                          // Booting Log & Status
                          Text(
                            _bootMessages[_currentMessageIndex],
                            style: GoogleFonts.jetBrainsMono(
                              color: primaryColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Smooth linear boot progress bar
                          Container(
                            width: 180,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.15),
                                width: 0.5,
                              ),
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
                          const SizedBox(height: 24),
                          Text(
                            'AI NODE CONNECTED // ACTIVE MODE',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.4),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
