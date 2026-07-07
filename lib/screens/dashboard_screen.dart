import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main_navigation_shell.dart';
import '../services/api_service.dart';

import 'dart:math' as math;
import '../widgets/animated_tap_scale.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _totalRobots = 5;
  int _onlineRobots = 4;
  double _averageBattery = 100.0;
  late AnimationController _fadeController;
  late AnimationController _radarController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final response = await http.get(Uri.parse('${ApiService().baseUrl}/dashboard'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _totalRobots = data['total_robots'] ?? 5;
          _onlineRobots = data['online_robots'] ?? 4;
          _averageBattery = (data['average_battery'] ?? 100.0).toDouble();
        });
      }
    } catch (e) {
      print("Error loading dashboard metrics: $e");
    }
  }

  void _showSystemDiagnostics() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xff131926) : Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xff5de6ff).withOpacity(0.1),
                      ),
                      child: const Icon(Icons.analytics_outlined, color: Color(0xff3b82f6), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'SYSTEM HEALTH',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'SYSTEMS OPTIMAL',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xff10b981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                const Divider(height: 20, color: Color(0xff1e293b)),
                const SizedBox(height: 8),
                _buildDiagnosticRow('LIDAR Rangefinder', '100% SIGNAL', const Color(0xff10b981)),
                const SizedBox(height: 10),
                _buildDiagnosticRow('Network Uplink Ping', '12ms (EXCELLENT)', const Color(0xff2563eb)),
                const SizedBox(height: 10),
                _buildDiagnosticRow('Servo Actuators', 'NOMINAL TEMP', const Color(0xff10b981)),
                const SizedBox(height: 10),
                _buildDiagnosticRow('Fleet Battery Health', '94.2% CAPACITY', Colors.white),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
                  ),
                  child: const Text(
                    '> CPU core temp: 42°C\n> Lidar frames: 60 FPS\n> Safety override: STANDBY\n> Calibration status: OK',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Color(0xff4ade80),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xff64748b), fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 12, color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final apiService = ApiService();

    return AnimatedBuilder(
      animation: apiService,
      builder: (context, child) {
        final isAdmin = apiService.isAdminMode;
        return Scaffold(
          backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: isDark ? Colors.white : const Color(0xff0f172a)),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            titleSpacing: 0,
            title: InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isAdmin ? const Color(0xff8b5cf6) : const Color(0xff2563eb),
                    child: Text(
                      isAdmin ? 'AM' : 'ON',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isAdmin ? 'Dr. Aryan Mehta' : 'Operator Nandini',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xff0f172a),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isAdmin ? 'Security Admin • Active' : 'Senior Operator • Active',
                        style: const TextStyle(
                          color: Color(0xff14b8a6), // Teal accent color matching HTML portal
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: isDark ? Colors.white : const Color(0xff0f172a)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new system notifications.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : const Color(0xff0f172a)),
            onPressed: () {
              MainNavigationShell.of(context).setTab(3); // Go to Settings
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand logo row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Image.asset(isDark ? 'assets/logo_light.png' : 'assets/logo_dark.png', height: 24),
                    const SizedBox(width: 8),
                    Text(
                      'bluCursor',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xff0f172a),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0), height: 1),
              
              // Profile Section in Drawer
              Container(
                padding: const EdgeInsets.all(20),
                color: isDark ? const Color(0xff0d131f) : const Color(0xfff1f5f9), // Slightly different background for depth
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isAdmin ? const Color(0xff8b5cf6) : const Color(0xff2563eb),
                      child: Text(
                        isAdmin ? 'AM' : 'JD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isAdmin ? 'Dr. Aryan Mehta' : 'John Doe',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xff0f172a),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAdmin ? 'Security Admin • Active' : 'Senior Operator • Active',
                      style: TextStyle(
                        color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin 
                            ? const Color(0xff8b5cf6).withOpacity(0.15) 
                            : const Color(0xff2563eb).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAdmin 
                              ? const Color(0xff8b5cf6).withOpacity(0.3) 
                              : const Color(0xff2563eb).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        isAdmin ? 'CLEARANCE LVL 5' : 'CLEARANCE LVL 3',
                        style: TextStyle(
                          color: isAdmin ? const Color(0xffa78bfa) : const Color(0xff60a5fa),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0), height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    const SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.home_outlined, color: isDark ? Colors.white : const Color(0xff475569)),
                      title: Text('Home Dashboard', style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a))),
                      onTap: () {
                        Navigator.pop(context);
                        MainNavigationShell.of(context).setTab(0);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.local_shipping_outlined, color: isDark ? Colors.white : const Color(0xff475569)),
                      title: Text('Delivery Logistics', style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a))),
                      onTap: () {
                        Navigator.pop(context);
                        MainNavigationShell.of(context).setTab(1);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.shield_outlined, color: isDark ? Colors.white : const Color(0xff475569)),
                      title: Text('Patrol Surveillance', style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a))),
                      onTap: () {
                        Navigator.pop(context);
                        MainNavigationShell.of(context).setTab(2);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings_outlined, color: isDark ? Colors.white : const Color(0xff475569)),
                      title: Text('Settings & Profile', style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a))),
                      onTap: () {
                        Navigator.pop(context);
                        MainNavigationShell.of(context).setTab(3);
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'v2.0 ENTERPRISE',
                  style: TextStyle(color: Color(0xff64748b), fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // 1. Persistent Top Navigation & Global Status Header
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xff111827), const Color(0xff090d16)]
                        : [Colors.white, const Color(0xfff8fafc)],
                  ),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xff00A2FF).withOpacity(0.12)
                        : const Color(0xff2563eb).withOpacity(0.1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xff00A2FF).withOpacity(0.04)
                          : Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(isDark ? 'assets/logo_light.png' : 'assets/logo_dark.png', height: 18),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xff10b981).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xff10b981).withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xff10b981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'FLEET SYSTEM NOMINAL',
                                style: TextStyle(
                                  color: Color(0xff10b981),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xff1e293b)),
                    Text(
                      'SYSTEM ALERTS & NOTIFICATIONS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildHeaderAlertItem(Icons.warning_amber_rounded, 'Failed simulation on Node-B', '12m ago', Colors.amber),
                    const SizedBox(height: 6),
                    _buildHeaderAlertItem(Icons.check_circle_outline_rounded, 'Batch render #402 complete', '1h ago', Colors.green),
                    const SizedBox(height: 6),
                    _buildHeaderAlertItem(Icons.info_outline_rounded, 'System Update: v2.0 Enterprise is live', '1d ago', Colors.blue),
                  ],
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 16),
                _buildQuickCommandCenter(),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: AnimatedTapScale(
                        onTap: () => MainNavigationShell.of(context).setTab(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/patrolling_widget.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: AnimatedTapScale(
                        onTap: () => MainNavigationShell.of(context).setTab(1),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/delivery_widget.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Live Fleet Overview
              const Text(
                'LIVE FLEET OVERVIEW',
                style: TextStyle(
                  color: Color(0xff64748b),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.55,
                children: [
                  _buildStatCard('Total Fleet', '$_totalRobots', Icons.dns_outlined, Colors.blue, 1.0, 'Nominal'),
                  _buildStatCard('Active Fleet', '$_onlineRobots', Icons.play_arrow_outlined, Colors.green, 0.8, '80% Online'),
                  _buildStatCard('Tasks Done', '14', Icons.check_box_outlined, Colors.orange, 0.72, '+14 today'),
                  _buildStatCard('System Health', '98%', Icons.favorite_border, Colors.cyan, 0.98, 'Optimal'),
                ],
              ),
              const SizedBox(height: 10),
              // Current Missions row
              InkWell(
                onTap: () => MainNavigationShell.of(context).setTab(1),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xff131926) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xff2563eb).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.navigation_outlined, color: Color(0xff3b82f6), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Missions',
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Active dispatch routing tasks',
                              style: TextStyle(color: Color(0xff64748b), fontSize: 10.5),
                            )
                          ],
                        ),
                      ),
                      const Text(
                        '3',
                        style: TextStyle(color: Color(0xff3b82f6), fontSize: 24, fontWeight: FontWeight.w900),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildFAQSection(),
              const SizedBox(height: 20),

              // 4. System Health
              const Text(
                'SYSTEM HEALTH',
                style: TextStyle(
                  color: Color(0xff64748b),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff131926) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1)),
                ),
                child: Column(
                  children: [
                    _buildDiagnosticItem(Icons.radar_rounded, 'LIDAR Rangefinder', '100% SIGNAL', const Color(0xff10b981)),
                    const SizedBox(height: 10),
                    _buildDiagnosticItem(Icons.wifi_tethering_rounded, 'Network Uplink Ping', '12ms (EXCELLENT)', const Color(0xff2563eb)),
                    const SizedBox(height: 10),
                    _buildDiagnosticItem(Icons.settings_input_component_rounded, 'Servo Actuators', 'NOMINAL TEMP', const Color(0xff10b981)),
                    const SizedBox(height: 10),
                    _buildDiagnosticItem(Icons.battery_saver_rounded, 'Fleet Battery Health', '94.2% CAPACITY', isDark ? Colors.white : const Color(0xff0f172a)),
                    const Divider(height: 24, color: Color(0xff1e293b)),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
                      ),
                      child: Text(
                        '> CPU core temp: 42°C\n> Lidar frames: 60 FPS\n> Safety override: STANDBY\n> Calibration status: OK',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: isDark ? const Color(0xff4ade80) : const Color(0xff15803d),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Your Recent Simulations (Empty State)
              const Text(
                'YOUR RECENT SIMULATIONS',
                style: TextStyle(
                  color: Color(0xff64748b),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff131926) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xff2563eb).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.analytics_outlined, color: Color(0xff3b82f6), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Active Simulations Yet',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xff0f172a),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You don\'t have any running tests right now. Click on "Launch Patrol" or "Launch Delivery" above to start your first robot simulation.',
                                style: TextStyle(
                                  color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xff1e293b)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xff10b981).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.history_toggle_off_rounded, color: Color(0xff10b981), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xff0f172a),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'When your robots finish a route or trigger an alert, the details will appear right here for you to review.',
                                style: TextStyle(
                                  color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  },
);
}


  Widget _buildHeaderAlertItem(IconData icon, String text, String time, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xffcbd5e1) : const Color(0xff334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xff64748b),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniSimulationButton({
    required String header,
    required String title,
    required String footer,
    required Color color,
    required String mapImagePath,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: AnimatedTapScale(
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xff111827), const Color(0xff090d16)]
                  : [Colors.white, const Color(0xfff8fafc)],
            ),
            border: Border.all(
              color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? color.withOpacity(0.06) : Colors.black.withOpacity(0.02),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header,
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xff0f172a),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        mapImagePath,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              (isDark ? const Color(0xff090d16) : Colors.white).withOpacity(0.1),
                              isDark ? const Color(0xff090d16) : Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          footer,
                          style: TextStyle(
                            color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: TextStyle(
            color: Color(0xff64748b),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff131926) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/faq_widget.jpg',
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App Guide & FAQs',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xff0f172a),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Quick help, robot guides, and clearance information',
                              style: TextStyle(
                                color: Color(0xff64748b),
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xff1e293b)),
                _buildFAQTile(
                  'How do I view the Live Telemetry Map?',
                  'Navigate to the Delivery or Patrol tabs to view real-time telemetry feeds, speed/battery meters, active path lines, and interactive robot tracking on the map.',
                  const Color(0xff3b82f6),
                  imageAssetPath: 'assets/map_5.png',
                ),
                const Divider(height: 1, color: Color(0xff1e293b)),
                _buildFAQTile(
                  'What is the Patrol & Surveillance Simulation?',
                  'This feature allows you to configure guard routes, run security patrol schedules, test camera blind spots, and monitor robot safety parameters in a simulated environment.',
                  const Color(0xff8b5cf6),
                  imageAssetPath: 'assets/robot_ares.png',
                ),
                const Divider(height: 1, color: Color(0xff1e293b)),
                _buildFAQTile(
                  'What is the Logistics & Delivery Simulation?',
                  'This feature lets you simulate dispatcher tasks, coordinate A-to-B delivery navigation, test obstacle avoidance, and track cargo items in real-time.',
                  const Color(0xff10b981),
                  imageAssetPath: 'assets/robot_hermes.png',
                ),
                const Divider(height: 1, color: Color(0xff1e293b)),
                _buildFAQTile(
                  'Can I manually override and pilot a robot?',
                  'Yes. You can manually pilot any online robot unit using the tactile touch joystick controller, steering commands, and instant log stream available in the control panel.',
                  const Color(0xfff59e0b),
                  imageAssetPath: 'assets/microchip_robot.png',
                ),
                const Divider(height: 1, color: Color(0xff1e293b)),
                _buildFAQTile(
                  'How does Clearance & Access Management work?',
                  'You can switch between Clearance Lvl 3 (Operator) and Clearance Lvl 5 (Admin) modes in Settings to access administrative command tools and quick controls.',
                  const Color(0xffec4899),
                  imageAssetPath: 'assets/botriq_logo.png',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQTile(String question, String answer, Color color, {String? imageAssetPath}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(Icons.help_outline, color: color, size: 18),
        ),
        title: Text(
          question,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xff0f172a),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconColor: color,
        collapsedIconColor: const Color(0xff64748b),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 48, right: 16, bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(
                      color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ),
                if (imageAssetPath != null) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: isDark ? Colors.black.withOpacity(0.2) : const Color(0xfff1f5f9),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        imageAssetPath,
                        height: 50,
                        width: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticItem(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xff64748b)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff64748b),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color themeColor, double fillPercent, String subText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff131926) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xff64748b), fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: themeColor, size: 14),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a), fontSize: 20, fontWeight: FontWeight.w900),
              ),
              Text(
                subText,
                style: TextStyle(color: themeColor, fontSize: 8.5, fontWeight: FontWeight.bold),
              )
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fillPercent,
              backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0),
              color: themeColor,
              minHeight: 3.5,
            ),
          )
        ],
      ),
    );
  }


  Widget _buildQuickCommandCenter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff131926) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              const Text(
                'QUICK COMMAND CENTER',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xff1e293b)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Button 1: Broadcast Alert
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ALERT BROADCAST SENT TO ALL FLEET UNITS'),
                      backgroundColor: Colors.amber,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.withOpacity(0.1),
                  foregroundColor: Colors.amber,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.campaign_outlined, size: 16),
                label: const Text('Broadcast Alert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              // Button 2: Emergency Stop All
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('EMERGENCY STANDBY ISSUED FOR ALL ACTIVE FLEET'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.dangerous_outlined, size: 16),
                label: const Text('All Stop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RadarScannerPainter extends CustomPainter {
  final double angle;
  final bool isDark;

  RadarScannerPainter({required this.angle, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final paintGrid = Paint()
      ..color = isDark ? const Color(0xff00D2FF).withOpacity(0.08) : const Color(0xff2563eb).withOpacity(0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final paintGreen = Paint()
      ..color = const Color(0xff10b981)
      ..style = PaintingStyle.fill;

    // Draw concentric circles
    canvas.drawCircle(center, radius, paintGrid);
    canvas.drawCircle(center, radius * 0.66, paintGrid);
    canvas.drawCircle(center, radius * 0.33, paintGrid);

    // Draw crosshair axes
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), paintGrid);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), paintGrid);

    // Draw radar sweep (gradient cone)
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          (isDark ? const Color(0xff00D2FF) : const Color(0xff2563eb)).withOpacity(0.2),
        ],
        stops: const [0.75, 1.0],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sweepPaint);

    // Draw mock robot blips (glowing dots)
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy - radius * 0.3), 4, paintGreen);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.3),
      10,
      Paint()
        ..color = const Color(0xff10b981).withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawCircle(Offset(center.dx - radius * 0.5, center.dy + radius * 0.2), 3, paintGreen);

    canvas.drawCircle(Offset(center.dx + radius * 0.2, center.dy + radius * 0.6), 4, paintGreen);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.6),
      8,
      Paint()
        ..color = const Color(0xff10b981).withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant RadarScannerPainter oldDelegate) => oldDelegate.angle != angle;
}
