import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fleet_state_provider.dart';
import '../models/robot.dart';

class PatrollingScreen extends StatelessWidget {
  const PatrollingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final provider = Provider.of<FleetStateProvider>(context);
    final List<Robot> robotsSource = provider.robots.isEmpty ? sampleRobots : provider.robots;
    
    // Filter patrol & inspection robots dynamically
    final List<Robot> patrolRobots = robotsSource
        .where((r) => r.modelType.toLowerCase().contains('patrol') || 
                      r.modelType.toLowerCase().contains('survey') || 
                      r.modelType.toLowerCase().contains('inspect') ||
                      r.name.toLowerCase().contains('zeus') ||
                      r.name.toLowerCase().contains('cronus'))
        .toList();

    // Patrol zone configurations matching patrolling module specs
    final List<Map<String, dynamic>> zones = [
      {
        'name': 'Patrol Zone A',
        'robot': patrolRobots.isNotEmpty ? patrolRobots[0] : null,
      },
      {
        'name': 'Patrol Zone B',
        'robot': patrolRobots.length > 1 ? patrolRobots[1] : null,
      },
      {
        'name': 'Patrol Zone C',
        'robot': patrolRobots.length > 2 ? patrolRobots[2] : null,
      },
      {
        'name': 'Patrol Zone D',
        'robot': null,
      },
      {
        'name': 'Patrol Zone E',
        'robot': null,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text('Patrolling Module'),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xff131926) : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Office Surveillance & Patrolling',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xff0f172a),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a patrol zone below to open live robot monitoring and safety logs.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: zones.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final zone = zones[index];
                final Robot? robot = zone['robot'];

                return Card(
                  color: isDark ? const Color(0xff131926) : Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Navigate to monitoring page with the assigned robot (or fallback)
                      final activeRobot = robot ?? patrolRobots[0];
                      Navigator.pushNamed(
                        context,
                        '/real_time_viz',
                        arguments: activeRobot,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xff2563eb).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xff2563eb).withOpacity(0.2),
                                    width: 1.2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.security_outlined,
                                  color: Color(0xff2563eb),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      zone['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text('Patroller: ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                        Text(
                                          robot != null ? robot.name : 'Unassigned (ZEUS-Surveyor will bind)',
                                          style: TextStyle(
                                            color: robot != null ? const Color(0xff2563eb) : Colors.amber[800],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (robot != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: robot.isOnline
                                            ? const Color(0xff10b981).withOpacity(0.12)
                                            : const Color(0xffef4444).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        robot.status.toUpperCase(),
                                        style: TextStyle(
                                          color: robot.isOnline ? const Color(0xff10b981) : const Color(0xffef4444),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.battery_std, size: 12, color: Colors.grey),
                                        Text(
                                          '${robot.batteryLevel}%',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              else
                                const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              final activeRobot = robot ?? patrolRobots[0];
                              Navigator.pushNamed(
                                context,
                                '/real_time_viz',
                                arguments: activeRobot,
                              );
                            },
                            icon: const Icon(Icons.videocam_outlined, size: 16),
                            label: const Text('Live Monitoring'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2563eb),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
