import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _LoginNavigationHelper {
  static bool navigated = false;
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoTransitionTimer;

  @override
  void initState() {
    super.initState();
    _LoginNavigationHelper.navigated = false;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto-transition fallback after 6 seconds
    _autoTransitionTimer = Timer(const Duration(seconds: 6), () {
      _navigateToLogin();
    });
  }

  void _navigateToLogin() {
    if (_LoginNavigationHelper.navigated) return;
    _LoginNavigationHelper.navigated = true;
    _autoTransitionTimer?.cancel();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoTransitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToLogin,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Logo
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Image.asset(
                        isDark ? 'assets/logo_light.png' : 'assets/logo_dark.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Center Image/Frame
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff3b82f6).withOpacity(isDark ? 0.15 : 0.08),
                              blurRadius: 40,
                              spreadRadius: 5,
                            )
                          ],
                          border: Border.all(
                            color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.asset(
                            'assets/robocore_splash.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Catcher, Title, Subtitle, and Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        children: [
                          Text(
                            'BLUCURSOR',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: isDark ? Colors.white : const Color(0xff0f172a),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ENTERPRISE FLEET COMMAND',
                            style: TextStyle(
                              color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Interactive Tap Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xff1e293b).withOpacity(0.4) : const Color(0xfff1f5f9),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xff3b82f6).withOpacity(isDark ? 0.15 : 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.flash_on,
                                  color: Color(0xff2563eb),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'TAP SCREEN TO ENTER PORTAL',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xff0f172a),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
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
            ),
          ),
        ),
      ),
    );
  }
}
