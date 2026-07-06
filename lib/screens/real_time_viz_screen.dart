import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/robot.dart';
import '../services/api_service.dart';

class RealTimeVizScreen extends StatefulWidget {
  const RealTimeVizScreen({Key? key}) : super(key: key);

  @override
  State<RealTimeVizScreen> createState() => _RealTimeVizScreenState();
}

class _RealTimeVizScreenState extends State<RealTimeVizScreen> {
  Robot? _robot;
  bool _isInitialized = false;

  // Live state variables
  late double _currentX;
  late double _currentY;
  double _angle = 0.0;
  late int _battery;
  late String _status;
  double _speed = 0.8;
  String _direction = 'North-East';
  final List<Offset> _trail = [];
  
  // Simulation and controls
  Timer? _simulationTimer;
  bool _isManualOverride = false;
  final List<String> _activityLog = [];

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
  int _currentPathIndex = 0;

  // Auto Navigation destination states
  double? _startX;
  double? _startY;
  double? _destX;
  double? _destY;
  bool _settingStart = false;
  bool _settingDestination = false;
  bool _autoNavActive = false;
  bool _showManualController = true;
  List<Offset> _navPath = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Robot) {
        _robot = args;
      } else {
        _robot = sampleRobots[0]; // fallback
      }

      _status = _robot!.status;
      _battery = _robot!.batteryLevel;

      // Parse coordinates from robot position (e.g. "12.4, 8.2")
      try {
        final parts = _robot!.position.split(RegExp(r',\s*'));
        _currentX = double.parse(parts[0]);
        _currentY = double.parse(parts[1]);
      } catch (e) {
        _currentX = 4.0;
        _currentY = 4.0;
      }

      if (_robot!.isOnline) {
        _currentX = _navigationPath[0].x;
        _currentY = _navigationPath[0].y;
        _currentPathIndex = 0;
        _angle = 180.0; // Point South towards nextPoint
        _updateDirection(_angle);
      }

      _trail.add(Offset(_currentX, _currentY));
      _activityLog.add('[SYS] Telemetry link established for ${_robot!.name}');
      _activityLog.add('[SYS] Operating Mode: ${_robot!.isOnline ? "Nominal Autonav" : "Offline / Offline Mode"}');
      if (!_robot!.isOnline) {
        _speed = 0.0;
        _activityLog.add('[WARN] Unit is offline. Remote controls locked.');
      }

      // If WebSocket is connected, hook up updates instead of local simulation
      if (ApiService().isConnected) {
        ApiService().addListener(_onTelemetryUpdated);
        _activityLog.add('[SYS] Connected to Live Telemetry server.');
      } else {
        if (_robot!.isOnline) {
          _startSimulation();
        }
      }

      _isInitialized = true;
    }
  }

  void _onTelemetryUpdated() {
    if (_robot == null) return;
    final updated = sampleRobots.firstWhere((r) => r.id == _robot!.id, orElse: () => _robot!);
    final coords = updated.position.split(RegExp(r',\s*'));
    final newX = double.tryParse(coords[0]) ?? _currentX;
    final newY = double.tryParse(coords[1]) ?? _currentY;

    if (newX != _currentX || newY != _currentY) {
      _logAction('GPS updated: [${newX.toStringAsFixed(1)}, ${newY.toStringAsFixed(1)}]');
    }
    if (updated.angle != _angle) {
      _logAction('Heading updated: ${updated.angle.toInt()}°');
    }

    if (mounted) {
      setState(() {
        _robot = updated;
        _currentX = newX;
        _currentY = newY;
        _angle = updated.angle;
        _battery = updated.batteryLevel;
        _status = updated.status;
        _speed = updated.isOnline ? 0.8 : 0.0;
        
        if (updated.autoNavigation) {
          _startX = updated.startX;
          _startY = updated.startY;
          _destX = updated.destinationX;
          _destY = updated.destinationY;
          _autoNavActive = true;
        } else if (_autoNavActive && !updated.autoNavigation) {
          _autoNavActive = false;
        }
        
        _trail.add(Offset(_currentX, _currentY));
        if (_trail.length > 8) {
          _trail.removeAt(0);
        }
      });
    }
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || _isManualOverride || _status == 'E-STOPPED') return;

      setState(() {
        _currentPathIndex = (_currentPathIndex + 1) % _navigationPath.length;
        final nextPoint = _navigationPath[_currentPathIndex];

        final dx = nextPoint.x - _currentX;
        final dy = nextPoint.y - _currentY;
        if (dx != 0 || dy != 0) {
          final targetAngle = (math.atan2(dy, dx) * 180 / math.pi) + 90;
          double diff = (targetAngle - _angle) % 360;
          if (diff > 180) diff -= 360;
          _angle = _angle + diff;
          
          _updateDirection(_angle);
        }

        _currentX = nextPoint.x;
        _currentY = nextPoint.y;
        _battery = math.max(10, _battery - 1);

        _trail.add(Offset(_currentX, _currentY));
        if (_trail.length > 8) {
          _trail.removeAt(0);
        }

        _updateRobotState();
        _logAction('Autonav route point $_currentPathIndex reached. GPS: [${_currentX.toStringAsFixed(1)}, ${_currentY.toStringAsFixed(1)}]');
      });
    });
  }

  void _updateRobotState() {
    if (_robot == null) return;
    final index = sampleRobots.indexWhere((r) => r.id == _robot!.id);
    if (index != -1) {
      sampleRobots[index] = sampleRobots[index].copyWith(
        position: '${_currentX.toStringAsFixed(2)}, ${_currentY.toStringAsFixed(2)}',
        angle: (_angle % 360 + 360) % 360,
        batteryLevel: _battery,
        status: _status,
      );
    }
  }

  void _updateDirection(double angle) {
    double normAngle = (angle % 360 + 360) % 360;
    if (normAngle >= 337.5 || normAngle < 22.5) {
      _direction = 'North';
    } else if (normAngle >= 22.5 && normAngle < 67.5) {
      _direction = 'North-East';
    } else if (normAngle >= 67.5 && normAngle < 112.5) {
      _direction = 'East';
    } else if (normAngle >= 112.5 && normAngle < 157.5) {
      _direction = 'South-East';
    } else if (normAngle >= 157.5 && normAngle < 202.5) {
      _direction = 'South';
    } else if (normAngle >= 202.5 && normAngle < 247.5) {
      _direction = 'South-West';
    } else if (normAngle >= 247.5 && normAngle < 292.5) {
      _direction = 'West';
    } else if (normAngle >= 292.5 && normAngle < 337.5) {
      _direction = 'North-West';
    } else {
      _direction = 'Idle';
    }
  }

  void _logAction(String action) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _activityLog.add('[$timestamp] $action');
    if (_activityLog.length > 25) {
      _activityLog.removeAt(0);
    }
  }

  void _triggerManualMove(double dx, double dy, String dirName) {
    if (_status == 'E-STOPPED' || !_robot!.isOnline) return;

    if (_autoNavActive) {
      _stopAutoNavigation();
    }

    if (ApiService().isConnected) {
      String command = "forward";
      if (dx == 0 && dy < 0) command = "forward";
      else if (dx == 0 && dy > 0) command = "backward";
      else if (dx < 0 && dy == 0) command = "rotate_left";
      else if (dx > 0 && dy == 0) command = "rotate_right";

      ApiService().sendMoveCommand(_robot!.id, command);
      _logAction('CMD: Manual Override -> Move $dirName (WebSocket)');
      setState(() {
        _isManualOverride = true;
      });
      return;
    }

    setState(() {
      _isManualOverride = true;
      _currentX = (_currentX + dx).clamp(2.0, 23.0);
      _currentY = (_currentY + dy).clamp(2.0, 18.0);
      
      final double newAngle = (math.atan2(dy, dx) * 180 / math.pi) + 90;
      double diff = (newAngle - _angle) % 360;
      if (diff > 180) diff -= 360;
      _angle = _angle + diff;
      
      _updateDirection(_angle);
      _speed = 0.8;
      _trail.add(Offset(_currentX, _currentY));
      if (_trail.length > 8) {
        _trail.removeAt(0);
      }
      _updateRobotState();
      _logAction('CMD: Manual Override -> Move $dirName');
    });
  }

  void _rotate180() {
    if (_status == 'E-STOPPED' || !_robot!.isOnline) return;
    if (_autoNavActive) {
      _stopAutoNavigation();
    }
    if (ApiService().isConnected) {
      ApiService().sendMoveCommand(_robot!.id, "rotate_right");
      Future.delayed(const Duration(milliseconds: 300), () {
        ApiService().sendMoveCommand(_robot!.id, "rotate_right");
      });
      _logAction('CMD: Rotate 180° (WebSocket)');
      setState(() {
        _isManualOverride = true;
      });
      return;
    }

    setState(() {
      _isManualOverride = true;
      _angle = _angle + 180;
      _updateRobotState();
      _logAction('CMD: Rotate 180° Initiated');
    });
  }

  Future<void> _recalculatePath() async {
    if (_startX != null && _destX != null) {
      final path = await compute(_astarIsolate, {
        'startX': _startX!,
        'startY': _startY!,
        'goalX': _destX!,
        'goalY': _destY!,
      });
      if (mounted) {
        setState(() {
          _navPath = path;
        });
      }
    } else {
      setState(() {
        _navPath = [];
      });
    }
  }

  Future<void> _startAutoNavigation() async {
    if (_startX == null || _destX == null) return;
    
    setState(() {
      _autoNavActive = true;
      _isManualOverride = false;
      _status = 'Auto Navigating';
    });
    
    _logAction('Auto Nav: [${_startX!.toStringAsFixed(1)}, ${_startY!.toStringAsFixed(1)}] -> [${_destX!.toStringAsFixed(1)}, ${_destY!.toStringAsFixed(1)}]');
    
    if (ApiService().isConnected) {
      ApiService().sendStartAuto(_robot!.id, _startX!, _startY!, _destX!, _destY!);
      return;
    }
    
    // Offline simulation mode
    _simulationTimer?.cancel();
    
    setState(() {
      _currentX = _startX!;
      _currentY = _startY!;
      _trail.clear();
      _trail.add(Offset(_currentX, _currentY));
    });

    final path = await compute(_astarIsolate, {
      'startX': _currentX,
      'startY': _currentY,
      'goalX': _destX!,
      'goalY': _destY!,
    });
    int pathIndex = 0;
    
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted || _isManualOverride || !_autoNavActive) {
        timer.cancel();
        return;
      }
      
      if (pathIndex >= path.length) {
        setState(() {
          _autoNavActive = false;
          _status = 'Idle';
          _logAction('Auto Nav: Destination Reached!');
        });
        timer.cancel();
        return;
      }
      
      setState(() {
        final target = path[pathIndex];
        double dx = target.dx - _currentX;
        double dy = target.dy - _currentY;
        double distance = math.sqrt(dx * dx + dy * dy);
        
        final stepSize = _speed * 0.5;
        
        if (distance <= stepSize) {
          _currentX = target.dx;
          _currentY = target.dy;
          pathIndex++;
        } else {
          _currentX += (dx / distance) * stepSize;
          _currentY += (dy / distance) * stepSize;
          
          if (dx.abs() > dy.abs()) {
            _angle = dx > 0 ? 90.0 : 270.0;
          } else {
            _angle = dy > 0 ? 180.0 : 0.0;
          }
        }
        
        _updateDirection(_angle);
        _battery = math.max(10, _battery - 1);
        _trail.add(Offset(_currentX, _currentY));
        if (_trail.length > 25) {
          _trail.removeAt(0);
        }
        _updateRobotState();
      });
    });
  }

  void _stopAutoNavigation() {
    setState(() {
      _autoNavActive = false;
      _status = 'Idle';
    });
    _logAction('Auto Nav: Stopped by user.');
    if (ApiService().isConnected) {
      ApiService().sendStopAuto(_robot!.id);
    } else {
      _simulationTimer?.cancel();
    }
  }

  void _emergencyStop() {
    setState(() {
      _status = 'E-STOPPED';
      _speed = 0.0;
      _isManualOverride = true;
      _updateRobotState();
      _logAction('[ALERT] EMERGENCY BRAKE ENGAGED! ALL MOTORS POWER OFF.');
    });
  }

  @override
  void dispose() {
    if (ApiService().isConnected) {
      ApiService().removeListener(_onTelemetryUpdated);
    }
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Robot robot = _robot ?? sampleRobots[0];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
      appBar: AppBar(
        title: Text('Monitoring: ${robot.name}'),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xff131926) : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _status == 'E-STOPPED' 
                  ? Colors.red.withOpacity(0.15) 
                  : const Color(0xff2563eb).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: _status == 'E-STOPPED' 
                      ? Colors.red 
                      : robot.isOnline ? const Color(0xff10b981) : Colors.grey,
                  size: 10,
                ),
                const SizedBox(width: 6),
                Text(
                  _status.toUpperCase(),
                  style: TextStyle(
                    color: _status == 'E-STOPPED' ? Colors.red : const Color(0xff2563eb),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // A. Large Office Map Viewport
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff0b0f19) : const Color(0xffcbd5e1).withOpacity(0.3),
                image: const DecorationImage(
                  image: AssetImage('assets/map_6.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double mapWidth = constraints.maxWidth;
                    final double mapHeight = constraints.maxHeight;
                    
                    final double robotX = 8 + (_currentX / 25) * (mapWidth - 16);
                    final double robotY = 8 + (_currentY / 20) * (mapHeight - 16);

                    double? startPixelX = _startX != null ? 8 + (_startX! / 25) * (mapWidth - 16) : null;
                    double? startPixelY = _startY != null ? 8 + (_startY! / 20) * (mapHeight - 16) : null;
                    double? destPixelX = _destX != null ? 8 + (_destX! / 25) * (mapWidth - 16) : null;
                    double? destPixelY = _destY != null ? 8 + (_destY! / 20) * (mapHeight - 16) : null;

                    return GestureDetector(
                      onTapUp: (details) {
                        if (!_settingStart && !_settingDestination) return;
                        final double tapX = details.localPosition.dx;
                        final double tapY = details.localPosition.dy;
                        
                        final double mapX = (((tapX - 8) / (mapWidth - 16)) * 25).clamp(0.0, 25.0);
                        final double mapY = (((tapY - 8) / (mapHeight - 16)) * 20).clamp(0.0, 20.0);
                        
                        setState(() {
                          if (_settingStart) {
                            _startX = mapX;
                            _startY = mapY;
                            _settingStart = false;
                            _logAction('Set Start to [${mapX.toStringAsFixed(1)}, ${mapY.toStringAsFixed(1)}]');
                          } else if (_settingDestination) {
                            _destX = mapX;
                            _destY = mapY;
                            _settingDestination = false;
                            _logAction('Set Target to [${mapX.toStringAsFixed(1)}, ${mapY.toStringAsFixed(1)}]');
                          }
                          _recalculatePath();
                        });
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: OfficeMapPainter(isDark: isDark),
                            ),
                          ),
                          if (_startX != null && _destX != null)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: ConnectorLinePainter(
                                  path: _navPath,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: TrailPainter(trail: _trail, isDark: isDark),
                            ),
                          ),
                          if (startPixelX != null && startPixelY != null)
                            Positioned(
                              left: startPixelX - 12,
                              top: startPixelY - 24,
                              width: 24,
                              height: 24,
                              child: const Icon(Icons.location_on, color: Colors.green, size: 24),
                            ),
                          if (destPixelX != null && destPixelY != null)
                            Positioned(
                              left: destPixelX - 12,
                              top: destPixelY - 24,
                              width: 24,
                              height: 24,
                              child: const Icon(Icons.flag, color: Colors.red, size: 24),
                            ),
                          Positioned(
                            left: robotX - 18,
                            top: robotY - 18,
                            width: 36,
                            height: 36,
                            child: PulsingRobotIndicator(angle: _angle),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Card(
                              color: isDark ? const Color(0xff131926).withOpacity(0.85) : Colors.white.withOpacity(0.9),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.gps_fixed, color: Color(0xff2563eb), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'GPS: [${_currentX.toStringAsFixed(2)}, ${_currentY.toStringAsFixed(2)}]${_startX != null && _destX != null ? " | Path: [${_startX!.toStringAsFixed(1)}, ${_startY!.toStringAsFixed(1)}] -> [${_destX!.toStringAsFixed(1)}, ${_destY!.toStringAsFixed(1)}]" : ""}',
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 70,
                            child: Column(
                              children: [
                                _buildFloatingMapBtn(
                                  icon: Icons.pin_drop,
                                  color: _settingStart ? Colors.green : Colors.grey,
                                  onPressed: () {
                                    setState(() {
                                      _settingStart = !_settingStart;
                                      _settingDestination = false;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildFloatingMapBtn(
                                  icon: Icons.flag,
                                  color: _settingDestination ? Colors.red : Colors.grey,
                                  onPressed: () {
                                    setState(() {
                                      _settingDestination = !_settingDestination;
                                      _settingStart = false;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                if (_startX != null && _destX != null)
                                  _buildFloatingMapBtn(
                                    icon: _autoNavActive ? Icons.stop : Icons.play_arrow,
                                    color: _autoNavActive ? Colors.orange : const Color(0xff2563eb),
                                    onPressed: _autoNavActive ? _stopAutoNavigation : _startAutoNavigation,
                                  ),
                                const SizedBox(height: 8),
                                _buildFloatingMapBtn(
                                  icon: Icons.gamepad,
                                  color: _showManualController ? const Color(0xff2563eb) : Colors.grey,
                                  onPressed: () {
                                    setState(() {
                                      _showManualController = !_showManualController;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // B. Details, Controls, and Activity Log Panel
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff131926) : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1), width: 1.5),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildCircularMetricTile(
                            'BATTERY',
                            '$_battery%',
                            _battery / 100.0,
                            const Color(0xff10b981),
                            Icons.battery_charging_full,
                          ),
                        ),
                        Expanded(
                          child: _buildCircularMetricTile(
                            'VELOCITY',
                            '${_speed.toStringAsFixed(1)} m/s',
                            _speed / 2.0,
                            const Color(0xff14b8a6),
                            Icons.speed,
                          ),
                        ),
                        Expanded(
                          child: _buildCompassMetricTile(
                            'HEADING',
                            _direction,
                            _angle,
                            const Color(0xff8b5cf6),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (_showManualController) ...[
                      // 2. Control Panel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Manual Override Controls',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (_isManualOverride)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isManualOverride = false;
                                  if (_status == 'E-STOPPED') {
                                    _status = 'Online';
                                  }
                                  _speed = 0.8;
                                  _updateRobotState();
                                  _logAction('CMD: Resume Autonomous Navigation');
                                });
                              },
                              icon: const Icon(Icons.play_arrow, size: 16, color: Color(0xff2563eb)),
                              label: const Text(
                                'Resume Auto',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff2563eb)),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                backgroundColor: const Color(0xff2563eb).withOpacity(0.08),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Joystick D-Pad Layout
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xff0b0f19),
                                  border: Border.all(color: const Color(0xff55E8FF).withOpacity(0.25), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff55E8FF).withOpacity(0.08),
                                      blurRadius: 12,
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
                                      height: 120,
                                      color: const Color(0xff55E8FF).withOpacity(0.1),
                                    ),
                                    Container(
                                      width: 120,
                                      height: 1.2,
                                      color: const Color(0xff55E8FF).withOpacity(0.1),
                                    ),
                                    // Central glowing joystick nub
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xff0e1320),
                                        border: Border.all(color: const Color(0xff55E8FF).withOpacity(0.4), width: 1.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xff55E8FF).withOpacity(0.15),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.circle, size: 8, color: Color(0xff55E8FF)),
                                      ),
                                    ),
                                    // D-Pad Buttons
                                    Positioned(
                                      top: 0,
                                      left: 46,
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: IconButton(
                                          onPressed: () => _triggerManualMove(0, -0.8, 'Forward'),
                                          icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 28),
                                          color: const Color(0xff55E8FF),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                                          splashRadius: 24,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 46,
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: IconButton(
                                          onPressed: () => _triggerManualMove(0, 0.8, 'Backward'),
                                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                                          color: const Color(0xff55E8FF),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                                          splashRadius: 24,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 46,
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: IconButton(
                                          onPressed: () => _triggerManualMove(-0.8, 0, 'Left'),
                                          icon: const Icon(Icons.keyboard_arrow_left_rounded, size: 28),
                                          color: const Color(0xff55E8FF),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                                          splashRadius: 24,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 46,
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: IconButton(
                                          onPressed: () => _triggerManualMove(0.8, 0, 'Right'),
                                          icon: const Icon(Icons.keyboard_arrow_right_rounded, size: 28),
                                          color: const Color(0xff55E8FF),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                                          splashRadius: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Quick Action Buttons
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _rotate180,
                                    icon: const Icon(Icons.cached, size: 16),
                                    label: const Text('Rotate 180°', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xff55E8FF),
                                      side: BorderSide(color: const Color(0xff55E8FF).withOpacity(0.35)),
                                      backgroundColor: const Color(0xff0f172a).withOpacity(0.65),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _emergencyStop,
                                    icon: const Icon(Icons.warning_amber_rounded, size: 16),
                                    label: const Text('EMERGENCY STOP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff991b1b),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 4,
                                      shadowColor: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                    ],

                    // 3. Activity Log Console
                    const Text(
                      'Live Activity Feed',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: _activityLog.length,
                        itemBuilder: (context, index) {
                          final log = _activityLog[_activityLog.length - 1 - index];
                          
                          // Extract timestamp if format matches [12:34:56]
                          String time = '';
                          String text = log;
                          final match = RegExp(r'^\[([\d:]+)\]\s*(.*)').firstMatch(log);
                          if (match != null) {
                            time = match.group(1) ?? '';
                            text = match.group(2) ?? '';
                          } else {
                            time = DateTime.now().toString().substring(11, 19);
                          }

                          final isError = log.contains('ALERT') || log.contains('WARN') || log.contains('EMERGENCY');
                          final isCmd = log.contains('CMD');
                          
                          Color dotColor = const Color(0xff2563eb);
                          if (isError) {
                            dotColor = Colors.red;
                          } else if (isCmd) {
                            dotColor = const Color(0xff14b8a6);
                          } else if (log.contains('reached') || log.contains('initialized') || log.contains('link')) {
                            dotColor = const Color(0xff10b981);
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 58,
                                child: Text(
                                  time,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: dotColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: dotColor.withOpacity(0.4),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1.5,
                                    height: 22,
                                    color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xff0f172a),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularMetricTile(String label, String value, double percent, Color activeColor, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCompassMetricTile(String label, String value, double angle, Color activeColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: activeColor.withOpacity(0.15), width: 2.0),
                color: activeColor.withOpacity(0.04),
              ),
            ),
            AnimatedRotation(
              turns: angle / 360,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: Icon(Icons.navigation, color: activeColor, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFloatingMapBtn({required IconData icon, required Color color, required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff131926).withOpacity(0.9) : Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}

class ConnectorLinePainter extends CustomPainter {
  final List<Offset> path;
  final bool isDark;

  ConnectorLinePainter({required this.path, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xff2563eb).withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double mapWidth = size.width;
    final double mapHeight = size.height;
    
    for (int i = 0; i < path.length - 1; i++) {
      final double p1x = 8 + (path[i].dx / 25) * (mapWidth - 16);
      final double p1y = 8 + (path[i].dy / 20) * (mapHeight - 16);
      
      final double p2x = 8 + (path[i+1].dx / 25) * (mapWidth - 16);
      final double p2y = 8 + (path[i+1].dy / 20) * (mapHeight - 16);

      final p1 = Offset(p1x, p1y);
      final p2 = Offset(p2x, p2y);

      final distance = (p2 - p1).distance;
      final int dashCount = (distance / 6).floor();
      
      for (int j = 0; j < dashCount; j++) {
        if (j % 2 == 0) {
          final double t1 = j / dashCount;
          final double t2 = (j + 1) / dashCount;
          canvas.drawLine(
            Offset.lerp(p1, p2, t1)!,
            Offset.lerp(p1, p2, t2)!,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Office Map Custom Painter
class OfficeMapPainter extends CustomPainter {
  final bool isDark;
  OfficeMapPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = isDark ? const Color(0xff131926).withOpacity(0.2) : Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);

    // Simulated conference room
    final confRoom = Rect.fromLTWH(8, 8, size.width * 0.35, size.height * 0.35);
    canvas.drawRect(confRoom, paint);
    
    // Server room
    final serverRoom = Rect.fromLTWH(size.width * 0.65, 8, size.width * 0.3, size.height * 0.45);
    canvas.drawRect(serverRoom, paint);

    // Break room
    final breakRoom = Rect.fromLTWH(8, size.height * 0.65, size.width * 0.35, size.height * 0.3);
    canvas.drawRect(breakRoom, paint);

    // Doors/Hallway lines
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.55, size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.5),
      Offset(size.width * 0.55, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Trail Painter
class TrailPainter extends CustomPainter {
  final List<Offset> trail;
  final bool isDark;
  TrailPainter({required this.trail, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xff3b82f6).withOpacity(0.5)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final startPt = _getPixelOffset(trail[0], size);
    path.moveTo(startPt.dx, startPt.dy);

    for (int i = 1; i < trail.length; i++) {
      final pt = _getPixelOffset(trail[i], size);
      path.lineTo(pt.dx, pt.dy);
    }

    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = const Color(0xff2563eb)
      ..style = PaintingStyle.fill;
      
    for (var offset in trail) {
      final pixel = _getPixelOffset(offset, size);
      canvas.drawCircle(pixel, 4.0, dotPaint);
    }
  }

  Offset _getPixelOffset(Offset pt, Size size) {
    final double px = 8 + (pt.dx / 25) * (size.width - 16);
    final double py = 8 + (pt.dy / 20) * (size.height - 16);
    return Offset(px, py);
  }

  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) => true;
}

// Pulsing Robot Indicator
class PulsingRobotIndicator extends StatefulWidget {
  final double angle;
  const PulsingRobotIndicator({Key? key, required this.angle}) : super(key: key);

  @override
  State<PulsingRobotIndicator> createState() => _PulsingRobotIndicatorState();
}

class _PulsingRobotIndicatorState extends State<PulsingRobotIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 8.0, end: 18.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _pulseAnimation.value * 2,
              height: _pulseAnimation.value * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff2563eb).withOpacity((18.0 - _pulseAnimation.value) / 18.0 * 0.4),
              ),
            ),
            AnimatedRotation(
              turns: widget.angle / 360,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff2563eb),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
                  ],
                ),
                child: const Icon(
                  Icons.navigation,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Top-level function for computing A* in a background Isolate
List<Offset> _astarIsolate(Map<String, double> params) {
  final startX = params['startX']!;
  final startY = params['startY']!;
  final goalX = params['goalX']!;
  final goalY = params['goalY']!;

  final start = Offset(startX, startY);
  final goal = Offset(goalX, goalY);

  final grid = List.generate(25, (_) => List.generate(20, (_) => 0));

  // Populate boundary walls
  for (int x = 0; x < 25; x++) {
    grid[x][0] = 1;
    grid[x][19] = 1;
  }
  for (int y = 0; y < 20; y++) {
    grid[0][y] = 1;
    grid[24][y] = 1;
  }

  // Populate horizontal partition wall at y=11 (Doors at x=9 and x=14)
  for (int x = 0; x < 25; x++) {
    if (x != 9 && x != 14) {
      grid[x][11] = 1;
    }
  }

  // Populate vertical partition wall at x=12 from y=11 to 20
  for (int y = 11; y < 20; y++) {
    grid[12][y] = 1;
  }

  // Populate vertical wall for left rooms at x=5 from y=0 to 11 (Door at y=3)
  for (int y = 0; y < 11; y++) {
    if (y != 3) {
      grid[5][y] = 1;
    }
  }

  // Populate horizontal wall at y=6 from x=0 to 5
  for (int x = 0; x < 6; x++) {
    grid[x][6] = 1;
  }

  // Populate office desks and chairs (obstacles)
  for (int y = 1; y < 10; y++) {
    grid[15][y] = 1;
    grid[13][y] = 1;
    grid[17][y] = 1;
  }

  for (int y in [3, 6, 9]) {
    grid[22][y] = 1;
    grid[23][y] = 1;
  }

  for (int x = 0; x < 5; x++) {
    grid[x][2] = 1;
  }

  math.Point<int> findClosestFree(math.Point<int> pt) {
    if (grid[pt.x][pt.y] == 0) return pt;
    final queue = <math.Point<int>>[pt];
    final visited = <math.Point<int>>{pt};
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (grid[current.x][current.y] == 0) return current;
      for (final dir in [
        const math.Point(-1, 0), const math.Point(1, 0), const math.Point(0, -1), const math.Point(0, 1),
        const math.Point(-1, -1), const math.Point(1, 1), const math.Point(-1, 1), const math.Point(1, -1)
      ]) {
        final nx = current.x + dir.x;
        final ny = current.y + dir.y;
        if (nx >= 0 && nx < 25 && ny >= 0 && ny < 20) {
          final neighbor = math.Point(nx, ny);
          if (!visited.contains(neighbor)) {
            visited.add(neighbor);
            queue.add(neighbor);
          }
        }
      }
    }
    return pt;
  }

  final startPt = findClosestFree(math.Point(start.dx.round().clamp(0, 24), start.dy.round().clamp(0, 19)));
  final goalPt = findClosestFree(math.Point(goal.dx.round().clamp(0, 24), goal.dy.round().clamp(0, 19)));

  // A* Search
  final openSet = <math.Point<int>>[startPt];
  final cameFrom = <math.Point<int>, math.Point<int>>{};
  final gScore = <math.Point<int>, double>{startPt: 0.0};
  final fScore = <math.Point<int>, double>{
    startPt: math.sqrt(math.pow(startPt.x - goalPt.x, 2) + math.pow(startPt.y - goalPt.y, 2))
  };

  while (openSet.isNotEmpty) {
    openSet.sort((a, b) => (fScore[a] ?? 999999.0).compareTo(fScore[b] ?? 999999.0));
    final current = openSet.removeAt(0);

    if (current == goalPt) {
      final path = <Offset>[];
      var curr = current;
      path.add(Offset(curr.x.toDouble(), curr.y.toDouble()));
      while (cameFrom.containsKey(curr)) {
        curr = cameFrom[curr]!;
        path.insert(0, Offset(curr.x.toDouble(), curr.y.toDouble()));
      }
      return path;
    }

    final directions = [
      const math.Point(-1, 0), const math.Point(1, 0), const math.Point(0, -1), const math.Point(0, 1),
      const math.Point(-1, -1), const math.Point(1, 1), const math.Point(-1, 1), const math.Point(1, -1)
    ];

    for (final dir in directions) {
      final neighbor = math.Point(current.x + dir.x, current.y + dir.y);
      if (neighbor.x >= 0 && neighbor.x < 25 && neighbor.y >= 0 && neighbor.y < 20 && grid[neighbor.x][neighbor.y] == 0) {
        // Prevent corner cutting
        if (dir.x != 0 && dir.y != 0) {
          if (grid[current.x + dir.x][current.y] != 0 || grid[current.x][current.y + dir.y] != 0) {
            continue;
          }
        }
        final double moveCost = (dir.x != 0 && dir.y != 0) ? 1.414 : 1.0;
        final tentativeG = (gScore[current] ?? 999999.0) + moveCost;
        if (tentativeG < (gScore[neighbor] ?? 999999.0)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeG;
          final double hCost = math.sqrt(math.pow(neighbor.x - goalPt.x, 2) + math.pow(neighbor.y - goalPt.y, 2));
          fScore[neighbor] = tentativeG + hCost;
          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }
  }

  return [start, goal];
}
