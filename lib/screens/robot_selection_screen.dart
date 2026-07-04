import 'package:flutter/material.dart';
import '../models/robot.dart';

class RobotSelectionScreen extends StatefulWidget {
  const RobotSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RobotSelectionScreen> createState() => _RobotSelectionScreenState();
}

class _RobotSelectionScreenState extends State<RobotSelectionScreen> {
  final List<Robot> _robots = sampleRobots;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filtered = _robots.where((r) {
      return r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.modelType.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Commander'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search & Metrics Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search fleet by name or type...',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: isDark ? const Color(0xff131926) : Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE UNITS: ${_robots.where((r) => r.isOnline).length}/${_robots.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xff94a3b8) : const Color(0xff475569),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Text(
                      'FLEET STATUS: NOMINAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2563eb),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final robot = filtered[index];
                final bool isOnline = robot.isOnline;

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/robot_loading', arguments: robot);
                  },
                  child: Card(
                    color: isDark ? const Color(0xff131926) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  color: isDark ? const Color(0xff090d16) : const Color(0xfff1f5f9),
                                  child: Image.asset(
                                    robot.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.smart_toy_outlined,
                                      color: isOnline ? const Color(0xff2563eb) : const Color(0xff94a3b8),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOnline ? const Color(0xff2563eb) : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            robot.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            robot.modelType,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.battery_charging_full_outlined,
                                    size: 14,
                                    color: robot.batteryLevel > 50 
                                        ? const Color(0xff2563eb) 
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${robot.batteryLevel}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                robot.lastActivity,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
