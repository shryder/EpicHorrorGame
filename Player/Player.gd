extends KinematicBody

slave var camera_angle = 0;
var mouse_sensitivity = 0.3;

slave var velocity = Vector3();
slave var direction = Vector3();
slave var position = Transform();

# Fly stuff
const FLY_SPEED = 40;
const FLY_ACCEL = 4;

# Walk stuff
var gravity = -9.8 * 3;
const MAX_SPEED = 8;
const MAX_RUNNING_SPEED = 20;
const ACCEL = 1.5;
const DEACCEL = 8;

#jumping
var jump_height = 10;
var AIR_SPEED = 15;

slave var on_floor = true;

func _ready():
	pass

func _input(event):
	if (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity));

		# Limit rotation on Y axis
		var change = -event.relative.y * mouse_sensitivity;
		if (camera_angle + change) < 90 and (camera_angle + change) > -90:
			$Head.rotate_x(deg2rad(change));
			camera_angle += change;

func fly(delta):
	direction = Vector3();

	# Get where camera looking at
	var aim = $Head.get_global_transform().basis;

	if Input.is_action_pressed("move_forward"):
		direction -= aim.z;
	if Input.is_action_pressed("move_backward"):
		direction += aim.z;
	if Input.is_action_pressed("move_left"):
		direction -= aim.x;
	if Input.is_action_pressed("move_right"):
		direction += aim.x;

	direction = direction.normalized();

	var target = direction * FLY_SPEED;
	velocity = velocity.linear_interpolate(target, FLY_ACCEL * delta);

	move_and_slide(velocity);

func walk(delta):
	if is_network_master():
		direction = Vector3();
	
		# Get where camera looking at
		var aim = $Head.get_global_transform().basis;
	
		if Input.is_action_pressed("move_forward"):
			direction -= aim.z;
		if Input.is_action_pressed("move_backward"):
			direction += aim.z;
		if Input.is_action_pressed("move_left"):
			direction -= aim.x;
		if Input.is_action_pressed("move_right"):
			direction += aim.x;
	
		direction = direction.normalized();
	
		if(is_on_floor()):
			on_floor = true;
		else:
			if (!$Tail.is_colliding()):
				on_floor = false;
	
		if(on_floor and !is_on_floor()):
			move_and_collide(Vector3(0, -1, 0));
	
		velocity.y += gravity * delta;
	
		var temp_velocity = velocity;
		temp_velocity.y = 0;
	
		var speed;
		if !is_on_floor():
			speed = AIR_SPEED;
		else:
			if Input.is_action_pressed("move_sprint"):
				speed = MAX_RUNNING_SPEED;
			else:
				speed = MAX_SPEED;
	
		var target = direction * speed;
	
		var acceleration
		if(direction.dot(temp_velocity) > 0):
			acceleration = ACCEL;
		else:
			acceleration = DEACCEL;
	
		temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta);
	
		velocity.x = temp_velocity.x;
		velocity.z = temp_velocity.z;
	
		if Input.is_action_just_pressed("move_jump") and on_floor:
			velocity.y = jump_height;
			on_floor = false;
	
		velocity = move_and_slide(velocity, Vector3(0, 1, 0), 0.10);

		rset_unreliable("velocity", velocity);
		rset_unreliable("position", global_transform);
	else:
		move_and_slide(velocity, Vector3(0, 1, 0), 0.10);
		global_transform = position;
func _physics_process(delta):
	# walk(delta);
	walk(delta);
	pass