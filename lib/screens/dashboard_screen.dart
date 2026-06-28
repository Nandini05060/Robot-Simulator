import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fleet_state_provider.dart';
import 'main_navigation_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final provider = Provider.of<FleetStateProvider>(context);
    final robots = provider.robots;
    
    final totalCount = robots.length;
    final onlineCount = robots.where((r) => r.isOnline).length;
    final deliveryCount = robots.where((r) => r.modelType.toLowerCase().contains('delivery')).length;
    final patrolCount = robots.where((r) => r.modelType.toLowerCase().contains('patrol')).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xff131926) : Colors.white,
        title: Row(
          children: [
            // Company Logo branding
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff090d16) : const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1),
                  width: 1,
                ),
              ),
              child: Image.asset(
                isDark ? 'assets/logo_light.png' : 'assets/logo_dark.png',
                height: 16,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            const Text(
              'Robot Operations Center',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Welcome Section
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xff2563eb),
                  child: Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Administrator',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Clearance Level 5 • ${provider.isLoggedIn ? "Active API Session" : "Standby"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. About Application Card
            Card(
              color: const Color(0xff2563eb).withOpacity(0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: const Color(0xff2563eb).withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Color(0xff2563eb), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SYSTEM CAPABILITIES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xff2563eb),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage, track, and command corporate office robots. The control center provides telemetry metrics, real-time map trail vectors, manual steering, and safety override protocols.',
                      style: TextStyle(fontSize: 13, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Analytics Section
            Text(
              'System Analytics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                _buildAnalyticsCard('Total Robots', '$totalCount', Icons.precision_manufacturing, const Color(0xff2563eb)),
                _buildAnalyticsCard('Active Robots', '$onlineCount', Icons.play_circle_outline, const Color(0xff10b981)),
                _buildAnalyticsCard('Delivery Carts', '$deliveryCount', Icons.local_shipping_outlined, const Color(0xff3b82f6)),
                _buildAnalyticsCard('Patrolling Units', '$patrolCount', Icons.security, const Color(0xff8b5cf6)),
              ],
            ),
            const SizedBox(height: 12),
            _buildLargeAnalyticsCard('Robots Currently Online', '$onlineCount / $totalCount', Icons.wifi, const Color(0xff10b981)),
            const SizedBox(height: 24),

            // 4. Main Category Selection
            Text(
              'Module Access',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Category 1: Delivery Cart Robots
            Card(
              color: isDark ? const Color(0xff131926) : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Switch tab to Delivery (Index 1)
                  MainNavigationShell.of(context).setTab(1);
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xff2563eb).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🚚', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery Cart Robots',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage robots assigned for delivery and transportation tasks.',
                              style: TextStyle(
                                color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category 2: Patrolling Robots
            Card(
              color: isDark ? const Color(0xff131926) : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Switch tab to Patrolling (Index 2)
                  MainNavigationShell.of(context).setTab(2);
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xff2563eb).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🛡️', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Patrolling Robots',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage robots assigned for office surveillance and patrolling activities.',
                              style: TextStyle(
                                color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xff2563eb)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(color: Colors.grey, fontSize: 11.5, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xff131926) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ],
              ),
            ),
            Icon(icon, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeAnalyticsCard(String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xff131926) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
