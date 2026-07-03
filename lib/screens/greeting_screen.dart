import 'dart:async';
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                
                                // Left Card
                                _buildGlassCard(
                                  width: 82,
                                  height: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildCardHeader('AI CORE', 'ONLINE', const Color(0xff10B981)),
                                      SizedBox(
                                        height: 30,
                                        width: 70,
                                        child: CustomPaint(
                                          painter: _WaveformPainterRefined(_waveAnimation),
                                        ),
                                      ),
                                      _buildCardFooter('SYS HEALTH', '99.8%'),
                                    ],
                                  ),
                                ),

                                // Center Hero Robot Viewport
                                SizedBox(
                                  width: 140,
                                  height: 185,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Minimal Coordinate rings (spin & perspective)
                                      Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.0015)
                                          ..rotateX(1.3),
                                        child: AnimatedBuilder(
                                          animation: _spinAnimation,
                                          builder: (context, child) {
                                            return CustomPaint(
                                              size: const Size(130, 130),
                                              painter: _MinimalCoordinateRingsPainter(_spinAnimation.value),
                                            );
                                          },
                                        ),
                                      ),
                                      
                                      // Glowing Platform Shadow Underneath (Refined)
                                      Positioned(
                                        bottom: 22,
                                        child: AnimatedBuilder(
                                          animation: _floatController,
                                          builder: (context, child) {
                                            final scale = 1.0 - (_floatAnimation.value / -32.0);
                                            return Container(
                                              width: 80 * scale,
                                              height: 10 * scale,
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

                                      // Floating Robot Image
                                      AnimatedBuilder(
                                        animation: _floatAnimation,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(0, _floatAnimation.value - 12),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/robot_hermes.png',
                                                  width: 100,
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

                                // Right Card
                                _buildGlassCard(
                                  width: 82,
                                  height: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildCardHeader('FLEET STATUS', 'CONNECTED', const Color(0xff10B981)),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '12',
                                            style: GoogleFonts.outfit(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              height: 1,
                                            ),
                                          ),
                                          Text(
                                            'ROBOTS',
                                            style: GoogleFonts.outfit(
                                              fontSize: 6.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xff64748B),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildCardFooterWithNetworkBars('NETWORK', 'STABLE'),
                                    ],
                                  ),
                                ),

                              ],
                            ),

                            const SizedBox(height: 20),

                            // 3. Status Line
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('[', style: GoogleFonts.jetBrainsMono(color: const Color(0xffffffff).withOpacity(0.08), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '> SYSTEM DIAGNOSTICS: SECURE',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: const Color(0xff64748B),
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(']', style: GoogleFonts.jetBrainsMono(color: const Color(0xffffffff).withOpacity(0.08), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 4. Metrics Grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 4,
                              crossAxisSpacing: 6,
                              childAspectRatio: 1.1,
                              children: [
                                _buildMetricBox(Icons.monitor, 'Robots Online', '12'),
                                _buildMetricBox(Icons.battery_charging_full, 'Battery Health', '97%'),
                                _buildMetricBox(Icons.local_shipping, "Deliveries", '48'),
                                _buildMetricBox(Icons.memory, 'CPU Usage', '21%'),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // 5. Console Card (Mini Vector map path tracking)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xff131926).withOpacity(0.55),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xffffffff).withOpacity(0.05)),
                              ),
                              child: Row(
                                children: [
                                  // Left Vector Coordinate Map
                                  Container(
                                    width: 64,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.white.withOpacity(0.02)),
                                    ),
                                    child: AnimatedBuilder(
                                      animation: _crawlerAnimation,
                                      builder: (context, child) {
                                        return CustomPaint(
                                          painter: _MiniVectorMapPainter(_crawlerAnimation.value),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Right Timeline Logs
                                  Expanded(
                                    child: _buildConsoleTimeline(),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

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
      text: TextSpan(text: 'X:${rx.toStringAsFixed(1)}', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterX.paint(canvas, const Offset(4, 4));

    final textPainterY = TextPainter(
      text: TextSpan(text: 'Y:${ry.toStringAsFixed(1)}', style: textStyle),
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
