// ==========================================================================
// SIMULATED ROBOT DATABASE & STATE
// ==========================================================================
let robots = [
  { id: 'RB-001', name: 'Atlas', status: 'Online', batteryLevel: 88, position: '12.4, 8.2', angle: 45, lastActivity: 'Active now', modelType: 'Industrial Forklift', image: 'assets/robot_ares.png' },
  { id: 'RB-002', name: 'Titan', status: 'Online', batteryLevel: 94, position: '5.8, 14.3', angle: 180, lastActivity: 'Idle', modelType: 'Delivery Unit', image: 'assets/robot_hermes.png' },
  { id: 'RB-003', name: 'Nova', status: 'Offline', batteryLevel: 12, position: '20.1, 4.7', angle: 270, lastActivity: '4 hours ago', modelType: 'Heavy Pallet Mover', image: 'assets/robot_cronus.png' },
  { id: 'RB-004', name: 'Orion', status: 'Online', batteryLevel: 62, position: '18.9, 12.0', angle: 90, lastActivity: 'Scanning area', modelType: 'LIDAR Scanner', image: 'assets/robot_zeus.png' },
  { id: 'RB-005', name: 'Vega', status: 'Online', batteryLevel: 45, position: '8.1, 9.6', angle: 125, lastActivity: 'Moving cargo', modelType: 'Small Sorting Bot', image: 'assets/robot_pallas.png' }
];

let activeRobot = robots[0];
let currentScreen = 'splash';
let screenHistory = [];
let splashTimer = null;
let realtimePathTimer = null;
let realtimePathIndex = 0;
let realtimeTrail = [];
let consoleLogs = [];
let isAdminSimMode = false;
let activeMapImg = 'assets/map_6.png';
const mapRatios = {
  'assets/map_1.png': 1.0000,
  'assets/map_2.png': 1.2147,
  'assets/map_3.png': 0.9333,
  'assets/map_4.png': 1.1506,
  'assets/map_5.png': 0.7930,
  'assets/map_6.png': 0.7930
};

const routePath = [
  [4.0, 4.0, 326],
  [4.0, 14.0, 180],
  [12.0, 14.0, 90],
  [12.0, 8.0, 0],
  [22.0, 8.0, 90],
  [22.0, 16.0, 180],
  [12.0, 16.0, 270],
  [4.0, 4.0, 326]
];

