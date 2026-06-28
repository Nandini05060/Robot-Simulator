import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _robotMoveController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  double _loadingProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _robotMoveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Simulate loading progress
    _progressTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      setState(() {
        if (_loadingProgress < 1.0) {
          _loadingProgress += 0.01;
        } else {
          _progressTimer?.cancel();
          _navigateToLogin();
        }
      });
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    _robotMoveController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Blucursor Logo/Illustration Card
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff131926) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                              ? Colors.black.withOpacity(0.4) 
                              : const Color(0xff2563eb).withOpacity(0.08),
                          blurRadius: 35,
                          offset: const Offset(0, 15),
                        )
                      ],
                      border: Border.all(
                        color: isDark 
                            ? const Color(0xff1e293b) 
                            : const Color(0xffcbd5e1),
                        width: 1.5,
                      ),
                    ),
                    child: Image.asset(
                      isDark ? 'assets/logo_light.png' : 'assets/logo_dark.png',
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'ROBOT MANAGEMENT SYSTEM',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xff2563eb),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Smart Office Control',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xff0f172a),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ENTERPRISE ROBOTICS PLATFORM',
                      style: TextStyle(
                        color: isDark ? const Color(0xff64748b) : const Color(0xff475569),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),

              // Realistic Robot Illustration Card
              Container(
                height: 150,
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xff2563eb).withOpacity(0.05),
                  border: Border.all(
                    color: const Color(0xff2563eb).withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Image.asset(
                  'assets/robot_splash.png',
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(flex: 1),

              // Progress Bar
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 4,
                      width: 200,
                      child: LinearProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0),
                        color: const Color(0xff2563eb),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Simulator Engine... ${( _loadingProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xff64748b) : const Color(0xff475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
