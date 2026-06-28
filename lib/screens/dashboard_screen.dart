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
                    color: const Color(0xff090d16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xff1e293b)),
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
          backgroundColor: const Color(0xff090d16),
          appBar: AppBar(
            backgroundColor: const Color(0xff090d16),
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
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
                        style: const TextStyle(
                          color: Colors.white,
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
            icon: const Icon(Icons.notifications_none, color: Colors.white),
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
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              MainNavigationShell.of(context).setTab(3); // Go to Settings
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xff090d16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand logo row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Image.asset('assets/logo_light.png', height: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'bluCursor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xff1e293b), height: 1),
              
              // Profile Section in Drawer
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xff0d131f), // Slightly different background for depth
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAdmin ? 'Security Admin • Active' : 'Senior Operator • Active',
                      style: const TextStyle(
                        color: Color(0xff94a3b8),
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
              const Divider(color: Color(0xff1e293b), height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.home_outlined, color: Colors.white),
                      title: const Text('Home Dashboard', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        MainNavigationShell.of(context).setTab(0);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_shipping_outlined, color: Colors.white),
                      title: const Text('Delivery Logistics', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        MainNavigationShell.of(context).setTab(1);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shield_outlined, color: Colors.white),
                      title: const Text('Patrol Surveillance', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        MainNavigationShell.of(context).setTab(2);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined, color: Colors.white),
                      title: const Text('Settings & Profile', style: TextStyle(color: Colors.white)),
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
              // 1. Welcome Card (About Card)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff131926),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff1e293b)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/logo_light.png', height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xff2563eb).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xff2563eb).withOpacity(0.2)),
                          ),
                          child: const Text(
                            'v2.0 ENTERPRISE',
                            style: TextStyle(
                              color: Color(0xff3b82f6),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'bluCursor Fleet Operations Console',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Welcome to the bluCursor Fleet Portal. This interface allows authorized engineers to manage and coordinate smart office robotics, inspect cargo logistics pathways, view data graphs, and trigger real-time manual override steerings for logistics cart units.',
                      style: TextStyle(
                        color: Color(0xff94a3b8),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildBadgeTag('Enterprise IT', Icons.memory, const Color(0xff3b82f6)),
                        const SizedBox(width: 6),
                        _buildBadgeTag('Secure', Icons.gpp_good, const Color(0xff10b981)),
                        const SizedBox(width: 6),
                        _buildBadgeTag('Telemetry', Icons.flash_on, const Color(0xfff59e0b)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Hero Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xff1e293b).withOpacity(0.4),
                      const Color(0xff0f172a).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff1e293b)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Core Command v1.2',
                            style: TextStyle(
                              color: Color(0xff3b82f6),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Fleet Command Center',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Monitor logistics paths, steering vectors, and safety overrides in real-time.',
                            style: TextStyle(
                              color: Color(0xff94a3b8),
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2563eb),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.local_shipping_outlined, size: 12),
                                label: const Text('Inspect Fleet', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  MainNavigationShell.of(context).setTab(1);
                                },
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xff1e293b)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.insights, size: 12),
                                label: const Text('Active Telemetry', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  MainNavigationShell.of(context).setTab(1);
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Image.asset(
                        'assets/robot_splash.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Statistics Grid
              const Text(
                'FLEET STATISTICS',
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
              // Wide Stat
              InkWell(
                onTap: () {
                  MainNavigationShell.of(context).setTab(1);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xff131926),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xff1e293b)),
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
                          children: const [
                            Text(
                              'Current Missions',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
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

              // 4. Quick Actions
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  color: Color(0xff64748b),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildQuickActionCard('View Robots', Icons.list_alt, () {
                    MainNavigationShell.of(context).setTab(1);
                  }),
                  _buildQuickActionCard('Open Map', Icons.map_outlined, () {
                    MainNavigationShell.of(context).setTab(1);
                  }),
                  _buildQuickActionCard('Assign Task', Icons.add_circle_outline, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task scheduler is currently in auto-mode.')),
                    );
                  }),
                  _buildQuickActionCard('View Stats', Icons.bar_chart_outlined, _showSystemDiagnostics),
                ],
              ),
              const SizedBox(height: 24),

              // 5. System Capabilities (Features)
              const Text(
                'SYSTEM CAPABILITIES',
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
                childAspectRatio: 1.45,
                children: [
                  _buildFeatureCard('Real-Time Tracking', 'assets/robot_hermes.png', 'Interactive GPS coordinates.'),
                  _buildFeatureCard('Live Office Map', 'assets/robot_splash.png', 'Observe automated trail maps.'),
                  _buildFeatureCard('Multi-Robot Command', 'assets/robot_cronus.png', 'Coordinate active units.'),
                  _buildFeatureCard('Navigation Control', 'assets/robot_ares.png', 'Manual overrides steering.'),
                  _buildFeatureCard('Operational Stats', 'assets/robot_zeus.png', 'Inspect battery decay rates.'),
                  _buildFeatureCard('Safety Monitoring', 'assets/robot_pallas.png', 'Instant emergency stops.'),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Fleet Modules Categories
              const Text(
                'FLEET MODULES',
                style: TextStyle(
                  color: Color(0xff64748b),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              _buildFleetCategoryCard('Delivery Cart Robots', 'Manage cargo & office logistics', '3 Assigned Robots', 'assets/robot_hermes.png', 1),
              const SizedBox(height: 10),
              _buildFleetCategoryCard('Patrolling Robots', 'Area surveillance & security', '2 Assigned Robots', 'assets/robot_cronus.png', 2),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color themeColor, double fillPercent, String subText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff131926),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff1e293b)),
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
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
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
              backgroundColor: const Color(0xff1e293b),
              color: themeColor,
              minHeight: 3.5,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff131926),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff1e293b)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String imagePath, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff131926),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff1e293b)),
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
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
          Text(
            desc,
            style: const TextStyle(color: Color(0xff64748b), fontSize: 9.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildFleetCategoryCard(String title, String desc, String badgeText, String imagePath, int tabIndex) {
    return InkWell(
      onTap: () {
        MainNavigationShell.of(context).setTab(tabIndex);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff131926),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff1e293b)),
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
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(color: Color(0xff64748b), fontSize: 11),
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
}
