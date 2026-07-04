import asyncio
import heapq
from typing import Union, List, Tuple

from services.robot_service import get_robot
from services.telemetry_service import build_telemetry
from core.websocket_manager import manager

# Define grid size 25x20
grid = [[0 for _ in range(20)] for _ in range(25)]

# Populate boundary walls
for x in range(25):
    grid[x][0] = 1
    grid[x][19] = 1
for y in range(20):
    grid[0][y] = 1
    grid[24][y] = 1

# Populate horizontal partition wall at y=11 (Doors at x=9 and x=14)
for x in range(25):
    if x != 9 and x != 14:
        grid[x][11] = 1

# Populate vertical partition wall at x=12 from y=11 to 20
for y in range(11, 20):
    grid[12][y] = 1

# Populate vertical wall for left rooms at x=5 from y=0 to 11 (Door at y=3)
for y in range(0, 11):
    if y != 3:
        grid[5][y] = 1

# Populate horizontal wall at y=6 from x=0 to 5
for x in range(0, 6):
    grid[x][6] = 1

# Populate office desks and chairs (obstacles)
# Long desk at x=15 from y=1 to 9 (and chairs at x=13, 17)
for y in range(1, 10):
    grid[15][y] = 1
    grid[13][y] = 1
    grid[17][y] = 1

# Chairs on the right wall
for y in [3, 6, 9]:
    grid[22][y] = 1
    grid[23][y] = 1

# Bathroom fixtures (top left)
for x in range(0, 5):
    grid[x][2] = 1


def find_closest_free(pt: Tuple[int, int]) -> Tuple[int, int]:
    x, y = pt
    if grid[x][y] == 0:
        return pt
    
    # BFS to find the closest free cell
    queue = [pt]
    visited = {pt}
    while queue:
        cx, cy = queue.pop(0)
        if grid[cx][cy] == 0:
            return (cx, cy)
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, 1), (-1, 1), (1, -1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < 25 and 0 <= ny < 20:
                neighbor = (nx, ny)
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)
    return pt


def astar(start: Tuple[float, float], goal: Tuple[float, float]) -> List[Tuple[float, float]]:
    start_grid = (int(round(start[0])), int(round(start[1])))
    goal_grid = (int(round(goal[0])), int(round(goal[1])))
    
    start_grid = (max(0, min(24, start_grid[0])), max(0, min(19, start_grid[1])))
    goal_grid = (max(0, min(24, goal_grid[0])), max(0, min(19, goal_grid[1])))
    
    start_grid = find_closest_free(start_grid)
    goal_grid = find_closest_free(goal_grid)
    
    queue = []
    # (f_score, g_score, current, path)
    heapq.heappush(queue, (0.0, 0.0, start_grid, [start_grid]))
    visited = set()
    
    while queue:
        f, g, current, path = heapq.heappop(queue)
        
        if current == goal_grid:
            return [(float(pt[0]), float(pt[1])) for pt in path]
            
        if current in visited:
            continue
        visited.add(current)
        
        cx, cy = current
        # 8-directional moves (up, down, left, right, diagonals)
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, 1), (-1, 1), (1, -1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < 25 and 0 <= ny < 20 and grid[nx][ny] == 0:
                # Prevent cutting corners
                if dx != 0 and dy != 0:
                    if grid[cx + dx][cy] != 0 or grid[cx][cy + dy] != 0:
                        continue
                neighbor = (nx, ny)
                move_cost = 1.414 if (dx != 0 and dy != 0) else 1.0
                g_cost = g + move_cost
                h_cost = ((nx - goal_grid[0])**2 + (ny - goal_grid[1])**2)**0.5
                f_cost = g_cost + h_cost
                heapq.heappush(queue, (f_cost, g_cost, neighbor, path + [neighbor]))
                
    return [start, goal]


async def start_navigation(
    robot_id: Union[int, str],
    start_x: float,
    start_y: float,
    destination_x: float,
    destination_y: float,
):
    robot = get_robot(robot_id)
    if robot is None:
        return {
            "success": False,
            "message": "Robot not found"
        }

    # Snap robot start to nearest valid point
    start_grid = find_closest_free((int(round(start_x)), int(round(start_y))))
    robot.x = float(start_grid[0])
    robot.y = float(start_grid[1])
    
    robot.start_x = robot.x
    robot.start_y = robot.y
    robot.destination_x = destination_x
    robot.destination_y = destination_y
    robot.auto_navigation = True
    robot.mode = "Auto"
    robot.status = "Navigating"

    # Compute A* path in a background thread to avoid blocking the event loop
    path = await asyncio.to_thread(astar, (robot.x, robot.y), (destination_x, destination_y))
    path_index = 0
    
    # Move step-by-step along the path waypoints
    while robot.auto_navigation and path_index < len(path):
        target_x, target_y = path[path_index]
        
        dx = target_x - robot.x
        dy = target_y - robot.y
        distance = (dx**2 + dy**2)**0.5
        
        # Adjust robot speed dynamically to prevent overshoot
        current_speed = min(robot.speed, 0.4) 
        
        if distance <= current_speed:
            robot.x = target_x
            robot.y = target_y
            path_index += 1
        else:
            robot.x += (dx / distance) * current_speed
            robot.y += (dy / distance) * current_speed
            
            # Update heading direction angle
            if abs(dx) > abs(dy):
                robot.angle = 90 if dx > 0 else 270
            else:
                robot.angle = 180 if dy > 0 else 0
                
        # Broadcast live telemetry update
        await manager.broadcast(build_telemetry(robot))
        await asyncio.sleep(0.2)

    robot.auto_navigation = False
    robot.status = "Idle"
    robot.mode = "Manual"
    await manager.broadcast(build_telemetry(robot))

    return {
        "success": True,
        "robot": robot
    }


def stop_navigation(robot_id: Union[int, str]):
    robot = get_robot(robot_id)
    if robot is None:
        return
    robot.auto_navigation = False
    robot.status = "Manual"
    robot.mode = "Manual"