from models.robot import Robot


def build_telemetry(robot: Robot):

    return {
        "type": "TELEMETRY",

        "robot_id": robot.id,
        "robot_name": robot.name,

        "position": {
            "x": robot.x,
            "y": robot.y
        },

        "angle": robot.angle,
        "direction": robot.direction,

        "battery": robot.battery,
        "speed": robot.speed,

        "status": robot.status,
        "mode": robot.mode,

        "current_task": robot.current_task,

        "map": robot.map_name,

        "online": robot.is_online,
        
        "start_x": getattr(robot, 'start_x', None),
        "start_y": getattr(robot, 'start_y', None),
        "destination_x": getattr(robot, 'destination_x', None),
        "destination_y": getattr(robot, 'destination_y', None),
        "auto_navigation": getattr(robot, 'auto_navigation', False)
    }