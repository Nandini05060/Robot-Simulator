import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/robot.dart';
import '../main.dart';
import 'real_time_viz_screen.dart';

class RobotLoadingScreen extends StatefulWidget {
  const RobotLoadingScreen({Key? key}) : super(key: key);

  @override
  State<RobotLoadingScreen> createState() => _RobotLoadingScreenState();
}

class _RobotLoadingScreenState extends State<RobotLoadingScreen> with TickerProviderStateMixin {
  late Robot _robot;
  bool _initialized = false;
  double _progress = 0.0;
  String _statusText = "INITIALIZING SECURE LINK...";
  int _logIndex = 0;
  Timer? _progressTimer;
  late AnimationController _laserController;
  late Animation<double> _laserSweepAnimation;

  final List<String> _connectionLogs = [
    "ESTABLISHING TELEMETRY HANDSHAKE...",
    "CALIBRATING LIDAR SENSOR STREAM...",
    "SYNCING LOCAL COORDINATE GRID...",
    "DECRYPTING AUTONOMOUS PATH DATA...",
    "TELEMETRY READY. DEPLOYING SHIELD CORES..."
  ];

  @override
  void initState() {
    super.initState();
    
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    
    _laserSweepAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    // Run loading progress over 2.5 seconds
    const int durationMs = 2500;
    const int tickMs = 25;
    const double increment = tickMs / durationMs;

    _progressTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 1.0) {
          _progress += increment;
          
          // Update status logs progressively based on progress
          int targetLogIndex = (_progress * _connectionLogs.length).floor().clamp(0, _connectionLogs.length - 1);
          if (targetLogIndex != _logIndex) {
            _logIndex = targetLogIndex;
            _statusText = _connectionLogs[_logIndex];
          }
        } else {
          _progress = 1.0;
          _progressTimer?.cancel();
          
          // Complete and transition to map
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                SplitDoorsRoute(
                  page: const RealTimeVizScreen(),
                  robot: _robot,
                ),
              );
            }
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Robot) {
        _robot = args;
      } else {
        _robot = sampleRobots[0]; // fallback
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff55E8FF); // Electric Blue
    const accentColor = Color(0xff00D2FF);  // Neon Blue Accent
    const darkSurface = Color(0xff141822); // Obsidian Card
    const darkBg = Color(0xff090A0F);      // Dark Space Bg

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/robot_loading_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Tint overlay for premium readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xff090A0F).withOpacity(0.70),
                    const Color(0xff090A0F).withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),
          // Radial Glowing Accent
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    primaryColor.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main Content HUD
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: darkSurface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtitle
                      Text(
                        'SECURE LINK COM-PORT',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Robot Name Title
                      Text(
                        _initialized ? '${_robot.name} CONNECTING' : 'CONNECTING',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Radar / Scan Box
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.4),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_initialized)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(85),
                                child: Image.asset(
                                  _robot.imagePath,
                                  width: 125,
                                  height: 125,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.smart_toy, size: 48, color: primaryColor),
                                ),
                              ),
                            
                            // Laser Sweep Scan Line
                            AnimatedBuilder(
                              animation: _laserSweepAnimation,
                              builder: (context, child) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double top = _laserSweepAnimation.value * constraints.maxHeight;
                                    return Stack(
                                      children: [
                                        Positioned(
                                          top: top,
                                          left: constraints.maxWidth * 0.05,
                                          width: constraints.maxWidth * 0.9,
                                          height: 1.5,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: accentColor,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accentColor.withOpacity(0.8),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Progress Bar
                      Container(
                        width: double.infinity,
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
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progress,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xff00a3ff), primaryColor],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      
                      // Percentage Ticker
                      Text(
                        '${(_progress * 100).toInt()}% Synchronized',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Connection log
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _statusText,
                          key: ValueKey<String>(_statusText),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(
                            color: primaryColor.withOpacity(0.8),
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
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
  }
}
