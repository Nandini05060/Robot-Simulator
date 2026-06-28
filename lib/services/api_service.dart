import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import '../models/robot.dart';

class ApiService extends ChangeNotifier {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  IOWebSocketChannel? _wsChannel;
  bool _isConnected = false;

  String get baseUrl => "https://robot-simulator.onrender.com";
  String get wsUrl => "wss://robot-simulator.onrender.com";

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  bool get isConnected => _isConnected;

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        await fetchRobots();
        _connectWebSocket();
        return true;
      }
    } catch (e) {
      print("Login error: $e");
    }
    return false;
  }

  Future<void> fetchRobots() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/robots'))
          .timeout(const Duration(seconds: 35));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var item in data) {
          final idStr = item['id'].toString();
          final index = sampleRobots.indexWhere((r) {
            final rInt = int.tryParse(r.id.replaceAll(RegExp(r'\D'), ''));
            final idInt = int.tryParse(idStr.replaceAll(RegExp(r'\D'), ''));
            return r.id == idStr || (rInt != null && idInt != null && rInt == idInt);
          });
          if (index != -1) {
            sampleRobots[index] = sampleRobots[index].copyWith(
              status: item['is_online'] == true ? 'Online' : 'Offline',
              batteryLevel: item['battery'] ?? 100,
              position: "${item['x'] ?? 0.0}, ${item['y'] ?? 0.0}",
              angle: (item['angle'] ?? 0).toDouble(),
              lastActivity: item['current_task'] ?? 'Idle',
            );
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print("Fetch robots error: $e");
    }
  }

  void _connectWebSocket() {
    if (_token == null) return;
    try {
      _wsChannel = IOWebSocketChannel.connect(
        Uri.parse('$wsUrl/ws?token=$_token'),
      );
      _isConnected = true;
      _wsChannel!.stream.listen((message) {
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          if (data['type'] == 'TELEMETRY') {
            final idStr = data['robot_id'].toString();
            final index = sampleRobots.indexWhere((r) {
              final rInt = int.tryParse(r.id.replaceAll(RegExp(r'\D'), ''));
              final idInt = int.tryParse(idStr.replaceAll(RegExp(r'\D'), ''));
              return r.id == idStr || (rInt != null && idInt != null && rInt == idInt);
            });
            if (index != -1) {
              sampleRobots[index] = sampleRobots[index].copyWith(
                status: data['online'] == true ? 'Online' : 'Offline',
                batteryLevel: data['battery'] ?? 100,
                position: "${data['position']['x'] ?? 0.0}, ${data['position']['y'] ?? 0.0}",
                angle: (data['angle'] ?? 0).toDouble(),
                lastActivity: data['current_task'] ?? 'Active',
              );
              notifyListeners();
            }
          }
        } catch (e) {
          print("Error parsing WebSocket telemetry: $e");
        }
      }, onDone: () {
        _isConnected = false;
        print("WebSocket closed. Reconnecting...");
        Future.delayed(const Duration(seconds: 5), () {
          if (_token != null) _connectWebSocket();
        });
      }, onError: (e) {
        _isConnected = false;
        print("WebSocket error: $e");
      });
    } catch (e) {
      _isConnected = false;
      print("WebSocket connect error: $e");
    }
  }

  void sendMoveCommand(String robotId, String command) {
    if (_wsChannel == null || !_isConnected) return;
    final msg = {
      "type": "MOVE",
      "robot_id": robotId,
      "payload": {
        "command": command // forward, backward, rotate_left, rotate_right
      }
    };
    _wsChannel!.sink.add(jsonEncode(msg));
  }

  void logout() {
    _token = null;
    _isConnected = false;
    _wsChannel?.sink.close();
    _wsChannel = null;
  }
}
