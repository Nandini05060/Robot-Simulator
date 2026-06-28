from services.state_manager import state_manager


def get_dashboard_data():

    robots = state_manager.get_all()

    total = len(robots)

    online = sum(robot.is_online for robot in robots)

    offline = total - online

    moving = sum(robot.status == "Moving" for robot in robots)

    idle = sum(robot.status == "Idle" for robot in robots)

    charging = sum(robot.status == "Charging" for robot in robots)

    average_battery = (
        sum(robot.battery for robot in robots) / total
        if total else 0
    )

    return {
        "total_robots": total,
        "online_robots": online,
        "offline_robots": offline,
        "moving": moving,
        "idle": idle,
        "charging": charging,
        "average_battery": round(average_battery, 2)
    }