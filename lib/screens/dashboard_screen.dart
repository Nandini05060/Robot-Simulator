import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main_navigation_shell.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeIntroTab = 0;
  int _totalRobots = 5;
  int _onlineRobots = 4;
  double _averageBattery = 100.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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
                      isAdmin ? 'AM' : 'JD',
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
                        isAdmin ? 'Dr. Aryan Mehta' : 'John Doe',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Persistent Top Navigation & Global Status Header
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff131926) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                            const SizedBox(width: 8),
                            Text(
                              'bluCursor',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xff0f172a),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
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
              const SizedBox(height: 16),
              _buildCompanyIntroCard(),
              const SizedBox(height: 16),

              // 2. Quick Start Actions (Getting Started)
              const Text(
                'GETTING STARTED',
                style: TextStyle(
                  color: Color(0xff64748b),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              // Button 1: Patrol Simulation
              _buildQuickStartButton(
                context,
                icon: Icons.shield_outlined,
                title: 'Launch Patrol Simulation',
                subtitle: 'Test Security & Coverage',
                desc: 'Simulate guard routes, test camera blind spots, and optimize fleet battery life for continuous area surveillance.',
                color: const Color(0xff2563eb),
                onTap: () => MainNavigationShell.of(context).setTab(2),
              ),
              const SizedBox(height: 10),
              // Button 2: Delivery Simulation
              _buildQuickStartButton(
                context,
                icon: Icons.local_shipping_outlined,
                title: 'Launch Delivery Simulation',
                subtitle: 'Optimize Logistics & Routing',
                desc: 'Run A-to-B delivery scenarios, test obstacle avoidance in crowded aisles, and measure package throughput.',
                color: const Color(0xff10b981),
                onTap: () => MainNavigationShell.of(context).setTab(1),
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
    );
  },
);
}

  Widget _buildBadgeTag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
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

  Widget _buildQuickStartButton(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff131926) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xff0f172a),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: TextStyle(
                      color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xff64748b), size: 20),
          ],
        ),
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

  Widget _buildQuickActionCard(String label, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff131926) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.white : const Color(0xff2563eb), size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a), fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String imagePath, String desc) {
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xff2563eb).withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xff2563eb).withOpacity(0.25)),
            ),
            child: Image.asset(imagePath, height: 26, width: 26, fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a), fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
          Text(
            desc,
            style: TextStyle(color: isDark ? const Color(0xff64748b) : const Color(0xff475569), fontSize: 9.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildFleetCategoryCard(String title, String desc, String badgeText, String imagePath, int tabIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        MainNavigationShell.of(context).setTab(tabIndex);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff131926) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xff2563eb).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xff2563eb).withOpacity(0.2)),
              ),
              child: Image.asset(imagePath, height: 40, width: 40, fit: BoxFit.contain),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xff0f172a), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(color: isDark ? const Color(0xff64748b) : const Color(0xff475569), fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xff2563eb).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(color: Color(0xff3b82f6), fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xff3b82f6), size: 20)
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyIntroCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget tabContent;
    if (_activeIntroTab == 0) {
      tabContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'bluCursor Infotech is an IT outsourcing, digital transformation, and software development company based in Indore, India. Established in 2013, we deliver customized technology solutions across the digital value chain.',
            style: TextStyle(
              color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'OUR PHILOSOPHY PILLARS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPillarBadge('🛡️ Passion', 'Tech & Solving', const Color(0xff2563eb)),
              _buildPillarBadge('⚡ Power', 'Cost-effective', const Color(0xff10b981)),
              _buildPillarBadge('🏆 Pride', 'Client Growth', const Color(0xfff59e0b)),
            ],
          ),
        ],
      );
    } else if (_activeIntroTab == 1) {
      tabContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceRow('📱 Web & Mobile Development', 'Responsive web interfaces and dynamic mobile apps (85% mobile / 95% web focus).'),
          const SizedBox(height: 10),
          _buildServiceRow('🤖 AI & Machine Learning', 'Custom ML models, natural language processing, and predictive analytics.'),
          const SizedBox(height: 10),
          _buildServiceRow('🎨 UI/UX Design', 'Optimized, user-centric, and high-conversion digital experiences.'),
          const SizedBox(height: 10),
          _buildServiceRow('☁️ Cloud & DevOps', 'Scalable architecture on AWS & Microsoft Azure with CI/CD automation.'),
          const SizedBox(height: 10),
          _buildServiceRow('🤝 Salesforce Solutions', 'Preferred Salesforce partner for migration, integration, and development.'),
        ],
      );
    } else {
      tabContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leveraging a robust, enterprise-grade technology stack for custom solutions.',
            style: TextStyle(
              color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTechTag('React'),
              _buildTechTag('Angular'),
              _buildTechTag('Node.js'),
              _buildTechTag('AWS (Amazon Web Services)'),
              _buildTechTag('Microsoft Azure'),
              _buildTechTag('GenAI Integrations'),
              _buildTechTag('Large Language Models (LLMs)'),
              _buildTechTag('Computer Vision'),
              _buildTechTag('IoT Ecosystems'),
            ],
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff131926) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/blucursor_banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      (isDark ? const Color(0xff131926) : Colors.white).withOpacity(0.85),
                      isDark ? const Color(0xff131926) : Colors.white,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Text(
                  'bluCursor Infotech',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xff0f172a),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(0, 'Overview'),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Services'),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Tech Stack'),
                ],
              ),
            ),
            const Divider(height: 20, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: tabContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _activeIntroTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeIntroTab = index;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xff2563eb).withOpacity(isDark ? 0.15 : 0.08) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xff2563eb).withOpacity(0.3) 
                  : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected 
                  ? const Color(0xff2563eb) 
                  : (isDark ? const Color(0xff94a3b8) : const Color(0xff64748b)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillarBadge(String title, String subtitle, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? const Color(0xff94a3b8) : const Color(0xff64748b),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(String title, String desc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xff0f172a),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  color: isDark ? const Color(0xff94a3b8) : const Color(0xff64748b),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechTag(String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: isDark ? const Color(0xffe2e8f0) : const Color(0xff475569),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
