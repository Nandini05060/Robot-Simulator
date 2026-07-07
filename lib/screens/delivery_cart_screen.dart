import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/robot.dart';
import '../widgets/smooth_entrance_transition.dart';
import '../widgets/animated_tap_scale.dart';

class DeliveryCartScreen extends StatelessWidget {
  const DeliveryCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Delivery-specific robots from the sample database
    final List<Robot> deliveryRobots = [
      sampleRobots[0], // ARES-100 (Online)
      sampleRobots[1], // HERMES-Lite (Online)
      sampleRobots[4], // PALLAS-Sorter (Online)
      sampleRobots[2], // CRONUS-Heavy (Offline)
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
        'robot': deliveryRobots[3],
      },
      {
        'name': 'Floor Map E',
        'robot': null, // No robot assigned
      },
    ];

    final Color primaryBlue = const Color(0xff55E8FF);
    final Color darkBg = const Color(0xff090A0F);
    final Color cardBg = const Color(0xff141822);
    final Color borderCol = const Color(0xff55E8FF).withOpacity(0.15);

    return Scaffold(
      backgroundColor: isDark ? darkBg : const Color(0xfff8fafc),
      appBar: AppBar(
        title: Text(
          'Delivery Cart Module',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xff0e111a) : Colors.white,
        centerTitle: true,
      ),
      body: SmoothEntranceTransition(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Title
            Text(
              'Office Logistics & Delivery',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xff0f172a),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a map below to assign a delivery robot and monitor progress.',
              style: GoogleFonts.outfit(
                color: isDark ? const Color(0xff8A8D99) : Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Horizontal Summary Stats Dashboard Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStatBox('Total Robots', '5', '+1 new', Icons.developer_board, isDark, primaryBlue),
                  const SizedBox(width: 10),
                  _buildStatBox('Active', '3', '60%', Icons.play_circle_outline, isDark, const Color(0xff00D2FF)),
                  const SizedBox(width: 10),
                  _buildStatBox('Idle', '1', '20%', Icons.pause_circle_outline, isDark, const Color(0xffFFB800)),
                  const SizedBox(width: 10),
                  _buildStatBox('Offline', '1', '20%', Icons.dangerous_outlined, isDark, const Color(0xffFF4B5C)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Registered Delivery Robots Header
            Text(
              'Registered Delivery Robots',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xff0f172a),
              ),
            ),
            const SizedBox(height: 12),

            // Redesigned Robo Cards List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: maps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final map = maps[index];
                final Robot? robot = map['robot'];

                final String robotId = robot?.id ?? 'R-00';
                final String robotName = robot?.name ?? 'Standby';
                final String modelType = robot?.modelType ?? 'Standard Cargo unit';
                final String statusText = robot != null ? robot.status : 'Standby';
                final String lastActivityText = robot != null ? robot.lastActivity : 'System Standby';
                final int batteryPercent = robot?.batteryLevel ?? 0;
                final String imagePath = robot?.imagePath ?? 'assets/robot_splash.png';
                final bool isOnline = robot != null && robot.isOnline;

                // Color overrides matching screen state
                Color statusAccent = const Color(0xff8a8d99);
                Color badgeBg = const Color(0xff1b202e);
                if (robot != null) {
                  if (isOnline) {
                    statusAccent = const Color(0xff00D2FF); // Active Blue
                    badgeBg = const Color(0xff00D2FF).withOpacity(0.1);
                  } else if (robot.status == 'Offline') {
                    statusAccent = const Color(0xffFF4B5C); // Warning Red
                    badgeBg = const Color(0xffFF4B5C).withOpacity(0.1);
                  } else {
                    statusAccent = const Color(0xffFFB800); // Standby Yellow
                    badgeBg = const Color(0xffFFB800).withOpacity(0.1);
                  }
                }

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? cardBg : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? (isOnline ? primaryBlue.withOpacity(0.3) : borderCol) : const Color(0xffe2e8f0),
                      width: isDark && isOnline ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Top Identity Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail image
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xff090A0F) : const Color(0xfff1f5f9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? borderCol : const Color(0xffcbd5e1),
                                  width: 1.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.airport_shuttle, size: 28, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Meta information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        robotName,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark ? Colors.white : const Color(0xff0f172a),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: badgeBg,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          statusText.toUpperCase(),
                                          style: TextStyle(
                                            color: statusAccent,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Model: $modelType',
                                    style: TextStyle(
                                      color: isDark ? const Color(0xff8A8D99) : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Assigned Layout: ${map['name']}',
                                    style: TextStyle(
                                      color: isDark ? primaryBlue.withOpacity(0.7) : const Color(0xff2563eb),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0x1a94a3b8), height: 1),
                        const SizedBox(height: 16),

                        // 2. Info Grid Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Battery info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BATTERY',
                                    style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.battery_charging_full_outlined, size: 14, color: statusAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        robot != null ? '$batteryPercent%' : '--%',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                          color: isDark ? Colors.white : const Color(0xff0f172a),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 80,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: (batteryPercent / 100).clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: statusAccent,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Location info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'LOCATION',
                                    style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          robot != null ? (robot.isOnline ? 'Sector A-12' : 'Charging Dock') : 'Standby Base',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                            color: isDark ? Colors.white : const Color(0xff0f172a),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            // Last active info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'LAST ACTIVE',
                                    style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          lastActivityText,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                            color: isDark ? Colors.white : const Color(0xff0f172a),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3. Action Buttons Panel
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedTapScale(
                            onTap: () {
                              final activeRobot = robot ?? deliveryRobots[0];
                              Navigator.pushNamed(
                                context,
                                '/robot_loading',
                                arguments: activeRobot,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.map_outlined, size: 16, color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    'View Details',
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStatBox(String title, String num, String sub, IconData icon, bool isDark, Color accentColor) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff141822) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xff55E8FF).withOpacity(0.1) : const Color(0xffe2e8f0),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: accentColor),
              Text(
                sub,
                style: TextStyle(
                  color: isDark ? const Color(0xff8A8D99) : Colors.grey[600],
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            num,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : const Color(0xff0f172a),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: isDark ? const Color(0xff8A8D99) : Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
