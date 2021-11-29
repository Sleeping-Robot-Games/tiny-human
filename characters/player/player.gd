extends KinematicBody2D

signal grounded_updated(is_grounded)

var ideal_framerate = 60.0
var tile_size = 16
var gravity = 800
var velocity = Vector2()
var move_speed = 10 * tile_size
var move_direction
var move_input_speed = 0
var jump_height = 3 * tile_size
var min_jump_height = tile_size / 2
var max_jump_velocity = -sqrt(2 * gravity * jump_height)
var min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
var facing = 1
var wall_direction = 1
var is_jumping = false
var is_double_jumping = false
var is_grounded = false
var is_sliding = false
var can_double_jump = false
var level_complete = false

onready var anim_player = $Body/AnimationPlayer
onready var left_wall_raycast = $LeftWallRaycast
onready var right_wall_raycast = $RightWallRaycast
onready var floor_raycast = $FloorRaycast
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer

func _apply_gravity(delta):
	velocity.y += gravity * delta
	# set is_jumping to false if player is jumping and moving downward
	if is_jumping and velocity.y >= 0:
		is_jumping = false

func _cap_gravity_wall_slide():
	var max_velocity = tile_size * 10 if Input.is_action_pressed("move_down") else tile_size
	velocity.y = min(velocity.y, max_velocity) 

func _apply_movement(delta):
	var snap = Vector2.DOWN if !is_jumping else Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP)

	var was_grounded = is_grounded
	is_grounded = _check_is_grounded()
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)

func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))

func _handle_movement(var speed = self.move_speed):
	var delta = get_physics_process_delta_time()
	# get movement keypresses, convert to integers, and then store in move_direction
	move_input_speed = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
	# lerp velocity.x towards the direction the player is pressing keys for, weighted based on if they're grounded or not
	velocity.x = lerp(velocity.x, speed * move_input_speed, _get_h_weight() * delta / (1/ideal_framerate))
	# set sprite facing based on the last movement key pressed
	if move_direction != 0:
		facing = move_direction

func _handle_wall_slide_sticking():
	if move_direction != 0 and move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()

func _get_h_weight():
	if _check_is_grounded():
		return 1
	else:
		if move_direction == 0:
			return 0.02
		elif move_direction == sign(velocity.x) and abs(velocity.x) > move_speed:
			return 0.0
		else:
			return 0.1

func jump():
	velocity.y = max_jump_velocity
	is_jumping = true
	is_double_jumping = false

func minimize_jump():
	if velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity

func subsequent_jump():
	if !is_double_jumping:
		velocity.y = max_jump_velocity
		is_double_jumping = true

func wall_jump():
	velocity.y = max_jump_velocity
	velocity.x = (max_jump_velocity / 2) * wall_direction

func _check_is_grounded():
	if floor_raycast.is_colliding():
		return true
	else:
		return false

func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycast)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycast)
	if is_near_wall_left and is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)

func _check_is_valid_wall(raycast):
	if raycast.is_colliding():
		var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
		if dot > PI * 0.35 and dot < PI * 0.55:
			return true
	return false

func wall_dir():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.x > 0:
			return "left"
		elif collision.normal.x < 0:
			return "right"
	return "none"
