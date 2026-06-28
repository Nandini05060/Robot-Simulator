import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  // Determine backend URL depending on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the Android Emulator gateway pointing to the developer host loopback
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  static String get wsUrl {
    final host = baseUrl.replaceFirst('http://', '').replaceFirst('https://', '');
    return 'ws://$host/ws';
  }

  /// Sends login credentials to the backend. Returns JWT access token if successful.
  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('ApiService login error: $e');
      return null;
    }
  }

  /// Fetches the current list of robots in the fleet
  Future<List<Map<String, dynamic>>?> fetchRobots() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/robots'));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('ApiService fetchRobots error: $e');
    }
    return null;
  }

  /// Fetches aggregated dashboard telemetry metrics
  Future<Map<String, dynamic>?> fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('ApiService fetchDashboardData error: $e');
    }
    return null;
  }
}
