class Robot {
  final String id;
  final String name;
  final String status; // 'Online' | 'Offline'
  final int batteryLevel;
  final String position; // e.g., "x: 14.2, y: 8.5"
  final double angle; // in degrees
  final String lastActivity;
  final String modelType;
  final String imagePath; // Local asset path for robot pic

  Robot({
    required this.id,
    required this.name,
    required this.status,
    required this.batteryLevel,
    required this.position,
    required this.angle,
    required this.lastActivity,
    required this.modelType,
    required this.imagePath,
  });

  bool get isOnline => status.toLowerCase() == 'online';

  Robot copyWith({
    String? id,
    String? name,
    String? status,
    int? batteryLevel,
    String? position,
    double? angle,
    String? lastActivity,
    String? modelType,
    String? imagePath,
  }) {
    return Robot(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      position: position ?? this.position,
      angle: angle ?? this.angle,
      lastActivity: lastActivity ?? this.lastActivity,
      modelType: modelType ?? this.modelType,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

// Sample robot data with image assets mapped
final List<Robot> sampleRobots = [
  Robot(
    id: 'R-01',
    name: 'ARES-100',
    status: 'Online',
    batteryLevel: 88,
    position: '12.4, 8.2',
    angle: 45.0,
    lastActivity: 'Active now',
    modelType: 'Industrial Forklift',
    imagePath: 'assets/robot_ares.png',
  ),
  Robot(
    id: 'R-02',
    name: 'HERMES-Lite',
    status: 'Online',
    batteryLevel: 94,
    position: '5.8, 14.3',
    angle: 180.0,
    lastActivity: 'Idle',
    modelType: 'Delivery Unit',
    imagePath: 'assets/robot_hermes.png',
  ),
  Robot(
    id: 'R-03',
    name: 'CRONUS-Heavy',
    status: 'Offline',
    batteryLevel: 12,
    position: '20.1, 4.7',
    angle: 270.0,
    lastActivity: '4 hours ago',
    modelType: 'Heavy Pallet Mover',
    imagePath: 'assets/robot_cronus.png',
  ),
  Robot(
    id: 'R-04',
    name: 'ZEUS-Surveyor',
    status: 'Online',
    batteryLevel: 62,
    position: '18.9, 12.0',
    angle: 90.0,
    lastActivity: 'Scanning area',
    modelType: 'LIDAR Scanner',
    imagePath: 'assets/robot_hermes.png', // maps Hermes variant
  ),
  Robot(
    id: 'R-05',
    name: 'PALLAS-Sorter',
    status: 'Online',
    batteryLevel: 45,
    position: '8.1, 9.6',
    angle: 125.0,
    lastActivity: 'Moving cargo',
    modelType: 'Small Sorting Bot',
    imagePath: 'assets/robot_ares.png', // maps Ares variant
  ),
];
