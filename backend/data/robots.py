from models.robot import Robot

robots = [

    Robot(
        id=1,
        name="Robot A",
        model_type="Delivery",

        x=5,
        y=5,
        angle=0,

        direction="North",

        battery=100,
        speed=1,

        status="Idle",
        mode="Manual",

        is_online=True,

        current_task="None",

        map_name="Warehouse"
    ),

    Robot(
        id=2,
        name="Robot B",
        model_type="Patrol",

        x=10,
        y=10,
        angle=90,

        direction="East",

        battery=100,
        speed=1,

        status="Idle",
        mode="Manual",

        is_online=True,

        current_task="None",

        map_name="Warehouse"
    ),

    Robot(
        id=3,
        name="Robot C",
        model_type="Inspection",

        x=15,
        y=15,
        angle=180,

        direction="South",

        battery=100,
        speed=1,

        status="Idle",
        mode="Manual",

        is_online=False,

        current_task="Offline",

        map_name="Warehouse"
    )

]