// ==========================================================================
// SOURCE CODE DATABASE FOR FLUTTER CODE EXPLORER
// ==========================================================================
const codeFiles = {
  pubspec: `name: blucursor_fleet_manager
description: A modern enterprise-grade Flutter mobile application for bluCursor Fleet Management.
version: 1.0.0+2

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  flutter_animate: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/robot_ares.png
    - assets/robot_hermes.png
    - assets/robot_cronus.png`,

  main: `import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/control_panel_screen.dart';
import 'screens/real_time_viz_screen.dart';

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
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainNavigationShell(),
        '/control_panel': (context) => const ControlPanelScreen(),
        '/real_time_viz': (context) => const RealTimeVizScreen(),
      },
    );
  }
}`,

  theme: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xff55E8FF);   // Electric Blue
  static const Color accentColor = Color(0xff00D2FF);    // Neon Blue Accent
  static const Color highlightColor = Color(0xff8A8D99); // Secondary Gray
  
  static const Color successColor = Color(0xff00D2FF);   // Neon Blue Accent
  static const Color warningColor = Color(0xffFFB800);
  static const Color dangerColor = Color(0xffFF4B5C);
  
  static const Color darkBg = Color(0xff090A0F);         // Dark Space Background
  static const Color darkSurface = Color(0xff141822);    // Obsidian Card Background
  static const Color darkTextPrimary = Color(0xffF5F5F5);  // Soft White
  static const Color darkTextSecondary = Color(0xff8A8D99);
  static const Color darkBorder = Color(0x2655e8ff);     // Electric Blue transparent

  static ThemeData get lightTheme => darkTheme;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: highlightColor,
        surface: darkSurface,
        background: darkBg,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBg,
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
          titleLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
          titleMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          bodyLarge: const TextStyle(color: darkTextPrimary, fontSize: 16),
          bodyMedium: const TextStyle(color: darkTextSecondary, fontSize: 14),
        ),
      ),
    );
  }
}`,

  robot_model: `class Robot {
  final String id;
  final String name;
  final String status; // 'Online' | 'Offline'
  final int batteryLevel;
  final String position; // e.g. "12.4, 8.2"
  final double angle;
  final String lastActivity;
  final String modelType;
  final String imagePath;

  Robot({
    required this.id,
    required this.name,
    required this.status,
    required this.batteryLevel,
    required this.position,
    required this.angle,
    required this.lastActivity,
    required this.modelType,
    required this.imagePath,
  });

  bool get isOnline => status.toLowerCase() == 'online';
}`,

  splash: `import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  double _loadingProgress = 0.0;
  int _currentMessageIndex = 0;
  Timer? _progressTimer;

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
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
    _rotateController.repeat();

    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_loadingProgress < 1.0) {
          _loadingProgress += 0.0083; // matches 3.6s
        } else {
          _progressTimer?.cancel();
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Renders custom SVG rotating radar & Outfit status ticks...
    return Scaffold(
      backgroundColor: const Color(0xff090A0F),
      body: Center(
        child: Column(
          children: [
            // Top HUD header, Rotating radar & progress bar...
          ],
        ),
      ),
    );
  }
}`,

  login: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'operator@blucursor.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isBiometricScanning = false;
  String _biometricStatus = 'INITIALIZING BIO-LINK...';
  double _biometricProgress = 0.0;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isBiometricScanning = true;
        _biometricStatus = "ESTABLISHING SECURE CONNECTION...";
        _biometricProgress = 0.05;
      });
      // 3-second biometric pattern scan log loop before pushing dashboard
      Future.delayed(const Duration(milliseconds: 3000), () {
        Navigator.pushReplacementNamed(context, '/dashboard');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If _isBiometricScanning is active, render biometric scanning grid & fingerprint overlay...
    // Otherwise, render frosted credentials glass form with Neon Blue theme accents...
    return Scaffold(
      backgroundColor: const Color(0xff090A0F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(),
        ),
      ),
    );
  }
}`,

  shell: `import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'delivery_cart_screen.dart';
import 'patrolling_screen.dart';
import 'settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  static _MainNavigationShellState of(BuildContext context) =>
      context.findAncestorStateOfType<_MainNavigationShellState>()!;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    DeliveryCartScreen(),
    PatrollingScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xff2563eb),
        unselectedItemColor: const Color(0xff64748b),
        onTap: setTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Delivery'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Patrolling'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}`,

  dashboard: `import 'package:flutter/material.dart';
import 'main_navigation_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Section
            // About Application Card
            // System Analytics cards
            // Main Category cards (Delivery, Patrolling) -> switch tabs on tap
          ],
        ),
      ),
    );
  }
}`,

  delivery: `import 'package:flutter/material.dart';
import '../models/robot.dart';

class DeliveryCartScreen extends StatelessWidget {
  const DeliveryCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lists Floor Maps A-E cards with Assigned Robot, Status, Battery.
    // Tapping pushes '/real_time_viz' with arguments of the assigned Robot.
    return Scaffold();
  }
}`,

  patrolling: `import 'package:flutter/material.dart';
import '../models/robot.dart';

class PatrollingScreen extends StatelessWidget {
  const PatrollingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lists Patrol Zones A-E cards with Assigned Robot, Status, Battery.
    // Tapping pushes '/real_time_viz' with arguments of the assigned Robot.
    return Scaffold();
  }
}`,

  viz: `import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/robot.dart';

class RealTimeVizScreen extends StatefulWidget {
  const RealTimeVizScreen({Key? key}) : super(key: key);

  @override
  State<RealTimeVizScreen> createState() => _RealTimeVizScreenState();
}

class _RealTimeVizScreenState extends State<RealTimeVizScreen> {
  Robot? _robot;
  late double _currentX, _currentY;
  double _angle = 0.0;
  late int _battery;
  double _speed = 0.8;
  String _direction = 'North-East';
  final List<Offset> _trail = [];
  bool _isManualOverride = false;
  int _currentPathIndex = 0;
  Timer? _simulationTimer;
  String _status = 'Online';

  // Default path for autonomous patrol
  final List<math.Point<double>> _navigationPath = [
    const math.Point(4.0, 4.0),
    const math.Point(4.0, 14.0),
    const math.Point(12.0, 14.0),
    const math.Point(12.0, 8.0),
    const math.Point(22.0, 8.0),
    const math.Point(22.0, 16.0),
    const math.Point(12.0, 16.0),
    const math.Point(4.0, 4.0),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Parse arguments and initialize coordinates...
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text('Telemetry: \${_robot?.name ?? "Robot"}')),
      body: Column(
        children: [
          // A. Large Office Map Viewport
          Expanded(
            flex: 4,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double mapWidth = constraints.maxWidth;
                final double mapHeight = constraints.maxHeight;
                
                final double robotX = 8 + (_currentX / 25) * (mapWidth - 16);
                final double robotY = 8 + (_currentY / 20) * (mapHeight - 16);

                return Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: OfficeMapPainter(isDark: isDark))),
                    Positioned.fill(child: CustomPaint(painter: TrailPainter(trail: _trail, isDark: isDark))),
                    Positioned(
                      left: robotX - 18,
                      top: robotY - 18,
                      width: 36,
                      height: 36,
                      child: PulsingRobotIndicator(angle: _angle),
                    ),
                  ],
                );
              },
            ),
          ),
          // B. Details HUD with premium circular indicators
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircularMetricTile('BATTERY', '\$_battery%', _battery / 100.0, Colors.green, Icons.battery_charging_full),
                    _buildCircularMetricTile('VELOCITY', '\${_speed.toStringAsFixed(1)} m/s', _speed / 2.0, Colors.teal, Icons.speed),
                    _buildCompassMetricTile('HEADING', _direction, _angle, Colors.deepPurple),
                  ],
                ),
                // Manual controllers panel with Resume Auto Nav button...
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularMetricTile(String label, String value, double percent, Color activeColor, IconData icon) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 2.5,
                backgroundColor: activeColor.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              ),
            ),
            Icon(icon, color: activeColor, size: 16),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }

  Widget _buildCompassMetricTile(String label, String value, double angle, Color activeColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: activeColor.withOpacity(0.15), width: 2.0)),
            ),
            Transform.rotate(
              angle: (angle + 90) * math.pi / 180, // corrected rotation direction
              child: Icon(Icons.navigation, color: activeColor, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ],
    );
  }
}

class TrailPainter extends CustomPainter {
  final List<Offset> trail;
  final bool isDark;
  TrailPainter({required this.trail, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length < 2) return;
    final paint = Paint()..color = Colors.blue.withOpacity(0.5)..strokeWidth = 3.0..style = PaintingStyle.stroke;
    final path = Path();
    final startPt = _getPixelOffset(trail[0], size);
    path.moveTo(startPt.dx, startPt.dy);
    for (int i = 1; i < trail.length; i++) {
      final pt = _getPixelOffset(trail[i], size);
      path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path, paint);
  }

  Offset _getPixelOffset(Offset pt, Size size) {
    final double px = 8 + (pt.dx / 25) * (size.width - 16);
    final double py = 8 + (pt.dy / 20) * (size.height - 16);
    return Offset(px, py);
  }

  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) => true;
}`,

  settings: `import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAdminMode = false;
  // profile card, role toggle switcher, admin actions listing (Activate/Deactivate), logout...
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}`,

  greeting: import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class GreetingScreen extends StatefulWidget {
  const GreetingScreen({Key? key}) : super(key: key);

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _floatController;
  late AnimationController _waveController;
  late AnimationController _crawlerController;
  
  late Animation<double> _spinAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _crawlerAnimation;

  int _activeLogIndex = 0;
  Timer? _logTimer;

  final List<String> _bootLogs = [
    "Initializing AI Core...",
    "Loading Fleet Data...",
    "Connecting Sensors...",
    "Calibration in Progress...",
    "Simulation Ready"
  ];

  @override
  void initState() {
    super.initState();
    
    // Minimal floor rings rotation
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _spinAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_spinController);

    // Smooth, slow float animation (Tesla style)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Waveform oscillation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_waveController);

    // Vector map crawler progress
    _crawlerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _crawlerAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(_crawlerController);

    // Timeline loading sequencer
    _logTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        setState(() {
          if (_activeLogIndex < _bootLogs.length - 1) {
            _activeLogIndex++;
          } else {
            _logTimer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _floatController.dispose();
    _waveController.dispose();
    _crawlerController.dispose();
    _logTimer?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final isAdmin = apiService.isAdminMode;
    final operatorName = isAdmin ? 'Dr. Aryan Mehta' : 'Operator Nandini';

    return Scaffold(
      backgroundColor: const Color(0xff0A0E17),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
        child: Stack(
          children: [
            // Coordinate Grid overlay (Blueprint / Coordinates)
            Positioned.fill(
              child: CustomPaint(
                painter: _RefinedCoordinateGridPainter(),
              ),
            ),
            
            // Soft Radial Gradients
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.35),
                    radius: 1.1,
                    colors: [
                      const Color(0xff00A2FF).withOpacity(0.04),
                      const Color(0xff10B981).withOpacity(0.01),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Scanning screen line (refined speed)
            const Positioned.fill(
              child: _ScreenScanLineEffectRefined(),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            
                            // 1. Top Header
                            Column(
                              children: [
                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff00A2FF).withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xff00A2FF).withOpacity(0.18)),
                                  ),
                                  child: Text(
                                    '[ SYS_OPERATIONAL ]',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: const Color(0xff00A2FF),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Welcome Labels
                                Text(
                                  _getGreeting(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xff64748B),
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      operatorName,
                                      style: GoogleFonts.outfit(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const _PulsingEmeraldDot(),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Subtitle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.monitor, size: 8, color: Color(0xff00A2FF)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'FLEET CONTROL CENTER',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xff64748B),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.monitor, size: 8, color: Color(0xff00A2FF)),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // 2. Main HUD Column / Row Center
                            SizedBox(
                              width: 280,
                              height: 380,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Minimal Coordinate rings (spin & perspective) scaled up
                                  Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.0015)
                                      ..rotateX(1.3),
                                    child: AnimatedBuilder(
                                      animation: _spinAnimation,
                                      builder: (context, child) {
                                        return CustomPaint(
                                          size: const Size(260, 260),
                                          painter: _MinimalCoordinateRingsPainter(_spinAnimation.value),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  // Glowing Platform Shadow Underneath (Refined) scaled up
                                  Positioned(
                                    bottom: 34,
                                    child: AnimatedBuilder(
                                      animation: _floatController,
                                      builder: (context, child) {
                                        final scale = 1.0 - (_floatAnimation.value / -32.0);
                                        return Container(
                                          width: 160 * scale,
                                          height: 16 * scale,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                const Color(0xff00A2FF).withOpacity(0.22 * scale),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Floating Robot Image (Scaled up & Circuit board robot)
                                  AnimatedBuilder(
                                    animation: _floatAnimation,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, _floatAnimation.value - 12),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: const Color(0xff00A2FF).withOpacity(0.3),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xff00A2FF).withOpacity(0.15),
                                                      blurRadius: 20,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Image.asset(
                                                  'assets/robot_splash.png',
                                                  width: 220,
                                                  height: 300,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            // Sweeping Laser Scan Line (Refined)
                                            const Positioned.fill(
                                              child: _LaserSweepEffectRefined(),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // 6. Footer prompt
                            Column(
                              children: [
                                Text(
                                  'INITIALIZE CONTROL SYSTEM',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 3.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const _PulsingText(text: 'TAP ANYWHERE TO CONTINUE'),
                                const SizedBox(height: 6),
                                const _PulsingChevronsRefined(),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required double width, required double height, required Widget child}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xff131926).withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffffffff).withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: const Color(0xff64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooter(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: const Color(0xff64748B),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: const Color(0xff00A2FF),
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooterWithNetworkBars(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: const Color(0xff64748B),
          ),
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: const Color(0xff00A2FF),
              ),
            ),
            const Row(
              children: [
                _NetworkBar(height: 3),
                SizedBox(width: 1),
                _NetworkBar(height: 5),
                SizedBox(width: 1),
                _NetworkBar(height: 7),
                SizedBox(width: 1),
                _NetworkBar(height: 9),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricBox(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff131926).withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffffffff).withOpacity(0.04)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 8, color: const Color(0xff00A2FF)),
              const SizedBox(width: 3),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 6.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleTimeline() {
    return Stack(
      children: [
        // Connecting line
        Positioned(
          left: 3,
          top: 3,
          bottom: 3,
          width: 0.8,
          child: Container(
            color: const Color(0xffffffff).withOpacity(0.03),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(_bootLogs.length, (index) {
            final isCompleted = index < _activeLogIndex;
            final isActive = index == _activeLogIndex;
            
            double opacity = 0.2;
            Color dotColor = const Color(0xff64748B);
            Color textColor = const Color(0xff64748B);
            
            if (isCompleted) {
              opacity = 0.65;
              dotColor = const Color(0xff10B981);
              textColor = const Color(0xffE2E8F0);
            } else if (isActive) {
              opacity = 1.0;
              dotColor = const Color(0xff00A2FF);
              textColor = const Color(0xff00A2FF);
            }

            return Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    // Dot
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [BoxShadow(color: dotColor.withOpacity(0.6), blurRadius: 4, spreadRadius: 1)]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Text
                    Expanded(
                      child: Text(
                        _bootLogs[index],
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8,
                          color: textColor,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// 1. Refined Coordinate Grid Painter (monochromatic)
class _RefinedCoordinateGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffffffff).withOpacity(0.012)
      ..strokeWidth = 0.6;

    const double step = 25.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Refined Waveform Painter
class _WaveformPainterRefined extends CustomPainter {
  final Animation<double> animation;
  _WaveformPainterRefined(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff00A2FF)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double midY = size.height / 2;
    final double phase = animation.value;

    path.moveTo(0, midY);
    for (double x = 0; x <= size.width; x++) {
      final double y = midY + math.sin(x * 0.15 + phase) * 5;
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainterRefined oldDelegate) => true;
}

// 3. Minimal 3D perspective floor coordinate painter
class _MinimalCoordinateRingsPainter extends CustomPainter {
  final double angle;
  _MinimalCoordinateRingsPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Center crosshair lines
    final paintCross = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.8;
    
    canvas.drawLine(Offset(cx - 70, cy), Offset(cx + 70, cy), paintCross);
    canvas.drawLine(Offset(cx, cy - 70), Offset(cx, cy + 70), paintCross);

    // Draw outer solid ring
    final paintOuter = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(Offset(cx, cy), 65, paintOuter);

    // Draw inner dashed ring rotated slowly
    final paintInner = Paint()
      ..color = const Color(0xff00A2FF).withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    _drawDashedCircle(canvas, 45, paintInner);
    canvas.restore();
  }

  void _drawDashedCircle(Canvas canvas, double radius, Paint paint) {
    const int dashCount = 12;
    final double dashAngle = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: radius),
          i * dashAngle,
          dashAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MinimalCoordinateRingsPainter oldDelegate) => true;
}

// 4. Mini Vector Map Painter (Nothing OS style crawler path)
class _MiniVectorMapPainter extends CustomPainter {
  final double pathProgress;
  _MiniVectorMapPainter(this.pathProgress);

  final List<math.Point<double>> points = const [
    math.Point(8.0, 44.0),
    math.Point(22.0, 16.0),
    math.Point(42.0, 28.0),
    math.Point(56.0, 12.0)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background dot grid
    final paintGrid = Paint()..color = Colors.white.withOpacity(0.04);
    for (double x = 4; x < size.width; x += 10) {
      for (double y = 4; y < size.height; y += 10) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paintGrid);
      }
    }

    // Draw coordinate label text
    final currentSegment = pathProgress.floor();
    final t = pathProgress - currentSegment;
    final p1 = points[currentSegment];
    final p2 = points[(currentSegment + 1) % points.length];
    final rx = p1.x + (p2.x - p1.x) * t;
    final ry = p1.y + (p2.y - p1.y) * t;

    // Draw dashed path tracks
    final paintPathBg = Paint()
      ..color = const Color(0xff00A2FF).withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final pathBg = Path()..moveTo(points[0].x, points[0].y);
    for (int i = 1; i < points.length; i++) {
      pathBg.lineTo(points[i].x, points[i].y);
    }
    canvas.drawPath(pathBg, paintPathBg);

    // Draw traveled solid blue path
    final paintPathActive = Paint()
      ..color = const Color(0xff00A2FF).withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final pathActive = Path()..moveTo(points[0].x, points[0].y);
    for (int i = 1; i <= currentSegment; i++) {
      pathActive.lineTo(points[i].x, points[i].y);
    }
    pathActive.lineTo(rx, ry);
    canvas.drawPath(pathActive, paintPathActive);

    // Draw crawler point (emerald)
    final paintCrawler = Paint()
      ..color = const Color(0xff10B981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(rx, ry), 2.0, paintCrawler);

    // Draw coordinate readouts
    const textStyle = TextStyle(
      color: Color(0xff64748B),
      fontSize: 5,
      fontFamily: 'monospace',
    );
    
    final textPainterX = TextPainter(
      text: TextSpan(text: 'X:\${rx.toStringAsFixed(1)}', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterX.paint(canvas, const Offset(4, 4));

    final textPainterY = TextPainter(
      text: TextSpan(text: 'Y:\${ry.toStringAsFixed(1)}', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterY.paint(canvas, const Offset(4, 11));
  }

  @override
  bool shouldRepaint(covariant _MiniVectorMapPainter oldDelegate) => true;
}

// 5. Pulsing Emerald Dot Widget
class _PulsingEmeraldDot extends StatefulWidget {
  const _PulsingEmeraldDot({Key? key}) : super(key: key);

  @override
  State<_PulsingEmeraldDot> createState() => _PulsingEmeraldDotState();
}

class _PulsingEmeraldDotState extends State<_PulsingEmeraldDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _animation = Tween<double>(begin: 1.0, end: 5.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xff10B981),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xff10B981).withOpacity(0.6),
                blurRadius: _animation.value,
                spreadRadius: _animation.value / 3,
              ),
            ],
          ),
        );
      },
    );
  }
}

// 6. Sweeping Laser Effect (Refined)
class _LaserSweepEffectRefined extends StatefulWidget {
  const _LaserSweepEffectRefined({Key? key}) : super(key: key);

  @override
  State<_LaserSweepEffectRefined> createState() => _LaserSweepEffectRefinedState();
}

class _LaserSweepEffectRefinedState extends State<_LaserSweepEffectRefined> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _animation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (_animation.value < 0 || _animation.value > 1) return const SizedBox();
        return LayoutBuilder(
          builder: (context, constraints) {
            final top = _animation.value * constraints.maxHeight;
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
                        BoxShadow(
                          color: const Color(0xff00A2FF).withOpacity(0.8),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: const Color(0xff00A2FF).withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
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
    );
  }
}

// 7. Screen Scan Line Overlay (Refined speed)
class _ScreenScanLineEffectRefined extends StatefulWidget {
  const _ScreenScanLineEffectRefined({Key? key}) : super(key: key);

  @override
  State<_ScreenScanLineEffectRefined> createState() => _ScreenScanLineEffectRefinedState();
}

class _ScreenScanLineEffectRefinedState extends State<_ScreenScanLineEffectRefined> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _animation = Tween<double>(begin: -0.05, end: 1.05).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (_animation.value < 0 || _animation.value > 1) return const SizedBox();
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned(
                  top: _animation.value * constraints.maxHeight,
                  left: 0,
                  width: constraints.maxWidth,
                  height: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xff00A2FF).withOpacity(0.12),
                          const Color(0xff00A2FF).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// 8. Pulsing Text Helper
class _PulsingText extends StatefulWidget {
  final String text;
  const _PulsingText({Key? key, required this.text}) : super(key: key);

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          widget.text,
          style: GoogleFonts.outfit(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: Color.lerp(const Color(0xff64748B), const Color(0xff00A2FF), _controller.value)!.withOpacity(_animation.value),
            letterSpacing: 1.5,
          ),
        );
      },
    );
  }
}

// 9. Pulsing double arrow chevrons (Refined)
class _PulsingChevronsRefined extends StatefulWidget {
  const _PulsingChevronsRefined({Key? key}) : super(key: key);

  @override
  State<_PulsingChevronsRefined> createState() => _PulsingChevronsRefinedState();
}

class _PulsingChevronsRefinedState extends State<_PulsingChevronsRefined> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 3.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Opacity(
            opacity: 1.0 - (_animation.value / 3.0),
            child: const Icon(
              Icons.keyboard_double_arrow_down,
              color: Color(0xff00A2FF),
              size: 20,
            ),
          ),
        );
      },
    );
  }
}

// 10. Network bar indicator
class _NetworkBar extends StatelessWidget {
  final double height;
  const _NetworkBar({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xff00A2FF),
        borderRadius: BorderRadius.circular(0.5),
      ),
    );
  }
}
,};

// ==========================================================================
// SIMULATOR APP ROUTING & LIFE CYCLE
// ==========================================================================
function switchCodeFile(fileKey) {
  const displayedNameMap = {
    pubspec: 'pubspec.yaml',
    main: 'lib/main.dart',
    theme: 'lib/theme/app_theme.dart',
    robot_model: 'lib/models/robot.dart',
    splash: 'lib/screens/splash_screen.dart',
    login: 'lib/screens/login_screen.dart',
    greeting: 'lib/screens/greeting_screen.dart',
    shell: 'lib/screens/main_navigation_shell.dart',
    dashboard: 'lib/screens/dashboard_screen.dart',
    delivery: 'lib/screens/delivery_cart_screen.dart',
    patrolling: 'lib/screens/patrolling_screen.dart',
    viz: 'lib/screens/real_time_viz_screen.dart',
    settings: 'lib/screens/settings_screen.dart'
  };

  document.querySelectorAll('.code-tab').forEach(tab => {
    tab.classList.remove('active');
  });

  const activeTab = document.querySelector(`.code-tab[data-file="${fileKey}"]`);
  if (activeTab) {
    activeTab.classList.add('active');
  }

  document.getElementById('filePathDisplay').innerText = displayedNameMap[fileKey] || 'code_file.dart';
  
  // Highlight code if possible (as text for now)
  const codeEl = document.getElementById('codeDisplayCode');
  if (codeEl) {
    codeEl.innerText = codeFiles[fileKey] || '// Code not found';
  }
}

function toggleSidebarDrawer(isOpen) {
  const drawer = document.getElementById('app-side-drawer');
  const backdrop = document.getElementById('app-drawer-backdrop');
  if (drawer && backdrop) {
    if (isOpen) {
      drawer.classList.add('open');
      backdrop.classList.add('active');
    } else {
      drawer.classList.remove('open');
      backdrop.classList.remove('active');
    }
  }
}

function navigateFromDrawer(screenId) {
  toggleSidebarDrawer(false);
  
  // Update active state in drawer links
  document.querySelectorAll('.drawer-link').forEach(link => {
    link.classList.remove('active');
  });
  const activeLink = document.getElementById(`drawer-link-${screenId}`);
  if (activeLink) {
    activeLink.classList.add('active');
  }
  
  showScreen(screenId);
}

function animateValue(id, start, end, duration, decimals = 0) {
  const obj = document.getElementById(id);
  if (!obj) return;
  const range = end - start;
  const minTimer = 50;
  let stepTime = Math.abs(Math.floor(duration / (range || 1)));
  stepTime = Math.max(stepTime, minTimer);
  const startTime = new Date().getTime();
  const endTime = startTime + duration;
  let timer;
  
  function run() {
    const now = new Date().getTime();
    const remaining = Math.max((endTime - now) / duration, 0);
    const value = end - (remaining * range);
    obj.innerText = value.toFixed(decimals);
    if (value == end) {
      clearInterval(timer);
    }
  }
  
  timer = setInterval(run, stepTime);
  run();
}

function triggerMockAssignTask() {
  showToastNotification("Opening Task Assignment Panel... Simulation Mode Active.");
  setTimeout(() => {
    alert("Task Assignment Panel\n-------------------\nChoose Task:\n1. Deliver Documents to Conf Room\n2. Secure Patrol in Server corridor\n3. Return to charger dock\n\nSimulation: Assigned task 'Deliver Documents to Conf Room' to ARES-100.");
    const timestamp = new Date().toTimeString().split(' ')[0];
    consoleLogs.push(`[${timestamp}] [CMD] Cloud Task Assigned: 'Deliver Documents'`);
    if (currentScreen === 'real_time_viz') {
      renderConsoleFeed();
    }
  }, 300);
}

function triggerMockViewAnalytics() {
  const onlineCount = robots.filter(r => r.status === 'Online').length;
  showToastNotification("Generating Fleet Health Report...");
  setTimeout(() => {
    alert(`Fleet Health Summary\n-------------------\nTotal Fleet: ${robots.length}\nActive Robots: ${onlineCount}\nSystem Health: 98.6% (Nominal)\nGPS Latency: <12ms\nNetwork Jitter: 2.1ms\nAverage Battery: 66.8%\nAll safety loops are active.`);
  }, 400);
}

let deliveryViewType = 'cards';
let patrolViewType = 'cards';

function toggleModuleView(moduleType, viewType) {
  if (moduleType === 'delivery') {
    deliveryViewType = viewType;
    document.getElementById('delivery-toggle-cards').classList.toggle('active', viewType === 'cards');
    document.getElementById('delivery-toggle-table').classList.toggle('active', viewType === 'table');
    document.getElementById('delivery-maps-list').style.display = viewType === 'cards' ? 'flex' : 'none';
    document.getElementById('delivery-table-container').classList.toggle('active', viewType === 'table');
    renderDeliveryMaps();
  } else if (moduleType === 'patrol') {
    patrolViewType = viewType;
    document.getElementById('patrol-toggle-cards').classList.toggle('active', viewType === 'cards');
    document.getElementById('patrol-toggle-table').classList.toggle('active', viewType === 'table');
    document.getElementById('patrol-zones-list').style.display = viewType === 'cards' ? 'flex' : 'none';
    document.getElementById('patrol-table-container').classList.toggle('active', viewType === 'table');
    renderPatrolZones();
  }
}

function showScreen(screenId, isBack = false) {
  // Close drawer always
  toggleSidebarDrawer(false);

  // Sync drawer nav links active state
  document.querySelectorAll('.drawer-link').forEach(link => {
    link.classList.remove('active');
  });
  const drawerLink = document.getElementById(`drawer-link-${screenId}`);
  if (drawerLink) {
    drawerLink.classList.add('active');
  }

  if (!isBack && currentScreen !== screenId && currentScreen !== 'splash' && currentScreen !== 'login') {
    screenHistory.push(currentScreen);
  }

  // Handle nav active states
  document.querySelectorAll('.app-screen .app-nav-bar').forEach(navbar => {
    navbar.querySelectorAll('.nav-item').forEach(item => {
      item.classList.remove('active');
    });
    // Set active item
    let targetIndex = 0;
    if (screenId === 'dashboard') targetIndex = 0;
    else if (screenId === 'delivery') targetIndex = 1;
    else if (screenId === 'patrolling') targetIndex = 2;
    else if (screenId === 'settings') targetIndex = 3;
    
    const items = navbar.querySelectorAll('.nav-item');
    if (items[targetIndex]) {
      items[targetIndex].classList.add('active');
    }
  });

  // Check if we should trigger skeleton loading for simulated latency (450ms)
  const isModuleScreen = screenId === 'delivery' || screenId === 'patrolling';
  const skeletonLoader = document.getElementById('app-skeleton-loader');
  
  if (isModuleScreen && skeletonLoader) {
    skeletonLoader.classList.add('active');
  }

  setTimeout(() => {
    if (skeletonLoader) skeletonLoader.classList.remove('active');

    if (screenId === 'dashboard') {
      renderDashboardHUD();
      // Trigger counter tickers
      setTimeout(() => {
        const activeCount = robots.filter(r => r.status === 'Online').length;
        animateValue('stat-val-total', 0, robots.length, 500);
        animateValue('stat-val-active', 0, activeCount, 500);
        animateValue('stat-val-completed', 0, 142, 800);
        animateValue('stat-val-health', 0, 98.6, 600, 1);
        animateValue('stat-val-missions', 0, 2, 400);
      }, 100);
    } else if (screenId === 'delivery') {
      renderDeliveryMaps();
    } else if (screenId === 'patrolling') {
      renderPatrolZones();
    } else if (screenId === 'real_time_viz') {
      startRealtimeSimulation();
    } else if (screenId === 'greeting') {
      const greetingPrefixEl = document.getElementById('greeting-text-prefix');
      const operatorNameEl = document.getElementById('greeting-operator-name');
      const robotImgEl = document.getElementById('greeting-robot-img');
      
      if (greetingPrefixEl && operatorNameEl) {
        const hour = new Date().getHours();
        let greetingWord = "GOOD MORNING";
        if (hour >= 12 && hour < 17) {
          greetingWord = "GOOD AFTERNOON";
        } else if (hour >= 17 || hour < 5) {
          greetingWord = "GOOD EVENING";
        }
        greetingPrefixEl.innerText = greetingWord + ",";
        
        const nameText = isAdminSimMode ? "Dr. Aryan Mehta" : "Operator Nandini";
        operatorNameEl.innerHTML = `${nameText} <span class="emerald-dot"></span>`;
      }
      
      if (robotImgEl) {
        robotImgEl.src = 'assets/robot_splash.png';
      }

      // 1. Refined AI Core Waveform (sine wave)
      let waveformCanvas = document.getElementById('waveform-canvas');
      if (waveformCanvas) {
        let ctx = waveformCanvas.getContext('2d');
        let phase = 0;
        let animationFrameId;
        function drawWave() {
          if (currentScreen !== 'greeting') {
            cancelAnimationFrame(animationFrameId);
            return;
          }
          ctx.clearRect(0, 0, waveformCanvas.width, waveformCanvas.height);
          ctx.beginPath();
          ctx.strokeStyle = '#00A2FF';
          ctx.lineWidth = 1.2;
          for (let x = 0; x < waveformCanvas.width; x++) {
            let y = waveformCanvas.height / 2 + Math.sin(x * 0.15 + phase) * 5;
            if (x === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
          }
          ctx.stroke();
          phase += 0.05; // Slower and smoother
          animationFrameId = requestAnimationFrame(drawWave);
        }
        drawWave();
      }

      // 2. Refined Vector Coordinate Map Canvas Animation (Nothing OS style)
      let vectorMapCanvas = document.getElementById('vector-map-canvas');
      if (vectorMapCanvas) {
        let ctx = vectorMapCanvas.getContext('2d');
        let pathProgress = 0;
        let animationFrameId;
        
        const points = [
          {x: 8, y: 44},
          {x: 22, y: 16},
          {x: 42, y: 28},
          {x: 56, y: 12}
        ];
        
        function drawVectorMap() {
          if (currentScreen !== 'greeting') {
            cancelAnimationFrame(animationFrameId);
            return;
          }
          ctx.clearRect(0, 0, vectorMapCanvas.width, vectorMapCanvas.height);
          
          // Draw coordinate background dots
          ctx.fillStyle = 'rgba(255, 255, 255, 0.04)';
          for (let x = 4; x < vectorMapCanvas.width; x += 10) {
            for (let y = 4; y < vectorMapCanvas.height; y += 10) {
              ctx.fillRect(x, y, 1, 1);
            }
          }
          
          // Draw path tracks (dashed)
          ctx.beginPath();
          ctx.strokeStyle = 'rgba(0, 162, 255, 0.1)';
          ctx.lineWidth = 1;
          ctx.setLineDash([2, 2]);
          ctx.moveTo(points[0].x, points[0].y);
          for (let i = 1; i < points.length; i++) {
            ctx.lineTo(points[i].x, points[i].y);
          }
          ctx.stroke();
          ctx.setLineDash([]);
          
          // Calculate current crawler coordinates
          let currentSegment = Math.floor(pathProgress);
          let t = pathProgress - currentSegment;
          let p1 = points[currentSegment];
          let p2 = points[currentSegment + 1] || points[0];
          let rx = p1.x + (p2.x - p1.x) * t;
          let ry = p1.y + (p2.y - p1.y) * t;
          
          // Draw traveled track (solid blue)
          ctx.beginPath();
          ctx.strokeStyle = 'rgba(0, 162, 255, 0.3)';
          ctx.lineWidth = 1;
          ctx.moveTo(points[0].x, points[0].y);
          for (let i = 1; i <= currentSegment; i++) {
            ctx.lineTo(points[i].x, points[i].y);
          }
          ctx.lineTo(rx, ry);
          ctx.stroke();
          
          // Draw crawler point (emerald dot)
          ctx.beginPath();
          ctx.fillStyle = '#10B981';
          ctx.arc(rx, ry, 2, 0, Math.PI * 2);
          ctx.fill();
          
          // Pulse coordinate ring
          ctx.beginPath();
          ctx.strokeStyle = 'rgba(16, 185, 129, 0.35)';
          ctx.lineWidth = 0.8;
          let pulseRadius = 3 + Math.sin(Date.now() * 0.005) * 1.5;
          ctx.arc(rx, ry, Math.max(2.5, pulseRadius), 0, Math.PI * 2);
          ctx.stroke();
          
          // Coordinate labels
          ctx.font = '6px monospace';
          ctx.fillStyle = '#64748B';
          ctx.fillText(`X:${rx.toFixed(1)}`, 4, 8);
          ctx.fillText(`Y:${ry.toFixed(1)}`, 4, 15);
          
          pathProgress += 0.0035; // Very slow and smooth crawler
          if (pathProgress >= points.length - 1) {
            pathProgress = 0;
          }
          
          animationFrameId = requestAnimationFrame(drawVectorMap);
        }
        drawVectorMap();
      }

      // 3. Console Timeline Loader Sequence
      const totalNodes = 5;
      for (let i = 1; i <= totalNodes; i++) {
        let node = document.getElementById(`log-node-${i}`);
        if (node) {
          node.classList.remove('active', 'completed');
        }
      }
      
      let currentNodeIndex = 1;
      let activeNode = document.getElementById(`log-node-${currentNodeIndex}`);
      if (activeNode) activeNode.classList.add('active');

      let timelineInterval = setInterval(() => {
        if (currentScreen !== 'greeting') {
          clearInterval(timelineInterval);
          return;
        }
        let prevNode = document.getElementById(`log-node-${currentNodeIndex}`);
        if (prevNode) {
          prevNode.classList.remove('active');
          prevNode.classList.add('completed');
        }
        currentNodeIndex++;
        if (currentNodeIndex <= totalNodes) {
          let nextNode = document.getElementById(`log-node-${currentNodeIndex}`);
          if (nextNode) nextNode.classList.add('active');
        } else {
          clearInterval(timelineInterval);
        }
      }, 1200);


    document.querySelectorAll('.app-screen').forEach(screen => {
      screen.classList.remove('active');
    });

    const targetScreenEl = document.getElementById(`screen-${screenId}`);
    if (targetScreenEl) {
      targetScreenEl.classList.add('active');
      currentScreen = screenId;
      
      if (screenId === 'splash') {
        startCinematicSplash();
      }
    }
  }, isModuleScreen ? 450 : 0);
}

function goBackToPrevious() {
  if (screenHistory.length > 0) {
    const prev = screenHistory.pop();
    showScreen(prev, true);
  } else {
    showScreen('dashboard', true);
  }
}

function restartSplash() {
  showScreen('splash');
}

// Splash Screen Actions
function onSplashClick() {
  showScreen('login');
}

function startSplashLoader() {
  // Automatic loader disabled as per user request to move to login only on click.
}

function showSystemDiagnostics() {
  toggleDiagnosticsPopup(true);
}

function toggleDiagnosticsPopup(isOpen) {
  const popup = document.getElementById('diagnostics-popup');
  if (popup) {
    if (isOpen) popup.classList.add('active');
    else popup.classList.remove('active');
  }
}

function togglePasswordVisibility() {
  const pwdInput = document.getElementById('login-password');
  const icon = document.querySelector('.toggle-pwd');
  if (pwdInput.type === 'password') {
    pwdInput.type = 'text';
    icon.classList.remove('icon-eye');
    icon.classList.add('icon-eye-off');
  } else {
    pwdInput.type = 'password';
    icon.classList.remove('icon-eye-off');
    icon.classList.add('icon-eye');
  }
}

let webSocket = null;

function connectBackendWS(token) {
  if (webSocket) {
    try { webSocket.close(); } catch(e) {}
  }
  const wsUrl = `wss://robot-simulator.onrender.com/ws?token=${token}`;
  console.log("Connecting to WebSocket:", wsUrl);
  webSocket = new WebSocket(wsUrl);

  webSocket.onopen = () => {
    console.log("WebSocket connected to backend.");
    if (realtimePathTimer) {
      clearInterval(realtimePathTimer);
      realtimePathTimer = null;
    }
  };

  webSocket.onmessage = (event) => {
    try {
      const message = JSON.parse(event.data);
      if (message.type === 'TELEMETRY') {
        const robotId = message.robot_id;
        const r = robots.find(robot => {
          const matchR = robot.id.match(/\d+$/);
          const rSuffix = matchR ? parseInt(matchR[0]) : null;
          const matchMsg = robotId.toString().match(/\d+$/);
          const msgSuffix = matchMsg ? parseInt(matchMsg[0]) : null;
          return (rSuffix !== null && msgSuffix !== null && rSuffix === msgSuffix) || robot.id === robotId;
        });

        if (r) {
          r.status = message.online ? 'Online' : 'Offline';
          r.batteryLevel = message.battery;
          const x = message.position.x;
          const y = message.position.y;
          r.position = `${x.toFixed(2)}, ${y.toFixed(2)}`;
          r.angle = message.angle;
          r.lastActivity = message.current_task || 'Active';
          
          if (activeRobot && activeRobot.id === r.id) {
            realtimeTrail.push([x, y]);
            if (realtimeTrail.length > 35) realtimeTrail.shift();
            activeRobot = r;
            
            document.getElementById('viz-title').innerText = `Monitoring: ${r.name}`;
            const badge = document.getElementById('viz-status-badge');
            const isOnline = r.status === 'Online';
            badge.innerHTML = `<span class="status-monitor-dot ${isOnline ? 'green' : 'red'}" style="width: 6px; height: 6px; background-color: ${isOnline ? 'var(--app-success)' : 'var(--app-danger)'}; border-radius: 50%; display: inline-block; margin-right: 6px;"></span> ${r.status.toUpperCase()}`;
            badge.style.color = isOnline ? 'var(--app-success)' : 'var(--app-danger)';
            badge.style.background = isOnline ? 'rgba(34, 197, 94, 0.08)' : 'rgba(239, 68, 68, 0.08)';

            document.getElementById('hud-tracking-title').innerText = isManualOverride ? `Manual Override: ${r.name}` : `Active Tracking: ${r.name}`;
            document.getElementById('hud-tracking-desc').innerText = `GPS Latency: < 12ms | Coordinates: [${x.toFixed(2)}, ${y.toFixed(2)}]`;
            document.getElementById('monitor-battery').innerText = `${r.batteryLevel}%`;
            
            const batteryRing = document.getElementById('battery-ring');
            if (batteryRing) batteryRing.style.strokeDasharray = `${r.batteryLevel}, 100`;

            const velocityRing = document.getElementById('velocity-ring');
            const speedVal = isOnline ? (message.speed || 0.8) : 0.0;
            if (velocityRing) velocityRing.style.strokeDasharray = `${(speedVal / 2.0) * 100}, 100`;
            document.getElementById('monitor-speed').innerText = `${speedVal.toFixed(1)} m/s`;
            document.getElementById('monitor-direction').innerText = message.direction || 'Idle';

            const compassSvg = document.getElementById('heading-compass-svg');
            const shortText = document.getElementById('monitor-direction-short');
            if (compassSvg) compassSvg.style.transform = `rotate(${r.angle}deg)`;
            
            let shortDir = '--';
            if (isOnline) {
              const angleNorm = (message.angle % 360 + 360) % 360;
              if (angleNorm === 0) shortDir = 'N';
              else if (angleNorm === 45) shortDir = 'NE';
              else if (angleNorm === 90) shortDir = 'E';
              else if (angleNorm === 135) shortDir = 'SE';
              else if (angleNorm === 180) shortDir = 'S';
              else if (angleNorm === 225) shortDir = 'SW';
              else if (angleNorm === 270) shortDir = 'W';
              else if (angleNorm === 315) shortDir = 'NW';
            }
            if (shortText) shortText.innerText = shortDir;

            const timestamp = new Date().toTimeString().split(' ')[0];
            consoleLogs.push(`[${timestamp}] Telemetry: GPS [${x.toFixed(1)}, ${y.toFixed(1)}] | Battery: ${r.batteryLevel}%`);
            if (consoleLogs.length > 25) consoleLogs.shift();
            renderConsoleFeed();

            updateRobotAndTrailDOM();
          }
        }
      }
    } catch (err) {
      console.error("Error parsing WebSocket message:", err);
    }
  };

  webSocket.onclose = () => {
    console.log("WebSocket disconnected.");
    setTimeout(() => {
      if (localStorage.getItem('token')) {
        connectBackendWS(localStorage.getItem('token'));
      }
    }, 5000);
  };
}

function handleLoginSubmit(e) {
  e.preventDefault();
  const email = document.getElementById('login-email').value.trim().toLowerCase();
  const pass = document.getElementById('login-password').value.trim();
  const btn = document.getElementById('login-submit-btn');
  btn.innerHTML = `<i class="icon-loader spinner-icon"></i> <span>Authenticating...</span>`;
  btn.disabled = true;

  // Real HTTP POST login call to backend
  fetch(`https://robot-simulator.onrender.com/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ username: email, password: pass })
  })
  .then(res => {
    if (!res.ok) throw new Error('Invalid credentials');
    return res.json();
  })
  .then(data => {
    btn.innerHTML = `<span>Authenticate Operator</span>`;
    btn.disabled = false;
    
    const token = data.access_token;
    localStorage.setItem('token', token);
    connectBackendWS(token);

    // Set simulated admin mode depending on email used
    if (email === 'admin@blucursor.com') {
      isAdminSimMode = true;
      const adminToggle = document.getElementById('admin-mode-toggle');
      if (adminToggle) adminToggle.checked = true;
      toggleAdminSimMode({ checked: true });
      showToastNotification('Admin access granted. Welcome, Dr. Aryan Mehta.');
    } else {
      isAdminSimMode = false;
      const adminToggle = document.getElementById('admin-mode-toggle');
      if (adminToggle) adminToggle.checked = false;
      toggleAdminSimMode({ checked: false });
    }
    startBiometricScan();
  })
  .catch(err => {
    btn.innerHTML = `<span>Authenticate Operator</span>`;
    btn.disabled = false;
    showToastNotification('Access Denied: Invalid operator credentials!');
  });
}

function startBiometricScan() {
  showScreen('biometric');
  const logText = document.getElementById('biometric-loading-text');
  const bar = document.getElementById('biometric-progress-bar-fill');
  if (!logText || !bar) {
    showScreen('greeting');
    return;
  }

  const logs = [
    { text: "ESTABLISHING SECURE CONNECTION...", delay: 0 },
    { text: "INITIALIZING BIO-LINK MONITOR...", delay: 400 },
    { text: "SCANNING RETINAL PROFILE...", delay: 900 },
    { text: "BIOMETRICS MATCHED: OPERATOR CERTIFIED", delay: 1400 },
    { text: "SYNCING NEURAL ROUTER...", delay: 1900 },
    { text: "SYSTEM ONLINE. FLEET BEACON NOMINAL", delay: 2400 }
  ];

  bar.style.width = '0%';
  let progress = 0;

  // 3-second progress indicator (3000ms)
  const duration = 2800;
  const intervalTime = 30;
  const step = 100 / (duration / intervalTime);

  const progressInterval = setInterval(() => {
    progress += step;
    bar.style.width = `${Math.min(100, progress)}%`;
    if (progress >= 100) {
      clearInterval(progressInterval);
    }
  }, intervalTime);

  logs.forEach(item => {
    setTimeout(() => {
      if (currentScreen === 'biometric') {
        logText.innerText = item.text;
      }
    }, item.delay);
  });

  setTimeout(() => {
    if (currentScreen === 'biometric') {
      showScreen('greeting');
    }
  }, 3100);
}

function handleLogout() {
  const confirmLog = confirm("Are you sure you want to terminate operator session?");
  if (confirmLog) {
    localStorage.removeItem('token');
    if (webSocket) {
      try { webSocket.close(); } catch(e) {}
      webSocket = null;
    }
    showScreen('login');
  }
}

// Render Home Dashboard details
function renderDashboardHUD() {
  const avatar = document.getElementById('header-avatar');
  const name = document.getElementById('header-username');
  if (avatar && name) {
    if (isAdminSimMode) {
      avatar.innerText = 'AM';
      avatar.style.background = 'linear-gradient(135deg, #8b5cf6, #6d28d9)';
      name.innerText = 'Dr. Aryan Mehta';
    } else {
      avatar.innerText = 'JD';
      avatar.style.background = 'linear-gradient(135deg, #3b82f6, #1d4ed8)';
      name.innerText = 'John Doe';
    }
  }
}

// Popup robot reference
let deliveryPopupRobotId = null;
let patrolPopupRobotId = null;

// Helper to get robot dot offset inside the contain-fitted popup map preview
function getPopupDotOffset(x, y, W, H, mapImg) {
  const R = mapRatios[mapImg] || 0.7119;
  let w_img = W;
  let h_img = H;
  let dx = 0;
  let dy = 0;
  
  if (W / H > R) {
    h_img = H;
    w_img = H * R;
    dx = (W - w_img) / 2;
  } else {
    w_img = W;
    h_img = W / R;
    dy = (H - h_img) / 2;
  }
  
  const padding = 6;
  const px = dx + padding + (x / 25) * (w_img - padding * 2);
  const py = dy + padding + (y / 20) * (h_img - padding * 2);
  
  return {
    left: `${(px / W) * 100}%`,
    top: `${(py / H) * 100}%`
  };
}

// Show robot popup (for delivery or patrol card click)
function showRobotPopup(type, robotId, mapName) {
  const r = robots.find(robot => robot.id === robotId);
  if (!r) return;

  // Dynamically map layout/zone names to corresponding image files
  let mapImg = 'assets/map_6.png';
  
  activeMapImg = mapImg;
  
  if (type === 'delivery') {
    deliveryPopupRobotId = robotId;
    document.getElementById('delivery-popup-img').src = r.image;
    document.getElementById('delivery-popup-img').onerror = function() { this.src = 'assets/robot_splash.png'; };
    document.getElementById('delivery-popup-name').innerText = r.name;
    document.getElementById('delivery-popup-type').innerText = r.modelType;
    
    const statusEl = document.getElementById('delivery-popup-status');
    statusEl.innerText = r.status.toUpperCase();
    statusEl.className = `popup-badge ${r.status === 'Online' ? 'online' : 'offline'}`;
    
    document.getElementById('delivery-popup-battery').innerHTML = `<i class="icon-battery" style="font-size: 10px;"></i> ${r.batteryLevel}%`;
    document.getElementById('delivery-popup-map').innerText = mapName;
    document.getElementById('delivery-popup-coords').innerText = `[${r.position}]`;
    
    // Set popup preview map background image
    const previewEl = document.querySelector('#delivery-robot-popup .popup-map-preview');
    if (previewEl) {
      previewEl.style.backgroundImage = `url('${mapImg}')`;
      previewEl.style.backgroundSize = 'contain';
      previewEl.style.backgroundRepeat = 'no-repeat';
      previewEl.style.backgroundPosition = 'center';
    }

    // Show popup first so dimensions are non-zero
    document.getElementById('delivery-robot-popup').classList.add('active');

    // Place robot dot at relative position within visible containment bounds
    const parts = r.position.split(', ');
    const x = parseFloat(parts[0]);
    const y = parseFloat(parts[1]);
    const dotEl = document.getElementById('delivery-popup-dot');
    if (previewEl && dotEl) {
      const W = previewEl.clientWidth || 280;
      const H = previewEl.clientHeight || 100;
      const pos = getPopupDotOffset(x, y, W, H, mapImg);
      dotEl.style.left = pos.left;
      dotEl.style.top = pos.top;
    }
  } else if (type === 'patrol') {
    patrolPopupRobotId = robotId;
    document.getElementById('patrol-popup-img').src = r.image;
    document.getElementById('patrol-popup-img').onerror = function() { this.src = 'assets/robot_splash.png'; };
    document.getElementById('patrol-popup-name').innerText = r.name;
    document.getElementById('patrol-popup-type').innerText = r.modelType;
    
    const statusEl = document.getElementById('patrol-popup-status');
    statusEl.innerText = r.status.toUpperCase();
    statusEl.className = `popup-badge ${r.status === 'Online' ? 'online' : 'offline'}`;
    
    document.getElementById('patrol-popup-battery').innerHTML = `<i class="icon-battery" style="font-size: 10px;"></i> ${r.batteryLevel}%`;
    document.getElementById('patrol-popup-zone').innerText = mapName;
    document.getElementById('patrol-popup-coords').innerText = `[${r.position}]`;

    // Set popup preview map background image
    const previewEl = document.querySelector('#patrol-robot-popup .popup-map-preview');
    if (previewEl) {
      previewEl.style.backgroundImage = `url('${mapImg}')`;
      previewEl.style.backgroundSize = 'contain';
      previewEl.style.backgroundRepeat = 'no-repeat';
      previewEl.style.backgroundPosition = 'center';
    }
    
    // Show popup first so dimensions are non-zero
    document.getElementById('patrol-robot-popup').classList.add('active');
    
    const parts = r.position.split(', ');
    const x = parseFloat(parts[0]);
    const y = parseFloat(parts[1]);
    const dotEl = document.getElementById('patrol-popup-dot');
    if (previewEl && dotEl) {
      const W = previewEl.clientWidth || 280;
      const H = previewEl.clientHeight || 100;
      const pos = getPopupDotOffset(x, y, W, H, mapImg);
      dotEl.style.left = pos.left;
      dotEl.style.top = pos.top;
    }
  }
}

function closeRobotPopup(type) {
  if (type === 'delivery') {
    document.getElementById('delivery-robot-popup').classList.remove('active');
    deliveryPopupRobotId = null;
  } else if (type === 'patrol') {
    document.getElementById('patrol-robot-popup').classList.remove('active');
    patrolPopupRobotId = null;
  }
}

function openRobotMonitoringFromPopup(type) {
  const robotId = type === 'delivery' ? deliveryPopupRobotId : patrolPopupRobotId;
  closeRobotPopup(type);
  if (robotId) {
    bindRobotToMonitoring(robotId);
  }
}

// Render Delivery maps
function renderDeliveryMaps() {
  const listEl = document.getElementById('delivery-maps-list');
  const tableBodyEl = document.getElementById('delivery-table-body');
  if (!listEl || !tableBodyEl) return;
  
  // Read filter inputs
  const searchInput = document.getElementById('delivery-search-input');
  const statusFilter = document.getElementById('delivery-status-filter');
  
  const searchVal = searchInput ? searchInput.value.toLowerCase().trim() : '';
  const statusVal = statusFilter ? statusFilter.value : 'all';

  const maps = [
    { name: 'Floor Map A', subtitle: 'Ground Floor Logistics Hub', robot: robots[0] }, // Atlas (Forklift)
    { name: 'Floor Map B', subtitle: 'Second Floor Workspace', robot: robots[4] }, // Vega (Sorter Bot)
    { name: 'Floor Map C', subtitle: 'Third Floor Office Wing', robot: robots[2] }, // Nova (Heavy Mover)
    { name: 'Floor Map D', subtitle: 'Fourth Floor Executive Hub', robot: null },  // Standby
    { name: 'Floor Map E', subtitle: 'Basement Storage Area', robot: null }
  ];

  // Filter
  const filteredMaps = maps.filter(map => {
    const r = map.robot;
    const matchesSearch = map.name.toLowerCase().includes(searchVal) || 
                          map.subtitle.toLowerCase().includes(searchVal) || 
                          (r && r.name.toLowerCase().includes(searchVal));
                          
    let matchesStatus = true;
    if (statusVal === 'online') {
      matchesStatus = r && r.status === 'Online';
    } else if (statusVal === 'offline') {
      matchesStatus = r && r.status === 'Offline';
    } else if (statusVal === 'standby') {
      matchesStatus = !r;
    }
    
    return matchesSearch && matchesStatus;
  });

  listEl.innerHTML = '';
  tableBodyEl.innerHTML = '';

  if (filteredMaps.length === 0) {
    const emptyMsg = `<div class="app-card" style="text-align: center; color: var(--app-text-muted); padding: 24px; width: 100%;">No matching layouts found.</div>`;
    listEl.innerHTML = emptyMsg;
    tableBodyEl.innerHTML = `<tr><td colspan="4" style="text-align: center; color: var(--app-text-muted); padding: 24px;">No matching layouts found.</td></tr>`;
    return;
  }

  filteredMaps.forEach(map => {
    const r = map.robot;
    
    let statusText = r ? r.status : 'Standby';
    let statusClass = r ? (r.status === 'Online' ? 'success' : 'danger') : 'secondary';
    let batteryText = r ? `${r.batteryLevel}%` : '--%';
    let lastActivityText = r ? r.lastActivity : 'Awaiting assignment';
    const robotImg = r ? r.image : 'assets/robot_splash.png';

    // 1. Render Card View - now opens popup
    const card = document.createElement('div');
    const cardStatusClass = r ? (r.status === 'Online' ? 'active' : 'offline') : 'idle';
    card.className = `asset-card-upgraded status-${cardStatusClass}`;
    card.onclick = () => {
      const active = r ? r : robots[0];
      showRobotPopup('delivery', active.id, map.name);
    };
    
    // Virtual Signal Strength calculation
    const signalStrength = r ? (r.status === 'Online' ? '96% (Exc)' : '0%') : '--';
    const batteryPercent = r ? r.batteryLevel : 0;
    
    card.innerHTML = `
      <!-- Top section -->
      <div class="new-card-top">
        <div class="new-robot-thumb-container">
          <img class="new-robot-thumb" src="${robotImg}" onerror="this.src='assets/robot_splash.png'">
        </div>
        <div class="new-card-meta">
          <div class="new-card-id-row">
            <span class="new-robot-id">${r ? r.id : 'RB-XXX'}</span>
            <span class="new-status-badge badge-${statusClass}">${statusText.toUpperCase()}</span>
          </div>
          <div class="new-robot-model">${r ? r.modelType : 'Standard Unit'}</div>
          <div class="new-robot-name">Node: ${r ? r.name : 'Standby'}</div>
        </div>
      </div>
      
      <!-- Info Grid section -->
      <div class="new-card-grid">
        <div class="grid-item battery-section">
          <div class="grid-label">BATTERY</div>
          <div class="battery-percent-row">
            <i class="icon-battery"></i>
            <span>${batteryText}</span>
          </div>
          <div class="mini-battery-bar">
            <div class="mini-battery-fill bar-${statusClass}" style="width: ${batteryPercent}%"></div>
          </div>
        </div>
        <div class="grid-item location-section">
          <div class="grid-label">LOCATION</div>
          <div class="location-value-row">
            <i class="icon-map-pin"></i>
            <span class="truncate">${map.name}</span>
          </div>
          <div class="grid-subtext truncate">${map.subtitle}</div>
        </div>
        <div class="grid-item active-section">
          <div class="grid-label">LAST ACTIVE</div>
          <div class="active-value-row">
            <i class="icon-clock"></i>
            <span>${lastActivityText === 'Active now' ? '1m ago' : (lastActivityText === 'Moving cargo' ? '2m ago' : '4h ago')}</span>
          </div>
          <div class="grid-subtext">Signal: ${signalStrength}</div>
        </div>
      </div>

      <!-- Action buttons section -->
      <div class="new-card-actions" onclick="event.stopPropagation()">
        <button class="new-action-btn btn-view" onclick="event.stopPropagation(); showRobotPopup('delivery', '${r ? r.id : 'RB-001'}', '${map.name}')">
          <i class="icon-map-pin"></i> View Details
        </button>
      </div>
    `;
    listEl.appendChild(card);

    // 2. Render Table View Row
    const tr = document.createElement('tr');
    tr.onclick = () => {
      const active = r ? r : robots[0];
      showRobotPopup('delivery', active.id, map.name);
    };
    tr.innerHTML = `
      <td>
        <div class="table-robot-badge">
          <img src="${robotImg}" onerror="this.src='assets/robot_splash.png'">
          <div>
            <strong style="display:block; font-size:12.5px;">${map.name}</strong>
            <span style="font-size:10.8px; color:var(--app-text-muted); font-weight:500;">${r ? r.name : 'Unassigned'}</span>
          </div>
        </div>
      </td>
      <td>
        <span class="badge-status status-${statusClass}">${statusText.toUpperCase()}</span>
      </td>
      <td>
        <span class="battery-text" style="font-size:12px; font-weight:700;"><i class="icon-battery" style="font-size:13px; vertical-align:middle; margin-right:2px;"></i> ${batteryText}</span>
      </td>
      <td>
        <span style="font-size:11px; color:var(--app-text-muted); font-weight:500;">${lastActivityText}</span>
      </td>
    `;
    tableBodyEl.appendChild(tr);
  });
}

// Render Patrol zones
function renderPatrolZones() {
  const listEl = document.getElementById('patrol-zones-list');
  const tableBodyEl = document.getElementById('patrol-table-body');
  if (!listEl || !tableBodyEl) return;

  // Read filter inputs
  const searchInput = document.getElementById('patrol-search-input');
  const statusFilter = document.getElementById('patrol-status-filter');
  
  const searchVal = searchInput ? searchInput.value.toLowerCase().trim() : '';
  const statusVal = statusFilter ? statusFilter.value : 'all';

  const zones = [
    { name: 'Patrol Zone A', subtitle: 'Conf Room Area', robot: robots[1] }, // Titan (Delivery Unit - Patrol)
    { name: 'Patrol Zone B', subtitle: 'Server Room Corridor', robot: robots[3] }, // Orion (LIDAR Scanner - Patrol)
    { name: 'Patrol Zone C', subtitle: 'Break Room Wing', robot: null },  // Standby
    { name: 'Patrol Zone D', subtitle: 'Executive Suite Outer Ring', robot: robots[1] }, // Titan
    { name: 'Patrol Zone E', subtitle: 'Loading Bay Patrol', robot: robots[3] } // Orion
  ];

  // Filter
  const filteredZones = zones.filter(zone => {
    const r = zone.robot;
    const matchesSearch = zone.name.toLowerCase().includes(searchVal) || 
                          zone.subtitle.toLowerCase().includes(searchVal) || 
                          (r && r.name.toLowerCase().includes(searchVal));
                          
    let matchesStatus = true;
    if (statusVal === 'online') {
      matchesStatus = r && r.status === 'Online';
    } else if (statusVal === 'offline') {
      matchesStatus = r && r.status === 'Offline';
    } else if (statusVal === 'standby') {
      matchesStatus = !r;
    }
    
    return matchesSearch && matchesStatus;
  });

  listEl.innerHTML = '';
  tableBodyEl.innerHTML = '';

  if (filteredZones.length === 0) {
    const emptyMsg = `<div class="app-card" style="text-align: center; color: var(--app-text-muted); padding: 24px; width: 100%;">No matching zones found.</div>`;
    listEl.innerHTML = emptyMsg;
    tableBodyEl.innerHTML = `<tr><td colspan="4" style="text-align: center; color: var(--app-text-muted); padding: 24px;">No matching zones found.</td></tr>`;
    return;
  }

  filteredZones.forEach(zone => {
    const r = zone.robot;
    
    let statusText = r ? r.status : 'Standby';
    let statusClass = r ? (r.status === 'Online' ? 'success' : 'danger') : 'secondary';
    let batteryText = r ? `${r.batteryLevel}%` : '--%';
    let lastActivityText = r ? r.lastActivity : 'Awaiting patrol task';
    const robotImg = r ? r.image : 'assets/robot_splash.png';

    // 1. Render Card View - now opens popup
    const card = document.createElement('div');
    const cardStatusClass = r ? (r.status === 'Online' ? 'active' : 'offline') : 'idle';
    card.className = `asset-card-upgraded status-${cardStatusClass}`;
    card.onclick = () => {
      const active = r ? r : robots[1];
      showRobotPopup('patrol', active.id, zone.name);
    };
    
    // Virtual Signal Strength calculation
    const signalStrength = r ? (r.status === 'Online' ? '92% (Good)' : '0%') : '--';
    const batteryPercent = r ? r.batteryLevel : 0;
    
    card.innerHTML = `
      <!-- Top section -->
      <div class="new-card-top">
        <div class="new-robot-thumb-container">
          <img class="new-robot-thumb" src="${robotImg}" onerror="this.src='assets/robot_splash.png'">
        </div>
        <div class="new-card-meta">
          <div class="new-card-id-row">
            <span class="new-robot-id">${r ? r.id : 'RB-XXX'}</span>
            <span class="new-status-badge badge-${statusClass}">${statusText.toUpperCase()}</span>
          </div>
          <div class="new-robot-model">${r ? r.modelType : 'Standard Unit'}</div>
          <div class="new-robot-name">Node: ${r ? r.name : 'Standby'}</div>
        </div>
      </div>
      
      <!-- Info Grid section -->
      <div class="new-card-grid">
        <div class="grid-item battery-section">
          <div class="grid-label">BATTERY</div>
          <div class="battery-percent-row">
            <i class="icon-battery"></i>
            <span>${batteryText}</span>
          </div>
          <div class="mini-battery-bar">
            <div class="mini-battery-fill bar-${statusClass}" style="width: ${batteryPercent}%"></div>
          </div>
        </div>
        <div class="grid-item location-section">
          <div class="grid-label">LOCATION</div>
          <div class="location-value-row">
            <i class="icon-map-pin"></i>
            <span class="truncate">${zone.name}</span>
          </div>
          <div class="grid-subtext truncate">${zone.subtitle}</div>
        </div>
        <div class="grid-item active-section">
          <div class="grid-label">LAST ACTIVE</div>
          <div class="active-value-row">
            <i class="icon-clock"></i>
            <span>${lastActivityText === 'Active now' ? '1m ago' : (lastActivityText === 'Scanning area' ? '2m ago' : '4h ago')}</span>
          </div>
          <div class="grid-subtext">Signal: ${signalStrength}</div>
        </div>
      </div>

      <!-- Action buttons section -->
      <div class="new-card-actions" onclick="event.stopPropagation()">
        <button class="new-action-btn btn-view" onclick="event.stopPropagation(); showRobotPopup('patrol', '${r ? r.id : 'RB-004'}', '${zone.name}')">
          <i class="icon-map-pin"></i> View Details
        </button>
      </div>
    `;
    listEl.appendChild(card);

    // 2. Render Table View Row
    const tr = document.createElement('tr');
    tr.onclick = () => {
      const active = r ? r : robots[3];
      showRobotPopup('patrol', active.id, zone.name);
    };
    tr.innerHTML = `
      <td>
        <div class="table-robot-badge">
          <img src="${robotImg}" onerror="this.src='assets/robot_splash.png'">
          <div>
            <strong style="display:block; font-size:12.5px;">${zone.name}</strong>
            <span style="font-size:10.8px; color:var(--app-text-muted); font-weight:500;">${r ? r.name : 'Unassigned'}</span>
          </div>
        </div>
      </td>
      <td>
        <span class="badge-status status-${statusClass}">${statusText.toUpperCase()}</span>
      </td>
      <td>
        <span class="battery-text" style="font-size:12px; font-weight:700;"><i class="icon-battery" style="font-size:13px; vertical-align:middle; margin-right:2px;"></i> ${batteryText}</span>
      </td>
      <td>
        <span style="font-size:11px; color:var(--app-text-muted); font-weight:500;">${lastActivityText}</span>
      </td>
    `;
    tableBodyEl.appendChild(tr);
  });
}

// Global Zoom, Camera control, and Sensor Simulation states
let mapZoom = 1.0;
let cameraPitch = 0;
let cameraYaw = 0;
let isCameraNightVision = false;

function adjustMapZoom(delta) {
  mapZoom = Math.max(0.75, Math.min(1.75, mapZoom + delta * 0.15));
  const robotEl = document.getElementById('viz-moving-robot');
  if (robotEl) {
    robotEl.style.transform = `translate(-50%, -50%) rotate(${activeRobot.angle}deg) scale(${mapZoom})`;
  }
  showToastNotification(`Map display zoom: ${(mapZoom * 100).toFixed(0)}%`);
}

function adjustCameraAngle(axis, delta) {
  if (activeRobot.status !== 'Online') {
    showToastNotification("Camera feed link offline.");
    return;
  }
  if (axis === 'pitch') {
    cameraPitch = Math.max(-45, Math.min(45, cameraPitch + delta * 5));
  } else if (axis === 'yaw') {
    cameraYaw = Math.max(-90, Math.min(90, cameraYaw + delta * 10));
  }
  document.getElementById('camera-overlay-angle').innerText = `CAM PITCH: ${cameraPitch}° | YAW: ${cameraYaw}°`;
  showToastNotification(`Camera ${axis} adjusted.`);
}

function toggleCameraNightVision() {
  if (activeRobot.status !== 'Online') {
    showToastNotification("Camera feed link offline.");
    return;
  }
  isCameraNightVision = !isCameraNightVision;
  const viewport = document.getElementById('cameraFeedViewport');
  if (viewport) {
    viewport.classList.toggle('night-vision', isCameraNightVision);
  }
  showToastNotification(isCameraNightVision ? "IR Night Vision enabled." : "Night Vision disabled.");
}

// Bind robot data and navigate to monitoring screen
function bindRobotToMonitoring(robotId, mapImg) {
  const r = robots.find(robot => robot.id === robotId);
  if (!r) return;
  activeRobot = r;

  // Set the map viewport background dynamically using the corresponding floor plan
  if (!mapImg) {
    mapImg = activeMapImg || 'assets/map_1.png';
  }
  const mapViewport = document.querySelector('.viz-map-viewport');
  if (mapViewport) {
    mapViewport.style.backgroundImage = `url('${mapImg}')`;
    mapViewport.style.backgroundSize = 'contain';
    mapViewport.style.backgroundRepeat = 'no-repeat';
    mapViewport.style.backgroundPosition = 'center';
  }

  // Set fields on monitoring page
  document.getElementById('viz-title').innerText = `Monitoring: ${r.name}`;
  const badge = document.getElementById('viz-status-badge');
  const isOnline = r.status === 'Online';
  badge.innerHTML = `<span class="status-monitor-dot ${isOnline ? 'green' : 'red'}" style="width: 6px; height: 6px; background-color: ${isOnline ? 'var(--app-success)' : 'var(--app-danger)'}; border-radius: 50%; display: inline-block; margin-right: 6px;"></span> ${r.status.toUpperCase()}`;
  badge.style.color = isOnline ? 'var(--app-success)' : 'var(--app-danger)';
  badge.style.background = isOnline ? 'rgba(34, 197, 94, 0.08)' : 'rgba(239, 68, 68, 0.08)';

  document.getElementById('hud-tracking-title').innerText = `Active Tracking: ${r.name}`;
  document.getElementById('monitor-battery').innerText = `${r.batteryLevel}%`;
  
  // Update battery ring dasharray
  const batteryRing = document.getElementById('battery-ring');
  if (batteryRing) batteryRing.style.strokeDasharray = `${r.batteryLevel}, 100`;

  // Update velocity ring dasharray
  const velocityRing = document.getElementById('velocity-ring');
  const speedVal = isOnline ? 0.8 : 0.0;
  if (velocityRing) velocityRing.style.strokeDasharray = `${(speedVal / 2.0) * 100}, 100`;

  // Reset Map Zoom and Camera Zoom states
  mapZoom = 1.0;
  cameraPitch = 0;
  cameraYaw = 0;
  isCameraNightVision = false;
  
  // Sync Camera and Zoom DOM UI elements
  const movingRobot = document.getElementById('viz-moving-robot');
  if (movingRobot) movingRobot.style.transform = `translate(-50%, -50%) rotate(${r.angle}deg) scale(1)`;
  
  const camOverlayAngle = document.getElementById('camera-overlay-angle');
  if (camOverlayAngle) camOverlayAngle.innerText = `CAM PITCH: 0° | YAW: 0°`;
  
  const camViewport = document.getElementById('cameraFeedViewport');
  if (camViewport) camViewport.classList.remove('night-vision');
  
  // Bind camera feed picture to robot visual avatar
  const camPic = document.getElementById('cameraVideoMock');
  if (camPic) {
    camPic.src = r.image;
    camPic.style.opacity = isOnline ? '0.65' : '0.15';
  }

  // Update Floating Mission Info Panel
  const isPatrol = r.id === 'RB-004' || r.id === 'RB-003' || r.modelType.includes('LIDAR') || r.modelType.includes('Surveyor');
  document.getElementById('mission-task-name').innerText = isPatrol ? 'Surveillance' : 'Cargo Logistics';
  document.getElementById('mission-eta').innerText = isOnline ? '2m 14s' : 'Halted';
  document.getElementById('mission-dist').innerText = isOnline ? '18.2m' : '0.0m';
  
  const missionBar = document.getElementById('mission-progress-fill-bar');
  if (missionBar) {
    missionBar.style.animation = isOnline ? 'missionSimProgress 12s infinite linear' : 'none';
    missionBar.style.width = isOnline ? '55%' : '0%';
  }

  // Set Sensor Grid indicators and texts
  const lidarInd = document.getElementById('sensor-ind-lidar');
  const sonarInd = document.getElementById('sensor-ind-sonar');
  const imuInd = document.getElementById('sensor-ind-imu');
  const avoidInd = document.getElementById('sensor-ind-avoid');

  const lidarVal = document.getElementById('sensor-val-lidar');
  const sonarVal = document.getElementById('sensor-val-sonar');
  const imuVal = document.getElementById('sensor-val-imu');
  const avoidVal = document.getElementById('sensor-val-avoid');

  if (lidarInd && sonarInd && imuInd && avoidInd) {
    lidarInd.className = `sensor-status-indicator ${isOnline ? '' : 'offline'}`;
    sonarInd.className = `sensor-status-indicator ${isOnline ? '' : 'offline'}`;
    imuInd.className = `sensor-status-indicator ${isOnline ? '' : 'offline'}`;
    avoidInd.className = `sensor-status-indicator ${isOnline ? '' : 'offline'}`;
  }

  if (lidarVal && sonarVal && imuVal && avoidVal) {
    lidarVal.innerText = isOnline ? 'Active (360°)' : 'Offline';
    sonarVal.innerText = isOnline ? '0.4m Range' : 'Standby';
    imuVal.innerText = isOnline ? 'Stabilized' : 'Halted';
    avoidVal.innerText = isOnline ? 'Clear' : 'Error';
  }

  // Update heading compass rotation and short direction text
  const compassSvg = document.getElementById('heading-compass-svg');
  const shortText = document.getElementById('monitor-direction-short');
  if (compassSvg) compassSvg.style.transform = `rotate(${r.angle}deg)`;

  let shortDir = '--';
  if (isOnline) {
    if (r.angle === 0) shortDir = 'N';
    else if (r.angle === 45) shortDir = 'NE';
    else if (r.angle === 90) shortDir = 'E';
    else if (r.angle === 125 || r.angle === 135) shortDir = 'SE';
    else if (r.angle === 180) shortDir = 'S';
    else if (r.angle === 225) shortDir = 'SW';
    else if (r.angle === 270) shortDir = 'W';
    else if (r.angle === 315) shortDir = 'NW';
  }
  if (shortText) shortText.innerText = shortDir;

  // Clear Console logs
  const consoleEl = document.getElementById('monitor-console');
  consoleEl.innerHTML = '';
  consoleLogs = [
    `[SYS] Telemetry link established for ${r.name}`,
    `[SYS] GPS coords initialized at [${r.position}]`
  ];
  if (!isOnline) {
    consoleLogs.push(`[WARN] Robot is offline. Manual overrides locked.`);
    document.getElementById('monitor-speed').innerText = `0.0 m/s`;
    document.getElementById('monitor-direction').innerText = `Idle`;
  } else {
    document.getElementById('monitor-speed').innerText = `0.8 m/s`;
    document.getElementById('monitor-direction').innerText = `North-East`;
  }
  
  renderConsoleFeed();
  triggerSplitTransition('real_time_viz', r);
}

function renderConsoleFeed() {
  const consoleEl = document.getElementById('monitor-console');
  if (!consoleEl) return;
  consoleEl.innerHTML = '';
  
  consoleLogs.forEach(log => {
    const row = document.createElement('div');
    row.style.display = 'flex';
    row.style.alignItems = 'flex-start';
    row.style.marginBottom = '6px';
    row.style.fontSize = '11px';
    
    // Extract timestamp if present
    let time = '';
    let text = log;
    const match = log.match(/^\[([\d:]+)\]\s*(.*)/);
    if (match) {
      time = match[1];
      text = match[2];
    } else {
      time = new Date().toTimeString().split(' ')[0];
    }
    
    let color = 'var(--app-primary)';
    if (log.includes('ALERT') || log.includes('WARN') || log.includes('EMERGENCY')) {
      color = 'var(--app-danger)';
    } else if (log.includes('CMD')) {
      color = 'var(--app-accent)';
    } else if (log.includes('reached') || log.includes('initialized') || log.includes('link')) {
      color = 'var(--app-success)';
    }
    
    row.innerHTML = `
      <div style="min-width: 54px; color: #94a3b8; font-size: 10px; font-weight: 500; font-family: monospace; margin-top: 1px;">${time}</div>
      <div style="display: flex; flex-direction: column; align-items: center; margin: 0 8px; height: 100%;">
        <div style="width: 6px; height: 6px; border-radius: 50%; background-color: ${color}; box-shadow: 0 0 4px ${color}; margin-top: 4px;"></div>
      </div>
      <div style="color: #f8fafc; font-weight: 500; font-family: system-ui, -apple-system, sans-serif; line-height: 1.3; flex-grow: 1;">${text}</div>
    `;
    consoleEl.appendChild(row);
  });
  consoleEl.scrollTop = consoleEl.scrollHeight;
}

// Real-time autonomous map route positioning simulation
// Global variable for manual override state
let isManualOverride = false;

// Helper to translate virtual coordinates to map viewport pixel coordinates
function getPixelOffset(x, y) {
  const viewport = document.querySelector('.viz-map-viewport');
  if (!viewport) return { px: 0, py: 0 };
  const W = viewport.clientWidth;
  const H = viewport.clientHeight;
  
  const mapImg = activeMapImg || 'assets/map_1.png';
  const R = mapRatios[mapImg] || 0.7119;
  
  let w_img = W;
  let h_img = H;
  let dx = 0;
  let dy = 0;
  
  if (W / H > R) {
    // Viewport is wider than image (height-limited)
    h_img = H;
    w_img = H * R;
    dx = (W - w_img) / 2;
  } else {
    // Viewport is taller than image (width-limited)
    w_img = W;
    h_img = W / R;
    dy = (H - h_img) / 2;
  }
  
  const padding = 12;
  const px = dx + padding + (x / 25) * (w_img - padding * 2);
  const py = dy + padding + (y / 20) * (h_img - padding * 2);
  return { px, py };
}

// Function to update the robot marker and SVG trail elements in the DOM dynamically
function updateRobotAndTrailDOM() {
  if (currentScreen !== 'real_time_viz') return;
  const mapRobot = document.getElementById('viz-moving-robot');
  const svgTrail = document.querySelector('#viz-trail-svg polyline');
  if (!mapRobot) return;

  const parts = activeRobot.position.split(/,\s*/);
  let x = parseFloat(parts[0]);
  let y = parseFloat(parts[1]);
  if (isNaN(x) || isNaN(y)) {
    x = 12.5;
    y = 10.0;
  }
  const angle = activeRobot.angle;

  const coords = getPixelOffset(x, y);
  
  // Set position in pixels
  mapRobot.style.left = `${coords.px}px`;
  mapRobot.style.top = `${coords.py}px`;
  mapRobot.style.transform = `translate(-50%, -50%) rotate(${angle}deg)`;

  // Draw SVG Trail using pixel points
  if (svgTrail) {
    if (activeRobot.status !== 'Online' || realtimeTrail.length < 2) {
      if (realtimeTrail.length > 0) {
        const startOffset = getPixelOffset(realtimeTrail[0][0], realtimeTrail[0][1]);
        svgTrail.setAttribute('points', `${startOffset.px},${startOffset.py}`);
      } else {
        svgTrail.setAttribute('points', '');
      }
    } else {
      const pointsStr = realtimeTrail.map(c => {
        const offset = getPixelOffset(c[0], c[1]);
        return `${offset.px},${offset.py}`;
      }).join(' ');
      svgTrail.setAttribute('points', pointsStr);
    }
  }
}

// Re-render when browser window resizes
window.addEventListener('resize', () => {
  if (currentScreen === 'real_time_viz') {
    updateRobotAndTrailDOM();
  }
});

// Real-time autonomous map route positioning simulation
function startRealtimeSimulation() {
  if (realtimePathTimer) clearInterval(realtimePathTimer);
  realtimeTrail = [];
  isManualOverride = false;
  realtimePathIndex = 0;

  const resumeContainer = document.getElementById('resume-autonav-container');
  if (resumeContainer) resumeContainer.style.display = 'none';

  // Parse initial position
  const parts = activeRobot.position.split(/,\s*/);
  let startX = parseFloat(parts[0]);
  let startY = parseFloat(parts[1]);
  if (isNaN(startX) || isNaN(startY)) {
    startX = 12.5;
    startY = 10.0;
  }
  realtimeTrail.push([startX, startY]);

  // If WebSocket is connected, let backend handle telemetry
  if (webSocket && webSocket.readyState === WebSocket.OPEN) {
    updateRobotAndTrailDOM();
    return;
  }

  // Snap active robot to start of route loop to avoid sudden jumping paths
  if (activeRobot.status === 'Online') {
    activeRobot.position = `${routePath[0][0]}, ${routePath[0][1]}`;
    activeRobot.angle = routePath[0][2];
    realtimeTrail[0] = [routePath[0][0], routePath[0][1]];
  }

  // Draw initial position immediately
  updateRobotAndTrailDOM();
  setTimeout(updateRobotAndTrailDOM, 50);
  setTimeout(updateRobotAndTrailDOM, 200);
  setTimeout(updateRobotAndTrailDOM, 500);

  if (activeRobot.status !== 'Online') {
    return;
  }

  realtimePathTimer = setInterval(() => {
    if (currentScreen !== 'real_time_viz' || activeRobot.status === 'E-STOPPED') {
      clearInterval(realtimePathTimer);
      return;
    }

    // Stopped automatic movement - position and angle do not update automatically.
    // They only update when manual D-pad buttons are pressed or held.
    const parts = activeRobot.position.split(/,\s*/);
    let x = parseFloat(parts[0]);
    let y = parseFloat(parts[1]);
    if (isNaN(x) || isNaN(y)) {
      x = 12.5;
      y = 10.0;
    }
    const angle = activeRobot.angle;
    const pt = [x, y, angle];
    
    // We still update the robot trail visually (it starts with the initial point)
    updateRobotAndTrailDOM();

    // Update HUD metrics
    document.getElementById('hud-tracking-desc').innerText = `GPS Latency: < 12ms | Coordinates: [${pt[0].toFixed(2)}, ${pt[1].toFixed(2)}]`;
    
    const randomBat = Math.max(10, activeRobot.batteryLevel - 1);
    activeRobot.batteryLevel = randomBat;
    document.getElementById('monitor-battery').innerText = `${randomBat}%`;
    
    // Update battery ring
    const batteryRing = document.getElementById('battery-ring');
    if (batteryRing) batteryRing.style.strokeDasharray = `${randomBat}, 100`;

    // Update velocity ring
    const velocityRing = document.getElementById('velocity-ring');
    if (velocityRing) velocityRing.style.strokeDasharray = `${(0.8 / 2.0) * 100}, 100`;

    // Update heading compass rotation and short direction text
    const compassSvg = document.getElementById('heading-compass-svg');
    const shortText = document.getElementById('monitor-direction-short');
    if (compassSvg) compassSvg.style.transform = `rotate(${pt[2]}deg)`;

    let shortDir = '--';
    let directionText = 'Idle';
    if (angle === 0) { directionText = 'North'; shortDir = 'N'; }
    else if (angle === 45) { directionText = 'North-East'; shortDir = 'NE'; }
    else if (angle === 90) { directionText = 'East'; shortDir = 'E'; }
    else if (angle === 125 || angle === 135) { directionText = 'South-East'; shortDir = 'SE'; }
    else if (angle === 180) { directionText = 'South'; shortDir = 'S'; }
    else if (angle === 225) { directionText = 'South-West'; shortDir = 'SW'; }
    else if (angle === 270) { directionText = 'West'; shortDir = 'W'; }
    else if (angle === 315) { directionText = 'North-West'; shortDir = 'NW'; }

    if (shortText) shortText.innerText = shortDir;
    document.getElementById('monitor-direction').innerText = directionText;

    const timestamp = new Date().toTimeString().split(' ')[0];
    consoleLogs.push(`[${timestamp}] GPS Coords: [${pt[0].toFixed(1)}, ${pt[1].toFixed(1)}]`);
    if (consoleLogs.length > 25) consoleLogs.shift();
    renderConsoleFeed();
  }, 1800);
}

// Remote Manual Override controls
function sendRemoteCmd(cmdName, dx, dy) {
  if (activeRobot.status !== 'Online') return;

  if (webAutoNavActive) {
    stopWebAutoNav();
  }

  // Send command to backend WebSocket if connected
  if (webSocket && webSocket.readyState === WebSocket.OPEN) {
    const matchR = activeRobot.id.match(/\d+$/);
    const intId = matchR ? parseInt(matchR[0]) : 1;
    
    let command = "forward";
    if (dx === 0 && dy < 0) command = "forward";
    else if (dx === 0 && dy > 0) command = "backward";
    else if (dx < 0 && dy === 0) command = "rotate_left";
    else if (dx > 0 && dy === 0) command = "rotate_right";

    webSocket.send(JSON.stringify({
      type: "MOVE",
      robot_id: activeRobot.id, // Backend supports string IDs now
      payload: {
        command: command
      }
    }));

    isManualOverride = true;
    const resumeContainer = document.getElementById('resume-autonav-container');
    if (resumeContainer) resumeContainer.style.display = 'block';
    document.getElementById('hud-tracking-title').innerText = `Manual Override: ${activeRobot.name}`;
    return;
  }

  const timestamp = new Date().toTimeString().split(' ')[0];
  
  // Activate manual override
  isManualOverride = true;
  const resumeContainer = document.getElementById('resume-autonav-container');
  if (resumeContainer) resumeContainer.style.display = 'block';
  document.getElementById('hud-tracking-title').innerText = `Manual Override: ${activeRobot.name}`;

  // Calculate new position
  let parts = activeRobot.position.split(/,\s*/);
  let x = parseFloat(parts[0]);
  let y = parseFloat(parts[1]);
  if (isNaN(x) || isNaN(y)) {
    x = 12.5;
    y = 10.0;
  }
  x = x + dx * 0.8;
  y = y + dy * 0.8;
  
  let deg = activeRobot.angle;
  if (dx > 0) deg = 90;
  else if (dx < 0) deg = 270;
  else if (dy > 0) deg = 180;
  else if (dy < 0) deg = 0;
  activeRobot.angle = deg;
  
  x = Math.max(2, Math.min(23, x));
  y = Math.max(2, Math.min(18, y));
  activeRobot.position = `${x.toFixed(1)}, ${y.toFixed(1)}`;

  realtimeTrail.push([x, y]);
  if (realtimeTrail.length > 35) {
    realtimeTrail.shift();
  }

  updateRobotAndTrailDOM();

  // Update compass needle rotation
  const compassSvg = document.getElementById('heading-compass-svg');
  if (compassSvg) compassSvg.style.transform = `rotate(${deg}deg)`;

  // Update HUD metrics
  document.getElementById('hud-tracking-desc').innerText = `GPS Latency: < 12ms | Coordinates: [${x.toFixed(2)}, ${y.toFixed(2)}]`;
  document.getElementById('monitor-speed').innerText = `0.8 m/s`;
  
  // Update velocity ring
  const velocityRing = document.getElementById('velocity-ring');
  if (velocityRing) velocityRing.style.strokeDasharray = `${(0.8 / 2.0) * 100}, 100`;

  // Normalize angle to [0, 360)
  let normAngle = (deg % 360 + 360) % 360;
  let dir = 'Idle';
  let shortDir = '--';
  
  if (normAngle >= 337.5 || normAngle < 22.5) {
    dir = 'North';
    shortDir = 'N';
  } else if (normAngle >= 22.5 && normAngle < 67.5) {
    dir = 'North-East';
    shortDir = 'NE';
  } else if (normAngle >= 67.5 && normAngle < 112.5) {
    dir = 'East';
    shortDir = 'E';
  } else if (normAngle >= 112.5 && normAngle < 157.5) {
    dir = 'South-East';
    shortDir = 'SE';
  } else if (normAngle >= 157.5 && normAngle < 202.5) {
    dir = 'South';
    shortDir = 'S';
  } else if (normAngle >= 202.5 && normAngle < 247.5) {
    dir = 'South-West';
    shortDir = 'SW';
  } else if (normAngle >= 247.5 && normAngle < 292.5) {
    dir = 'West';
    shortDir = 'W';
  } else if (normAngle >= 292.5 && normAngle < 337.5) {
    dir = 'North-West';
    shortDir = 'NW';
  }

  document.getElementById('monitor-direction').innerText = dir;

  const shortText = document.getElementById('monitor-direction-short');
  if (shortText) shortText.innerText = shortDir;

  consoleLogs.push(`[${timestamp}] CMD: Manual Override -> ${cmdName}`);
  if (consoleLogs.length > 25) consoleLogs.shift();
  renderConsoleFeed();
}

function rotateRobot() {
  if (activeRobot.status !== 'Online') return;
  
  if (webAutoNavActive) {
    stopWebAutoNav();
  }
  
  isManualOverride = true;
  const resumeContainer = document.getElementById('resume-autonav-container');
  if (resumeContainer) resumeContainer.style.display = 'block';
  document.getElementById('hud-tracking-title').innerText = `Manual Override: ${activeRobot.name}`;

  const mapRobot = document.getElementById('viz-moving-robot');
  if (mapRobot) {
    if (mapRobot.classList.contains('spinning')) return;
    
    mapRobot.classList.add('spinning');
    const currentAngle = activeRobot.angle;
    const targetAngle = (currentAngle + 180) % 360;
    
    // Set smooth transition on the robot dot
    mapRobot.style.transition = 'transform 1.2s cubic-bezier(0.25, 1, 0.5, 1), left 0.15s linear, top 0.15s linear';
    mapRobot.style.transform = `translate(-50%, -50%) rotate(${currentAngle + 180}deg)`;

    // Synchronize heading compass needle spin
    const compassSvg = document.getElementById('heading-compass-svg');
    if (compassSvg) {
      compassSvg.style.transition = 'transform 1.2s cubic-bezier(0.25, 1, 0.5, 1)';
      compassSvg.style.transform = `rotate(${currentAngle + 180}deg)`;
    }

    setTimeout(() => {
      // Clean up classes
      mapRobot.classList.remove('spinning');
      
      // Update state to save the new 180 degree rotation heading
      activeRobot.angle = targetAngle;
      
      // Reset robot transition back to normal, temporarily omitting transform
      // to prevent backward spin on resetting angle.
      mapRobot.style.transition = 'left 0.15s linear, top 0.15s linear';
      updateRobotAndTrailDOM();
      
      // Restore transform transition after update
      setTimeout(() => {
        mapRobot.style.transition = 'left 0.15s linear, top 0.15s linear, transform 0.15s ease';
      }, 50);
      
      if (compassSvg) {
        compassSvg.style.transition = 'none';
        compassSvg.style.transform = `rotate(${targetAngle}deg)`;
      }
    }, 1200);
  }

  const timestamp = new Date().toTimeString().split(' ')[0];
  consoleLogs.push(`[${timestamp}] CMD: Rotate 180° Cycle Initiated`);
  if (consoleLogs.length > 25) consoleLogs.shift();
  renderConsoleFeed();
}

function resumeAutoNav() {
  isManualOverride = false;
  
  const resumeContainer = document.getElementById('resume-autonav-container');
  if (resumeContainer) resumeContainer.style.display = 'none';

  document.getElementById('hud-tracking-title').innerText = `Active Tracking: ${activeRobot.name}`;

  if (webStartX !== null && webDestX !== null && !webAutoNavActive) {
    toggleWebAutoNav();
  }

  showToastNotification("Resumed autonomous navigation.");

  const timestamp = new Date().toTimeString().split(' ')[0];
  consoleLogs.push(`[${timestamp}] CMD: Resume Autonomous Navigation`);
  if (consoleLogs.length > 25) consoleLogs.shift();
  renderConsoleFeed();
}

function emergencyStopRobot() {
  const timestamp = new Date().toTimeString().split(' ')[0];
  
  activeRobot.status = 'E-STOPPED';
  
  const badge = document.getElementById('viz-status-badge');
  badge.innerHTML = `<span class="status-monitor-dot red"></span> E-STOPPED`;
  badge.style.color = '#ef4444';
  
  document.getElementById('monitor-speed').innerText = `0.0 m/s`;
  document.getElementById('monitor-direction').innerText = `Halted`;

  const shortText = document.getElementById('monitor-direction-short');
  if (shortText) shortText.innerText = '--';

  const velocityRing = document.getElementById('velocity-ring');
  if (velocityRing) velocityRing.style.strokeDasharray = `0, 100`;

  consoleLogs.push(`[${timestamp}] [ALERT] EMERGENCY BRAKE ENGAGED! ALL MOTORS POWER OFF.`);
  renderConsoleFeed();
}

// Switch between Normal and Admin simulated roles
function toggleAdminSimMode(checkbox) {
  isAdminSimMode = checkbox.checked;
  
  const avatar = document.getElementById('profile-avatar');
  const name = document.getElementById('profile-name');
  const role = document.getElementById('profile-role');
  const clearance = document.getElementById('profile-clearance');
  const empId = document.getElementById('profile-emp-id');
  const email = document.getElementById('profile-email');
  const dept = document.getElementById('profile-dept');
  
  const statusBadge = document.getElementById('priv-badge-status');
  const lockedBanner = document.getElementById('admin-locked-banner');
  const adminActions = document.getElementById('admin-actions-list');
  const adminDetailsCard = document.getElementById('admin-details-card');
  
  // Drawer profile
  const drawerAvatar = document.getElementById('drawer-avatar-big');
  const drawerName = document.getElementById('drawer-profile-name');
  const drawerRole = document.getElementById('drawer-profile-role');
  const drawerBadge = document.getElementById('drawer-profile-badge');
  const headerAvatar = document.getElementById('header-avatar');
  const headerUsername = document.getElementById('header-username');
  const drawerAdminLink = document.getElementById('drawer-link-admin');

  const isDark = document.getElementById('appScreen') ? document.getElementById('appScreen').classList.contains('dark-theme-active') : false;

  if (isAdminSimMode) {
    // Settings screen
    if (avatar) { avatar.innerText = 'AM'; avatar.style.background = 'linear-gradient(135deg, #8b5cf6, #6d28d9)'; }
    if (name) name.innerText = 'Dr. Aryan Mehta';
    if (role) role.innerText = 'Role: System Administrator';
    if (clearance) { 
      clearance.innerText = 'Clearance Level 5'; 
      clearance.style.color = isDark ? '#a78bfa' : '#6d28d9'; 
      clearance.style.background = isDark ? 'rgba(139, 92, 246, 0.12)' : 'rgba(109, 40, 217, 0.08)'; 
      clearance.style.borderColor = isDark ? 'rgba(139, 92, 246, 0.3)' : 'rgba(109, 40, 217, 0.2)'; 
    }
    if (empId) empId.innerText = 'ADM-0001';
    if (email) email.innerText = 'admin@blucursor.com';
    if (dept) dept.innerText = 'System Administration';
    if (adminDetailsCard) adminDetailsCard.style.display = 'block';
    
    // Admin badge
    if (statusBadge) { statusBadge.innerText = 'ACTIVE'; statusBadge.style.color = '#10b981'; statusBadge.style.backgroundColor = 'rgba(16, 185, 129, 0.12)'; statusBadge.style.borderColor = 'rgba(16,185,129,0.3)'; }
    if (lockedBanner) lockedBanner.style.display = 'none';
    if (adminActions) adminActions.style.display = 'block';
    
    // Drawer
    if (drawerAvatar) { drawerAvatar.innerText = 'AM'; drawerAvatar.style.background = 'linear-gradient(135deg, #8b5cf6, #6d28d9)'; }
    if (drawerName) drawerName.innerText = 'Dr. Aryan Mehta';
    if (drawerRole) drawerRole.innerText = 'System Administrator';
    if (drawerBadge) { 
      drawerBadge.style.color = isDark ? '#a78bfa' : '#6d28d9'; 
      drawerBadge.style.background = isDark ? 'rgba(139, 92, 246, 0.12)' : 'rgba(109, 40, 217, 0.08)'; 
      drawerBadge.style.borderColor = isDark ? 'rgba(139, 92, 246, 0.25)' : 'rgba(109, 40, 217, 0.2)'; 
    }
    if (headerAvatar) { headerAvatar.innerText = 'AM'; headerAvatar.style.background = 'linear-gradient(135deg, #8b5cf6, #6d28d9)'; }
    if (headerUsername) headerUsername.innerText = 'Dr. Aryan Mehta';
    if (drawerAdminLink) drawerAdminLink.style.display = 'flex';
    
    showToastNotification('Admin Mode: Dr. Aryan Mehta | Level 5 Clearance');
  } else {
    // Settings screen
    if (avatar) { avatar.innerText = 'JD'; avatar.style.background = 'linear-gradient(135deg, #3b82f6, #1d4ed8)'; }
    if (name) name.innerText = 'John Doe';
    if (role) role.innerText = 'Role: Senior Operator';
    if (clearance) { 
      clearance.innerText = 'Clearance Level 3'; 
      clearance.style.color = isDark ? '#60a5fa' : '#0033A1'; 
      clearance.style.background = isDark ? 'rgba(59, 130, 246, 0.12)' : 'rgba(0, 51, 161, 0.08)'; 
      clearance.style.borderColor = isDark ? 'rgba(59,130,246,0.25)' : 'rgba(0, 51, 161, 0.2)'; 
    }
    if (empId) empId.innerText = 'EMP-9942';
    if (email) email.innerText = 'operator@blucursor.com';
    if (dept) dept.innerText = 'Fleet Operations';
    if (adminDetailsCard) adminDetailsCard.style.display = 'none';

    // Admin badge
    if (statusBadge) { statusBadge.innerText = 'LOCK'; statusBadge.style.color = 'var(--app-danger)'; statusBadge.style.backgroundColor = 'rgba(239, 68, 68, 0.1)'; statusBadge.style.borderColor = 'rgba(239,68,68,0.25)'; }
    if (lockedBanner) lockedBanner.style.display = 'flex';
    if (adminActions) adminActions.style.display = 'none';
    
    // Drawer
    if (drawerAvatar) { drawerAvatar.innerText = 'JD'; drawerAvatar.style.background = 'linear-gradient(135deg, #3b82f6, #1d4ed8)'; }
    if (drawerName) drawerName.innerText = 'John Doe';
    if (drawerRole) drawerRole.innerText = 'Senior Operator';
    if (drawerBadge) { 
      drawerBadge.innerText = 'CLEARANCE LVL 3'; 
      drawerBadge.style.color = isDark ? '#60a5fa' : '#0033A1'; 
      drawerBadge.style.background = isDark ? 'rgba(59, 130, 246, 0.12)' : 'rgba(0, 51, 161, 0.08)'; 
      drawerBadge.style.borderColor = isDark ? 'rgba(59, 130, 246, 0.25)' : 'rgba(0, 51, 161, 0.2)'; 
    }
    if (headerAvatar) { headerAvatar.innerText = 'JD'; headerAvatar.style.background = 'linear-gradient(135deg, #3b82f6, #1d4ed8)'; }
    if (headerUsername) headerUsername.innerText = 'John Doe';
    if (drawerAdminLink) drawerAdminLink.style.display = 'none';
  }
}

// Switch between Light and Dark simulated themes
function toggleThemeSimMode(checkbox) {
  const appScreen = document.getElementById('appScreen');
  const themeModeToggle = document.getElementById('theme-mode-toggle');
  
  if (themeModeToggle) {
    themeModeToggle.checked = checkbox.checked;
  }

  if (checkbox.checked) {
    appScreen.classList.add('dark-theme-active');
    document.querySelectorAll('.phone-screen img.logo-img').forEach(img => {
      img.src = 'assets/logo_light.png';
    });
  } else {
    appScreen.classList.remove('dark-theme-active');
    document.querySelectorAll('.phone-screen img.logo-img').forEach(img => {
      img.src = 'assets/logo_dark.png';
    });
  }
  
  // Refresh roles & badges colors for contrast
  toggleAdminSimMode({ checked: isAdminSimMode });
}

function adminAction(actionName) {
  alert(`[ADMIN PROCESS] Executing privilege action: "${actionName}"...\nOperations log initialized and signed by admin@blucursor.com.`);
}

// Copy Code
function copyActiveCode() {
  const codeEl = document.getElementById('codeDisplayCode');
  if (codeEl) {
    navigator.clipboard.writeText(codeEl.innerText).then(() => {
      showToastNotification('Code copied to clipboard!');
    });
  }
}

// Toast Alerts
function showToastNotification(msg) {
  let toast = document.createElement('div');
  toast.className = 'toast-alert';
  toast.innerText = msg;
  document.body.appendChild(toast);
  
  setTimeout(() => toast.classList.add('visible'), 50);
  setTimeout(() => {
    toast.classList.remove('visible');
    setTimeout(() => toast.remove(), 300);
  }, 2200);
}

// Dialog Info
function showAboutInfo() {
  document.getElementById('aboutDialog').classList.add('active');
}
function closeAboutInfo() {
  document.getElementById('aboutDialog').classList.remove('active');
}

// D-Pad Hold-to-Move Support
let dpadHoldTimer = null;
let dpadHoldInterval = null;
let currentSpeedMultiplier = 1.0;

function startDpadHold(cmdName, dx, dy) {
  stopDpadHold(); // Clear any existing timers first!
  // First immediate trigger
  sendRemoteCmd(cmdName, dx * currentSpeedMultiplier, dy * currentSpeedMultiplier);
  
  // Start repeat interval for hold
  dpadHoldTimer = setTimeout(() => {
    dpadHoldInterval = setInterval(() => {
      sendRemoteCmd(cmdName, dx * currentSpeedMultiplier, dy * currentSpeedMultiplier);
    }, 150);
  }, 250);
}

function stopDpadHold() {
  if (dpadHoldTimer) {
    clearTimeout(dpadHoldTimer);
    dpadHoldTimer = null;
  }
  if (dpadHoldInterval) {
    clearInterval(dpadHoldInterval);
    dpadHoldInterval = null;
  }
}

function updateRobotSpeed(val) {
  const valNum = parseInt(val);
  currentSpeedMultiplier = valNum / 5;
  const speedMs = (valNum * 0.16).toFixed(1);
  const displayEl = document.getElementById('speed-val-display');
  if (displayEl) displayEl.innerText = `${speedMs}m/s`;
  
  // Update monitoring speed display if visible
  const speedDisplayEl = document.getElementById('monitor-speed');
  if (speedDisplayEl && currentScreen === 'real_time_viz') {
    speedDisplayEl.innerText = `${speedMs} m/s`;
  }
}

// map pulse keyframe (added to DOM animation)
const styleTag = document.createElement('style');
styleTag.innerText = `
@keyframes mapPulse {
  0% { transform: scale(1); opacity: 0.9; }
  100% { transform: scale(2.5); opacity: 0; }
}
`;
document.head.appendChild(styleTag);

// Initialize on page load
window.addEventListener('DOMContentLoaded', () => {
  // Auto-apply dark theme on the simulated phone
  const appScreen = document.getElementById('appScreen');
  const themeToggle = document.getElementById('theme-mode-toggle');
  if (appScreen) {
    appScreen.classList.add('dark-theme-active');
    if (themeToggle) {
      themeToggle.checked = true;
    }
    // Set logo to light version
    document.querySelectorAll('.phone-screen img.logo-img').forEach(img => {
      img.src = 'assets/logo_light.png';
    });
  }
  
  // Set up admin mode if already active
  if (isAdminSimMode) {
    const adminToggle = document.getElementById('admin-mode-toggle');
    if (adminToggle) adminToggle.checked = true;
    toggleAdminSimMode({ checked: true });
  }
  
  switchCodeFile('pubspec');
  
  // Start the cinematic boot loader sequence automatically on load
  startCinematicSplash();
});

// Cinematic Splash Boot Sequence
function startCinematicSplash() {
  const loadingText = document.getElementById('splash-loading-text');
  const progressBar = document.getElementById('splash-progress-bar-fill');
  const splashScreen = document.getElementById('screen-splash');
  if (!loadingText || !progressBar || !splashScreen) return;
  
  // Reset and prepare splash screen state
  splashScreen.classList.add('active');
  splashScreen.classList.remove('glitch-active', 'zoom-out');
  
  const bootMessages = [
    { text: "Initializing AI Core...", delay: 0 },
    { text: "Loading Robot Models...", delay: 600 },
    { text: "Connecting Simulation Engine...", delay: 1200 },
    { text: "Loading Navigation Mesh...", delay: 1800 },
    { text: "Synchronizing Sensors...", delay: 2400 },
    { text: "Calibrating Motors...", delay: 3000 },
    { text: "Simulation Ready", delay: 3600 }
  ];
  
  let progress = 0;
  progressBar.style.width = '0%';
  
  // Progress bar animation interval (updates every 40ms, total 3600ms)
  const totalDuration = 3600;
  const intervalTime = 40;
  const increment = (100 / (totalDuration / intervalTime));
  
  const progressInterval = setInterval(() => {
    progress += increment;
    progressBar.style.width = `${Math.min(100, progress)}%`;
    if (progress >= 100) {
      clearInterval(progressInterval);
    }
  }, intervalTime);
  
  // Message update timers
  bootMessages.forEach(msg => {
    setTimeout(() => {
      if (currentScreen === 'splash') {
        loadingText.innerText = msg.text;
        
        // Trigger glitch/zoom transition on complete
        if (msg.text === "Simulation Ready") {
          setTimeout(() => {
            splashScreen.classList.add('glitch-active');
            
            // Camera zoom & fade transition
            setTimeout(() => {
              splashScreen.classList.add('zoom-out');
              
              setTimeout(() => {
                // Redirect
                const token = localStorage.getItem('token');
                if (token) {
                  connectBackendWS(token);
                  showScreen('dashboard');
                } else {
                  showScreen('login');
                }
              }, 600);
            }, 400);
          }, 500);
        }
      }
    }, msg.delay);
  });
}

// Jarvis Floating Assistant orb logic
let jarvisTypingInterval = null;
function toggleJarvisAssistant(isOpen) {
  const panel = document.getElementById('jarvisPanel');
  const orb = document.getElementById('jarvisOrb');
  if (!panel) return;
  
  if (isOpen) {
    panel.classList.add('active');
    if (orb) orb.classList.add('active');
    
    // Typewriter effect
    const jarvisText = document.getElementById('jarvisText');
    if (jarvisText) {
      jarvisText.innerHTML = '';
      const text = "System online, Operator. Monitoring fleet units RB-001 through RB-005. Volumetric mapping is synchronized and all safety override loops are active. How can I assist your fleet command today?";
      let index = 0;
      if (jarvisTypingInterval) clearInterval(jarvisTypingInterval);
      jarvisTypingInterval = setInterval(() => {
        if (index < text.length) {
          jarvisText.innerHTML += text.charAt(index);
          index++;
        } else {
          clearInterval(jarvisTypingInterval);
        }
      }, 20);
    }
  } else {
    panel.classList.remove('active');
    if (orb) orb.classList.remove('active');
    if (jarvisTypingInterval) clearInterval(jarvisTypingInterval);
  }
}

// Switch right panel tabs (About bluCursor / Code Explorer)
function switchRightPanelTab(tabId) {
  const btnAbout = document.getElementById('tab-panel-about');
  const btnCode = document.getElementById('tab-panel-code');
  const viewAbout = document.getElementById('panel-content-about');
  const viewCode = document.getElementById('panel-content-code');
  
  if (tabId === 'about') {
    if (btnAbout) btnAbout.classList.add('active');
    if (btnCode) btnCode.classList.remove('active');
    if (viewAbout) viewAbout.style.display = 'flex';
    if (viewCode) viewCode.style.display = 'none';
  } else {
    if (btnCode) btnCode.classList.add('active');
    if (btnAbout) btnAbout.classList.remove('active');
    if (viewCode) viewCode.style.display = 'flex';
    if (viewAbout) viewAbout.style.display = 'none';
  }
}

// Switch company intro tabs on dashboard
function switchIntroTab(index) {
  document.querySelectorAll('.intro-tab-content').forEach(content => {
    content.style.display = 'none';
  });
  document.querySelectorAll('.intro-tab-btn').forEach(btn => {
    btn.classList.remove('active');
  });
  const contentEl = document.getElementById(`intro-content-${index}`);
  if (contentEl) contentEl.style.display = 'block';
  const btnEl = document.getElementById(`tab-intro-${index}`);
  if (btnEl) btnEl.classList.add('active');
}

// Web Simulator Auto-Navigation and Manual controller toggling
let webStartX = null;
let webStartY = null;
let webDestX = null;
let webDestY = null;
let webSettingMode = null; // 'start' | 'target' | null
let webAutoNavActive = false;
let webAutoNavTimer = null;
let webShowManual = true;

function toggleWebSettingMode(mode) {
  const btnStart = document.getElementById('btn-web-start');
  const btnTarget = document.getElementById('btn-web-target');
  
  if (webSettingMode === mode) {
    webSettingMode = null;
    if (btnStart) btnStart.classList.remove('active-start');
    if (btnTarget) btnTarget.classList.remove('active-target');
    return;
  }
  
  webSettingMode = mode;
  if (mode === 'start') {
    if (btnStart) btnStart.classList.add('active-start');
    if (btnTarget) btnTarget.classList.remove('active-target');
  } else {
    if (btnTarget) btnTarget.classList.add('active-target');
    if (btnStart) btnStart.classList.remove('active-start');
  }
}

function onWebMapClick(event) {
  if (!webSettingMode) return;
  
  const viewport = document.getElementById('viz-map-container');
  if (!viewport) return;
  const rect = viewport.getBoundingClientRect();
  const px = event.clientX - rect.left;
  const py = event.clientY - rect.top;
  
  // Calculate map coordinates
  const W = viewport.clientWidth;
  const H = viewport.clientHeight;
  const mapImg = activeMapImg || 'assets/map_1.png';
  const R = mapRatios[mapImg] || 0.7119;
  
  let w_img = W;
  let h_img = H;
  let dx = 0;
  let dy = 0;
  
  if (W / H > R) {
    h_img = H;
    w_img = H * R;
    dx = (W - w_img) / 2;
  } else {
    w_img = W;
    h_img = W / R;
    dy = (H - h_img) / 2;
  }
  
  const padding = 12;
  const x = Math.max(0, Math.min(25, ((px - dx - padding) / (w_img - padding * 2)) * 25));
  const y = Math.max(0, Math.min(20, ((py - dy - padding) / (h_img - padding * 2)) * 20));
  
  if (webSettingMode === 'start') {
    webStartX = x;
    webStartY = y;
    const marker = document.getElementById('web-start-marker');
    if (marker) {
      marker.style.left = `${px}px`;
      marker.style.top = `${py}px`;
      marker.style.display = 'block';
    }
    
    // Deactivate start button
    const btnStart = document.getElementById('btn-web-start');
    if (btnStart) btnStart.classList.remove('active-start');
    webSettingMode = null;
    
    const timestamp = new Date().toTimeString().split(' ')[0];
    consoleLogs.push(`[${timestamp}] Set Start to [${x.toFixed(1)}, ${y.toFixed(1)}]`);
  } else if (webSettingMode === 'target') {
    webDestX = x;
    webDestY = y;
    const marker = document.getElementById('web-target-marker');
    if (marker) {
      marker.style.left = `${px}px`;
      marker.style.top = `${py}px`;
      marker.style.display = 'block';
    }
    
    // Deactivate target button
    const btnTarget = document.getElementById('btn-web-target');
    if (btnTarget) btnTarget.classList.remove('active-target');
    webSettingMode = null;
    
    const timestamp = new Date().toTimeString().split(' ')[0];
    consoleLogs.push(`[${timestamp}] Set Target to [${x.toFixed(1)}, ${y.toFixed(1)}]`);
  }
  
  renderConsoleFeed();
  drawWebPath();
  
  // Show/hide auto nav button
  const btnAuto = document.getElementById('btn-web-auto');
  if (btnAuto) {
    if (webStartX !== null && webDestX !== null) {
      btnAuto.style.display = 'flex';
    } else {
      btnAuto.style.display = 'none';
    }
  }
// JavaScript implementation of A* grid matching backend
const webGrid = Array.from({ length: 25 }, () => Array(20).fill(0));

// Populate boundary walls
for (let x = 0; x < 25; x++) {
  webGrid[x][0] = 1;
  webGrid[x][19] = 1;
}
for (let y = 0; y < 20; y++) {
  webGrid[0][y] = 1;
  webGrid[24][y] = 1;
}

// Populate horizontal partition wall at y=11 (Doors at x=9 and x=14)
for (let x = 0; x < 25; x++) {
  if (x !== 9 && x !== 14) {
    webGrid[x][11] = 1;
  }
}

// Populate vertical partition wall at x=12 from y=11 to 20
for (let y = 11; y < 20; y++) {
  webGrid[12][y] = 1;
}

// Populate vertical wall for left rooms at x=5 from y=0 to 11 (Door at y=3)
for (let y = 0; y < 11; y++) {
  if (y !== 3) {
    webGrid[5][y] = 1;
  }
}

// Populate horizontal wall at y=6 from x=0 to 5
for (let x = 0; x < 6; x++) {
  webGrid[x][6] = 1;
}

// Populate office desks and chairs (obstacles)
for (let y = 1; y < 10; y++) {
  webGrid[15][y] = 1;
  webGrid[13][y] = 1;
  webGrid[17][y] = 1;
}

for (let y of [3, 6, 9]) {
  webGrid[22][y] = 1;
  webGrid[23][y] = 1;
}

for (let x = 0; x < 5; x++) {
  webGrid[x][2] = 1;
}

function findWebClosestFree(pt) {
  let [x, y] = pt;
  x = Math.max(0, Math.min(24, x));
  y = Math.max(0, Math.min(19, y));
  pt = [x, y];
  if (webGrid[x][y] === 0) return pt;
  
  const queue = [pt];
  const visited = new Set([`${x},${y}`]);
  
  while (queue.length > 0) {
    const [cx, cy] = queue.shift();
    if (webGrid[cx][cy] === 0) return [cx, cy];
    
    for (const [dx, dy] of [
      [-1, 0], [1, 0], [0, -1], [0, 1],
      [-1, -1], [1, 1], [-1, 1], [1, -1]
    ]) {
      const nx = cx + dx;
      const ny = cy + dy;
      if (nx >= 0 && nx < 25 && ny >= 0 && ny < 20) {
        const key = `${nx},${ny}`;
        if (!visited.has(key)) {
          visited.add(key);
          queue.push([nx, ny]);
        }
      }
    }
  }
  return pt;
}

function webAstar(start, goal) {
  const start_grid = findWebClosestFree([
    Math.max(0, Math.min(24, Math.round(start[0]))),
    Math.max(0, Math.min(19, Math.round(start[1])))
  ]);
  const goal_grid = findWebClosestFree([
    Math.max(0, Math.min(24, Math.round(goal[0]))),
    Math.max(0, Math.min(19, Math.round(goal[1])))
  ]);
  
  const queue = [{ f: 0, g: 0, current: start_grid, path: [start_grid] }];
  const visited = new Set();
  
  while (queue.length > 0) {
    queue.sort((a, b) => a.f - b.f);
    const { g, current, path } = queue.shift();
    
    const [cx, cy] = current;
    if (cx === goal_grid[0] && cy === goal_grid[1]) {
      return path;
    }
    
    const key = `${cx},${cy}`;
    if (visited.has(key)) continue;
    visited.add(key);
    
    const directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1],
      [-1, -1], [1, 1], [-1, 1], [1, -1]
    ];
    for (const [dx, dy] of directions) {
      const nx = cx + dx;
      const ny = cy + dy;
      if (nx >= 0 && nx < 25 && ny >= 0 && ny < 20 && webGrid[nx][ny] === 0) {
        // Prevent cutting corners
        if (dx !== 0 && dy !== 0) {
          if (webGrid[cx + dx][cy] !== 0 || webGrid[cx][cy + dy] !== 0) {
            continue;
          }
        }
        const neighbor = [nx, ny];
        const move_cost = (dx !== 0 && dy !== 0) ? 1.414 : 1.0;
        const g_score = g + move_cost;
        const h_score = Math.sqrt(Math.pow(nx - goal_grid[0], 2) + Math.pow(ny - goal_grid[1], 2));
        queue.push({
          f: g_score + h_score,
          g: g_score,
          current: neighbor,
          path: [...path, neighbor]
        });
      }
    }
  }
  return [start, goal];
}

function drawWebPath() {
  const canvas = document.getElementById('web-path-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  if (webStartX === null || webDestX === null) return;
  
  const path = webAstar([webStartX, webStartY], [webDestX, webDestY]);
  if (path.length < 2) return;
  
  ctx.beginPath();
  ctx.setLineDash([5, 5]);
  ctx.strokeStyle = 'rgba(85, 232, 255, 0.85)';
  ctx.lineWidth = 2.5;
  
  const pStart = getPixelOffset(path[0][0], path[0][1]);
  ctx.moveTo(pStart.px, pStart.py);
  
  for (let i = 1; i < path.length; i++) {
    const p = getPixelOffset(path[i][0], path[i][1]);
    ctx.lineTo(p.px, p.py);
  }
  ctx.stroke();
}

function toggleWebAutoNav() {
  const btnAuto = document.getElementById('btn-web-auto');
  const iconAuto = document.getElementById('icon-web-auto');
  
  if (webAutoNavActive) {
    stopWebAutoNav();
    return;
  }
  
  webAutoNavActive = true;
  if (btnAuto) btnAuto.classList.add('active-auto');
  if (iconAuto) iconAuto.className = 'icon-stop';
  
  const timestamp = new Date().toTimeString().split(' ')[0];
  consoleLogs.push(`[${timestamp}] Auto Nav: [${webStartX.toFixed(1)}, ${webStartY.toFixed(1)}] -> [${webDestX.toFixed(1)}, ${webDestY.toFixed(1)}]`);
  renderConsoleFeed();
  
  // Send websocket start command if connected
  if (webSocket && webSocket.readyState === WebSocket.OPEN) {
    const matchR = activeRobot.id.match(/\d+$/);
    const intId = matchR ? parseInt(matchR[0]) : 1;
    webSocket.send(JSON.stringify({
      type: "START_AUTO",
      robot_id: intId,
      payload: {
        start_x: webStartX,
        start_y: webStartY,
        destination_x: webDestX,
        destination_y: webDestY
      }
    }));
    return;
  }
  
  // Local offline simulation using A* waypoints
  const path = webAstar([webStartX, webStartY], [webDestX, webDestY]);
  let pathIndex = 0;
  
  activeRobot.position = `${webStartX.toFixed(1)}, ${webStartY.toFixed(1)}`;
  activeRobot.status = 'Online';
  realtimeTrail = [[webStartX, webStartY]];
  updateRobotAndTrailDOM();
  
  webAutoNavTimer = setInterval(() => {
    if (pathIndex >= path.length) {
      stopWebAutoNav();
      const ts = new Date().toTimeString().split(' ')[0];
      consoleLogs.push(`[${ts}] Auto Nav: Destination Reached!`);
      renderConsoleFeed();
      return;
    }
    
    const parts = activeRobot.position.split(/,\s*/);
    let cx = parseFloat(parts[0]);
    let cy = parseFloat(parts[1]);
    if (isNaN(cx) || isNaN(cy)) {
      cx = 12.5;
      cy = 10.0;
    }
    
    const target = path[pathIndex];
    const tx = target[0];
    const ty = target[1];
    
    let dx = tx - cx;
    let dy = ty - cy;
    let distance = Math.sqrt(dx * dx + dy * dy);
    
    const stepSize = 0.4;
    
    if (distance <= stepSize) {
      cx = tx;
      cy = ty;
      pathIndex++;
    } else {
      cx += (dx / distance) * stepSize;
      cy += (dy / distance) * stepSize;
      
      if (Math.abs(dx) > Math.abs(dy)) {
        activeRobot.angle = dx > 0 ? 90 : 270;
      } else {
        activeRobot.angle = dy > 0 ? 180 : 0;
      }
    }
    
    activeRobot.position = `${cx.toFixed(1)}, ${cy.toFixed(1)}`;
    realtimeTrail.push([cx, cy]);
    if (realtimeTrail.length > 25) realtimeTrail.shift();
    updateRobotAndTrailDOM();
    
    document.getElementById('hud-tracking-desc').innerText = `GPS Latency: < 12ms | Coordinates: [${cx.toFixed(2)}, ${cy.toFixed(2)}]`;
  }, 250);
}

function stopWebAutoNav() {
  if (!webAutoNavActive) return;
  webAutoNavActive = false;
  
  const btnAuto = document.getElementById('btn-web-auto');
  const iconAuto = document.getElementById('icon-web-auto');
  if (btnAuto) btnAuto.classList.remove('active-auto');
  if (iconAuto) iconAuto.className = 'icon-play';
  
  if (webAutoNavTimer) clearInterval(webAutoNavTimer);
  
  if (webSocket && webSocket.readyState === WebSocket.OPEN) {
    const matchR = activeRobot.id.match(/\d+$/);
    const intId = matchR ? parseInt(matchR[0]) : 1;
    webSocket.send(JSON.stringify({
      type: "STOP_AUTO",
      robot_id: intId
    }));
  }
}

function toggleWebGamepad() {
  const panel = document.getElementById('manual-controls-section');
  const btnGamepad = document.getElementById('btn-web-gamepad');
  
  webShowManual = !webShowManual;
  if (panel && btnGamepad) {
    if (webShowManual) {
      panel.style.display = 'block';
      btnGamepad.style.color = 'var(--app-primary)';
    } else {
      panel.style.display = 'none';
      btnGamepad.style.color = 'var(--app-text-muted)';
    }
  }
}


// ==========================================================================
// ROBOT SPLIT-DOOR TRANSITION OVERLAY IMPLEMENTATION
// ==========================================================================
function triggerSplitTransition(targetScreenId, robot) {
  const overlay = document.getElementById('robot-transition-overlay');
  const robotNameEl = document.getElementById('trans-robot-name');
  const robotImgEl = document.getElementById('trans-robot-img');
  const progressFill = document.getElementById('trans-progress-fill');
  
  if (!overlay || !robot) {
    showScreen(targetScreenId);
    return;
  }
  
  // Set robot info
  robotNameEl.innerText = `${robot.name} CONNECTING`;
  robotImgEl.src = robot.image || 'assets/robot_hermes.png';
  
  // Dynamic background style for the loading screen phase
  overlay.style.backgroundImage = "linear-gradient(rgba(9, 10, 15, 0.70), rgba(9, 10, 15, 0.85)), url('assets/robot_loading_bg.jpg')";
  overlay.style.backgroundSize = "cover";
  overlay.style.backgroundPosition = "center";
  
  // Hide split doors during the loading stage
  const leftDoor = overlay.querySelector('.left-door');
  const rightDoor = overlay.querySelector('.right-door');
  leftDoor.style.display = 'none';
  rightDoor.style.display = 'none';
  leftDoor.style.transform = 'translateX(0)';
  rightDoor.style.transform = 'translateX(0)';
  
  // Reset progress and show overlay
  overlay.className = 'transition-overlay active';
  progressFill.style.width = '0%';
  
  // Drive loading progress bar animation over 2.0 seconds
  let start = null;
  const duration = 2000;
  
  function animateProgress(timestamp) {
    if (!start) start = timestamp;
    const elapsed = timestamp - start;
    const progress = Math.min(100, (elapsed / duration) * 100);
    progressFill.style.width = `${progress}%`;
    
    if (elapsed < duration) {
      if (overlay.classList.contains('active')) {
        requestAnimationFrame(animateProgress);
      }
    } else {
      // 1. Loading complete. Snap the split doors shut to prepare for the split reveal!
      leftDoor.style.display = 'block';
      rightDoor.style.display = 'block';
      
      // Force reflow
      leftDoor.offsetHeight;
      
      // 2. Switch the underlying screen
      showScreen(targetScreenId);
      
      // 3. Trigger the split opening sliding doors
      overlay.classList.add('separating');
      
      // 4. Remove overlay after doors slide out
      setTimeout(() => {
        overlay.classList.remove('active', 'separating');
        overlay.style.backgroundImage = ''; // Clear background for next call
      }, 700); // 0.6s door transition + margin
    }
  }
  
  requestAnimationFrame(animateProgress);
}
