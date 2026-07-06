import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/robot.dart';
import '../services/api_service.dart';

class ControlPanelScreen extends StatefulWidget {
  const ControlPanelScreen({Key? key}) : super(key: key);

  @override
  State<ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  late Robot _robot;
  bool _initialized = false;
  bool _isEStopped = false;
  final List<String> _logs = [];
  double _posX = 0.0;
  double _posY = 0.0;
  double _angle = 0.0;
  int _battery = 100;
  final ScrollController _scrollController = ScrollController();

  bool get _canControl => _robot.isOnline && !_isEStopped;

  void _addLog(String msg) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    if (mounted) {
      setState(() {
        _logs.insert(0, '[$timeStr] $msg');
      });
    }
  }

  void _updateRobotState() {
    final index = sampleRobots.indexWhere((r) => r.id == _robot.id);
    if (index != -1) {
      sampleRobots[index] = sampleRobots[index].copyWith(
        position: '${_posX.toStringAsFixed(2)}, ${_posY.toStringAsFixed(2)}',
        angle: (_angle % 360 + 360) % 360,
        batteryLevel: _battery,
      );
    }
  }

  void _moveForward() {
    if (!_canControl) return;
    if (ApiService().isConnected) {
      ApiService().sendMoveCommand(_robot.id, 'forward');
      _addLog('CMD SENT: FORWARD (Via WebSocket)');
    } else {
      final rad = _angle * math.pi / 180;
      setState(() {
        _posX = (_posX + 0.5 * math.cos(rad)).clamp(0.0, 25.0);
        _posY = (_posY + 0.5 * math.sin(rad)).clamp(0.0, 20.0);
        _battery = math.max(0, _battery - 1);
      });
      _updateRobotState();
      _addLog('CMD SENT: FORWARD [X: ${_posX.toStringAsFixed(2)}, Y: ${_posY.toStringAsFixed(2)}]');
    }
  }

  void _turnLeft() {
    if (!_canControl) return;
    if (ApiService().isConnected) {
      ApiService().sendMoveCommand(_robot.id, 'rotate_left');
      _addLog('CMD SENT: ROTATE LEFT (Via WebSocket)');
    } else {
      setState(() {
        _angle = _angle - 15;
      });
      _updateRobotState();
      _addLog('CMD SENT: ROTATE LEFT [Angle: ${(_angle.toInt() % 360 + 360) % 360}°]');
    }
  }

  void _turnRight() {
    if (!_canControl) return;
    if (ApiService().isConnected) {
      ApiService().sendMoveCommand(_robot.id, 'rotate_right');
      _addLog('CMD SENT: ROTATE RIGHT (Via WebSocket)');
    } else {
      setState(() {
        _angle = _angle + 15;
      });
      _updateRobotState();
      _addLog('CMD SENT: ROTATE RIGHT [Angle: ${(_angle.toInt() % 360 + 360) % 360}°]');
    }
  }

  void _rotate180() {
    if (!_canControl) return;
    if (ApiService().isConnected) {
      ApiService().sendMoveCommand(_robot.id, 'rotate_right');
      Future.delayed(const Duration(milliseconds: 300), () {
        ApiService().sendMoveCommand(_robot.id, 'rotate_right');
      });
      _addLog('CMD SENT: ROTATE 180° SPIN (Via WebSocket)');
    } else {
      _addLog('CMD SENT: ROTATE 180° SPIN INITIATED');
      setState(() {
        _angle = _angle + 180;
        _battery = math.max(0, _battery - 3);
      });
      _updateRobotState();
      Future.delayed(const Duration(milliseconds: 1000), () {
        _addLog('TELEMETRY: SPIN COMPLETE [Angle: ${(_angle.toInt() % 360 + 360) % 360}°]');
      });
    }
  }

  void _emergencyStop() {
    if (!_robot.isOnline) return;
    setState(() {
      _isEStopped = true;
    });
    _updateRobotState();
    _addLog('CRITICAL: EMERGENCY STOP TRIGGERED!');
    _addLog('CRITICAL: MOTORS DISABLED. SYSTEM STANDBY.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('EMERGENCY STOP ENGAGED'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetEmergencyStop() {
    if (!_robot.isOnline) return;
    setState(() {
      _isEStopped = false;
    });
    _updateRobotState();
    _addLog('SYSTEM: Safety loops reset. System Online.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('EMERGENCY STOP CLEARED. MOTORS RE-ENABLED.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final argRobot = ModalRoute.of(context)?.settings.arguments as Robot?;
      _robot = argRobot ?? sampleRobots[0];
      final coords = _robot.position.split(RegExp(r',\s*'));
      _posX = double.tryParse(coords[0]) ?? 10.0;
      _posY = double.tryParse(coords[1]) ?? 10.0;
      _angle = _robot.angle;
      _battery = _robot.batteryLevel;
      _logs.add('[SYSTEM] Operator attached to unit ${_robot.id}.');
      _logs.add('[SYSTEM] Telemetry link online.');
      
      // Hook up WebSocket updates
      ApiService().addListener(_onTelemetryUpdated);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    ApiService().removeListener(_onTelemetryUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTelemetryUpdated() {
    final updated = sampleRobots.firstWhere((r) => r.id == _robot.id, orElse: () => _robot);
    final coords = updated.position.split(RegExp(r',\s*'));
    final newX = double.tryParse(coords[0]) ?? _posX;
    final newY = double.tryParse(coords[1]) ?? _posY;
    
    if (newX != _posX || newY != _posY) {
      _addLog('TELEMETRY: GPS [X: ${newX.toStringAsFixed(2)}, Y: ${newY.toStringAsFixed(2)}]');
    }
    if (updated.angle != _angle) {
      _addLog('TELEMETRY: HEADING [Angle: ${updated.angle.toInt()}°]');
    }
    if (updated.batteryLevel != _battery) {
      _addLog('TELEMETRY: BATTERY [Level: ${updated.batteryLevel}%]');
    }

    if (mounted) {
      setState(() {
        _robot = updated;
        _posX = newX;
        _posY = newY;
        _angle = updated.angle;
        _battery = updated.batteryLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_robot.name} Control Deck'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: isDark ? const Color(0xff131926) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: isDark ? const Color(0xff090d16) : const Color(0xfff1f5f9),
                                  child: Image.asset(
                                    _robot.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.smart_toy,
                                      color: const Color(0xff2563eb),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _robot.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                  Text('Model ID: ${_robot.id}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xff2563eb).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.battery_charging_full, color: Color(0xff2563eb), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$_battery%',
                                  style: const TextStyle(color: Color(0xff2563eb), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xff090d16) : const Color(0xfff1f5f9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1)),
                        ),
                        child: ClipRect(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                painter: RadarGridPainter(isDark: isDark),
                                child: Container(),
                              ),
                              AnimatedRotation(
                                turns: _angle / 360,
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeInOut,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xff2563eb).withOpacity(0.4), width: 1),
                                  ),
                                  child: const Align(
                                    alignment: Alignment.topCenter,
                                    child: Icon(Icons.navigation, color: Color(0xff2563eb), size: 24),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'COORD VECTOR: [X: ${_posX.toStringAsFixed(2)}, Y: ${_posY.toStringAsFixed(2)}]',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                                      ),
                                    ),
                                    Text(
                                      'ROTATION VECTOR: ${(_angle.toInt() % 360).abs()}°',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
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
              const SizedBox(height: 24),
              
              Text(
                'TACTILE CONTROLS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    children: [
                      // Circular High-Tech Controller Base
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff0b0f19),
                            border: Border.all(color: const Color(0xff55E8FF).withOpacity(0.25), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff55E8FF).withOpacity(0.08),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                            gradient: const RadialGradient(
                              center: Alignment.center,
                              radius: 0.85,
                              colors: [
                                Color(0xff131a2c),
                                Color(0xff090c14),
                              ],
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Crosshair lines
                              Container(
                                width: 1.2,
                                height: 220,
                                color: const Color(0xff55E8FF).withOpacity(0.1),
                              ),
                              Container(
                                width: 220,
                                height: 1.2,
                                color: const Color(0xff55E8FF).withOpacity(0.1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Top Button (Forward)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: InkWell(
                            onTap: _canControl ? _moveForward : null,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _canControl ? const Color(0xff55E8FF).withOpacity(0.12) : const Color(0xff1e293b),
                                border: Border.all(
                                  color: _canControl ? const Color(0xff55E8FF).withOpacity(0.35) : const Color(0xff334155),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: _canControl ? const Color(0xff55E8FF) : const Color(0xff64748b),
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Left Button (Rotate Left)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: InkWell(
                            onTap: _canControl ? _turnLeft : null,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _canControl ? const Color(0xff55E8FF).withOpacity(0.12) : const Color(0xff1e293b),
                                border: Border.all(
                                  color: _canControl ? const Color(0xff55E8FF).withOpacity(0.35) : const Color(0xff334155),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_left_rounded,
                                color: _canControl ? const Color(0xff55E8FF) : const Color(0xff64748b),
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Right Button (Rotate Right)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: InkWell(
                            onTap: _canControl ? _turnRight : null,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _canControl ? const Color(0xff55E8FF).withOpacity(0.12) : const Color(0xff1e293b),
                                border: Border.all(
                                  color: _canControl ? const Color(0xff55E8FF).withOpacity(0.35) : const Color(0xff334155),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: _canControl ? const Color(0xff55E8FF) : const Color(0xff64748b),
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom Button (Rotate 180)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: _canControl ? _rotate180 : null,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _canControl ? const Color(0xff55E8FF).withOpacity(0.12) : const Color(0xff1e293b),
                                border: Border.all(
                                  color: _canControl ? const Color(0xff55E8FF).withOpacity(0.35) : const Color(0xff334155),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.loop_rounded,
                                color: _canControl ? const Color(0xff55E8FF) : const Color(0xff64748b),
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Center Button (E-STOP)
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: _isEStopped ? _resetEmergencyStop : _emergencyStop,
                          borderRadius: BorderRadius.circular(34),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isEStopped ? const Color(0xff065f46) : const Color(0xff991b1b),
                              border: Border.all(
                                color: _isEStopped ? const Color(0xff34d399) : const Color(0xfff87171),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isEStopped ? const Color(0xff34d399).withOpacity(0.3) : const Color(0xfff87171).withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _isEStopped ? 'RESET' : 'STOP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Card(
                color: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TELEMETRY LOG STREAM',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xff2563eb),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _logs.length,
                          itemBuilder: (context, idx) {
                            final log = _logs[idx];
                            final isError = log.contains('CRITICAL') || log.contains('STOP');
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: isError ? Colors.redAccent : (isDark ? const Color(0xff94a3b8) : const Color(0xff475569)),
                                  fontWeight: isError ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          },
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
    );
  }
}

class RadarGridPainter extends CustomPainter {
  final bool isDark;
  RadarGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = isDark ? const Color(0xff1e293b) : const Color(0xff94a3b8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 80, paint);

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), axisPaint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
