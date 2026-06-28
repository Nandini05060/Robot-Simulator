import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/robot.dart';
import 'api_service.dart';

class FleetStateProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  List<Robot> _robots = [];
  Map<String, dynamic> _dashboardData = {};
  WebSocketChannel? _wsChannel;
  bool _isConnecting = false;
  final List<String> _activityLogs = [];

  String? get token => _token;
  List<Robot> get robots => _robots;
  bool get isLoggedIn => _token != null;
  List<String> get activityLogs => _activityLogs;
  
  Map<String, dynamic> get dashboardData {
    if (_dashboardData.isEmpty) {
      // Return local computed stats if not loaded yet
      final total = _robots.length;
      final online = _robots.where((r) => r.isOnline).length;
      final averageBattery = total > 0 
          ? _robots.map((r) => r.batteryLevel).reduce((a, b) => a + b) / total 
          : 0.0;
      return {
        'total_robots': total,
        'online_robots': online,
        'offline_robots': total - online,
        'moving': _robots.where((r) => r.status.toLowerCase() == 'moving' || r.status.toLowerCase() == 'delivering').length,
        'idle': _robots.where((r) => r.status.toLowerCase() == 'idle').length,
        'charging': _robots.where((r) => r.status.toLowerCase() == 'charging').length,
        'average_battery': averageBattery,
      };
    }
    return _dashboardData;
  }

  /// Logs in to the backend and triggers initial data sync
  Future<bool> login(String username, String password) async {
    _token = null;
    _robots = [];
    _activityLogs.clear();
    notifyListeners();

    final token = await _apiService.login(username, password);
    if (token != null) {
      _token = token;
      _log('[AUTH] Logged in as $username successfully.');
      await initialSync();
      return true;
    } else {
      _log('[AUTH] Login failed for user: $username');
      return false;
    }
  }

  /// Syncs fleet and dashboard stats from HTTP REST endpoints, then connects WS
  Future<void> initialSync() async {
    if (_token == null) return;

    final robotsJson = await _apiService.fetchRobots();
    if (robotsJson != null) {
      _robots = robotsJson.map((item) => Robot.fromJson(item)).toList();
      _log('[SYS] Fleet metadata synced (${_robots.length} units).');
    }

    final stats = await _apiService.fetchDashboardData();
    if (stats != null) {
      _dashboardData = stats;
    }

    notifyListeners();
    connectWebSocket();
  }

  /// Connects to the real-time WebSocket telemetry stream
  void connectWebSocket() {
    if (_token == null || _wsChannel != null || _isConnecting) return;

    _isConnecting = true;
    final url = '${ApiService.wsUrl}?token=$_token';
    _log('[WS] Establishing link to telemetry stream...');

    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(url));
      _isConnecting = false;
      _log('[WS] Real-time link established.');

      _wsChannel!.stream.listen(
        (message) {
          _handleWsMessage(message);
        },
        onError: (error) {
          _log('[WS] Telemetry link error: $error');
          _reconnectWS();
        },
        onDone: () {
          _log('[WS] Telemetry link disconnected by host.');
          _reconnectWS();
        },
      );
    } catch (e) {
      _isConnecting = false;
      _log('[WS] Telemetry connection exception: $e');
      _reconnectWS();
    }
  }

  void _reconnectWS() {
    _wsChannel = null;
    // Attempt reconnect after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (_token != null && _wsChannel == null) {
        connectWebSocket();
      }
    });
  }

  /// Handles incoming WebSocket packets
  void _handleWsMessage(dynamic message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final type = data['type'];

      if (type == 'TELEMETRY') {
        final robot = Robot.fromJson(data);
        final index = _robots.indexWhere((r) => r.id == robot.id);

        if (index != -1) {
          _robots[index] = robot;
        } else {
          _robots.add(robot);
        }

        _log('[TELEMETRY] ${robot.name} updated: Pos=[${robot.position}] Batt=${robot.batteryLevel}% Status=${robot.status}');
        
        // Refresh dashboard stats locally
        _updateLocalDashboardStats();
        notifyListeners();
      } else if (type == 'ERROR') {
        _log('[ERROR] Server: ${data['message']}');
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  /// Sends a robot movement command over WebSocket
  void moveRobot(String robotId, String command) {
    if (_wsChannel == null) {
      _log('[WARN] Cannot send command: Telemetry link offline.');
      return;
    }

    final intId = int.tryParse(robotId) ?? 1;
    final payload = {
      'type': 'MOVE',
      'robot_id': intId,
      'payload': {'command': command}
    };

    _wsChannel!.sink.add(jsonEncode(payload));
    _log('[CMD] Sent: MOVE $command for Unit $robotId');
  }

  /// Starts a delivery task for a robot
  void startDelivery(String robotId, int destX, int destY) {
    if (_wsChannel == null) {
      _log('[WARN] Cannot start delivery: Telemetry link offline.');
      return;
    }

    final intId = int.tryParse(robotId) ?? 1;
    final payload = {
      'type': 'START_DELIVERY',
      'robot_id': intId,
      'payload': {
        'destination': {'x': destX, 'y': destY}
      }
    };

    _wsChannel!.sink.add(jsonEncode(payload));
    _log('[CMD] Sent: START_DELIVERY to ($destX, $destY) for Unit $robotId');
  }

  /// Stops/Resets a delivery task
  void stopDelivery(String robotId) {
    if (_wsChannel == null) {
      _log('[WARN] Cannot cancel task: Telemetry link offline.');
      return;
    }

    final intId = int.tryParse(robotId) ?? 1;
    final payload = {
      'type': 'STOP_DELIVERY',
      'robot_id': intId,
    };

    _wsChannel!.sink.add(jsonEncode(payload));
    _log('[CMD] Sent: STOP_DELIVERY for Unit $robotId');
  }

  void logout() {
    _wsChannel?.sink.close();
    _wsChannel = null;
    _token = null;
    _robots = [];
    _dashboardData = {};
    _activityLogs.clear();
    notifyListeners();
  }

  void _updateLocalDashboardStats() {
    final total = _robots.length;
    final online = _robots.where((r) => r.isOnline).length;
    final moving = _robots.where((r) => r.status.toLowerCase() == 'moving' || r.status.toLowerCase() == 'delivering').length;
    final idle = _robots.where((r) => r.status.toLowerCase() == 'idle').length;
    final charging = _robots.where((r) => r.status.toLowerCase() == 'charging').length;
    final averageBattery = total > 0 
        ? _robots.map((r) => r.batteryLevel).reduce((a, b) => a + b) / total 
        : 0.0;

    _dashboardData = {
      'total_robots': total,
      'online_robots': online,
      'offline_robots': total - online,
      'moving': moving,
      'idle': idle,
      'charging': charging,
      'average_battery': double.parse(averageBattery.toStringAsFixed(2)),
    };
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _activityLogs.insert(0, '[$timestamp] $message');
    if (_activityLogs.length > 50) {
      _activityLogs.removeLast();
    }
  }
}
