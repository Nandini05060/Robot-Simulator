import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/greeting_screen.dart';
import 'screens/control_panel_screen.dart';
import 'screens/real_time_viz_screen.dart';
import 'models/robot.dart';

void main() {
  runApp(const BluCursorFleetApp());
}

class BluCursorFleetApp extends StatefulWidget {
  const BluCursorFleetApp({Key? key}) : super(key: key);

  static _BluCursorFleetAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_BluCursorFleetAppState>()!;

  @override
  State<BluCursorFleetApp> createState() => _BluCursorFleetAppState();
}

class _BluCursorFleetAppState extends State<BluCursorFleetApp> {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bluCursor Fleet Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/control_panel') {
          final robot = settings.arguments as Robot;
          return SplitDoorsRoute(
            page: const ControlPanelScreen(),
            robot: robot,
          );
        }
        return null;
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/greeting': (context) => const GreetingScreen(),
        '/dashboard': (context) => const MainNavigationShell(),
        '/real_time_viz': (context) => const RealTimeVizScreen(),
      },
    );
  }
}

class SplitDoorsRoute extends PageRouteBuilder {
  final Widget page;
  final Robot robot;

  SplitDoorsRoute({required this.page, required this.robot})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 2200), // 1.4s load + 0.8s split
          reverseTransitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _SplitDoorsTransition(
              animation: animation,
              child: child,
              robot: robot,
            );
          },
        );
}

class _SplitDoorsTransition extends StatefulWidget {
  final Animation<double> animation;
  final Widget child;
  final Robot robot;

  const _SplitDoorsTransition({
    Key? key,
    required this.animation,
    required this.child,
    required this.robot,
  }) : super(key: key);

  @override
  State<_SplitDoorsTransition> createState() => _SplitDoorsTransitionState();
}

class _SplitDoorsTransitionState extends State<_SplitDoorsTransition> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserSweepAnimation;

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
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double value = widget.animation.value;
    
    double progress = 0.0;
    double splitProgress = 0.0;
    
    if (value < 0.64) {
      progress = value / 0.64;
      splitProgress = 0.0;
    } else {
      progress = 1.0;
      splitProgress = Curves.easeInOutCubic.transform((value - 0.64) / 0.36);
    }

    final size = MediaQuery.of(context).size;
    final leftOffset = Offset(-size.width / 2 * splitProgress, 0);
    final rightOffset = Offset(size.width / 2 * splitProgress, 0);

    return Stack(
      children: [
        widget.child,
        
        if (splitProgress < 1.0) ...[
          // Left Door Panel
          Transform.translate(
            offset: leftOffset,
            child: SizedBox(
              width: size.width / 2,
              height: size.height,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.5,
                  child: Container(
                    color: const Color(0xff0A0E17),
                    child: Center(
                      child: Container(
                        width: 1,
                        height: double.infinity,
                        color: Colors.white.withOpacity(0.015),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Right Door Panel
          Positioned(
            right: 0,
            child: Transform.translate(
              offset: rightOffset,
              child: SizedBox(
                width: size.width / 2,
                height: size.height,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: 0.5,
                    child: Container(
                      color: const Color(0xff0A0E17),
                      child: Center(
                        child: Container(
                          width: 1,
                          height: double.infinity,
                          color: Colors.white.withOpacity(0.015),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading Progress Card
          if (splitProgress < 0.15)
            Center(
              child: Opacity(
                opacity: (1.0 - splitProgress * 6.6).clamp(0.0, 1.0),
                child: Container(
                  width: 290,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xff131926).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xff00A2FF).withOpacity(0.15), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.55),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.robot.name} CONNECTING',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SYNCHRONIZING TELEMETRY STREAM',
                        style: GoogleFonts.outfit(
                          color: const Color(0xff64748B),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Robot Render Container
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xff00A2FF).withOpacity(0.03),
                          border: Border.all(color: Colors.white.withOpacity(0.015)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              widget.robot.imagePath,
                              width: 75,
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
                                              color: const Color(0xff00A2FF),
                                              boxShadow: [
                                                BoxShadow(color: const Color(0xff00A2FF).withOpacity(0.8), blurRadius: 4),
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
                      const SizedBox(height: 20),
                      
                      // Progress Bar
                      Container(
                        width: double.infinity,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff00A2FF),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: const [
                                  BoxShadow(color: Color(0xff00A2FF), blurRadius: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Status Text
                      Text(
                        'INITIALIZING QUANTUM DUPLEX LINK',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xff00A2FF),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
