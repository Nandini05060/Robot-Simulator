import 'package:flutter/material.dart';
import '../models/robot.dart';

class DeliveryCartScreen extends StatelessWidget {
  const DeliveryCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Delivery-specific robots from the sample database
    final List<Robot> deliveryRobots = [
      sampleRobots[0], // ARES-100
      sampleRobots[1], // HERMES-Lite
      sampleRobots[4], // PALLAS-Sorter
    ];

    // Map configuration matching the Delivery Cart module specs
    final List<Map<String, dynamic>> maps = [
      {
        'name': 'Floor Map A',
        'robot': deliveryRobots[0],
      },
      {
        'name': 'Floor Map B',
        'robot': deliveryRobots[1],
      },
      {
        'name': 'Floor Map C',
        'robot': deliveryRobots[2],
      },
      {
        'name': 'Floor Map D',
        'robot': null, // No robot assigned
      },
      {
        'name': 'Floor Map E',
        'robot': null, // No robot assigned
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text('Delivery Cart Module'),
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
              'Office Logistics & Delivery',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xff0f172a),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a map below to assign a delivery robot and monitor progress.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: maps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final map = maps[index];
                final Robot? robot = map['robot'];

                return Card(
                  color: isDark ? const Color(0xff131926) : Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Automatically assign a robot on selection (or assign a default if none)
                      final activeRobot = robot ?? deliveryRobots[0]; 
                      Navigator.pushNamed(
                        context,
                        '/real_time_viz',
                        arguments: activeRobot,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xff2563eb).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xff2563eb).withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.map_outlined,
                              color: Color(0xff2563eb),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  map['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('Assigned: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text(
                                      robot != null ? robot.name : 'Unassigned (ARES-100 will bind)',
                                      style: TextStyle(
                                        color: robot != null ? const Color(0xff2563eb) : Colors.amber[800],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Text('Last Activity: ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    Text(
                                      robot != null ? robot.lastActivity : 'System Standby',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.battery_std, size: 14, color: Colors.grey),
                                    Text(
                                      '${robot.batteryLevel}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          else
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
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
