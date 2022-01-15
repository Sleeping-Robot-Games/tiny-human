extends Node

var movement_disabled = false
var state = null setget set_state
var previous_state = null
var states = {}

onready var parent = get_parent()

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("double_jump")
	add_state("fall")
	add_state("wall_slide")
	add_state("push")
	add_state("idle_push")
	add_state("pull")
	add_state("idle_pull")
	call_deferred("set_state", states.idle)

func _physics_process(delta):
	
	print(parent.velocity.x)
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)

func set_state(new_state):
	previous_state = state
	state = new_state
	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)

func add_state(state_name):
	states[state_name] = states.size()

func _input(event):
	if state == states.idle  and parent.interact_object or state == states.push or state == states.idle_push or state == states.pull or state == states.idle_pull:
		if event.is_action_pressed("interact"):
			parent.interact_object.action() # passes the interact logic to item
	if state == states.idle or state == states.run:
		if event.is_action_pressed("jump"):
			parent.jump()
	elif state == states.jump:
		if event.is_action_released("jump"):
			parent.minimize_jump()
		elif event.is_action_pressed("jump"):
			parent.subsequent_jump()
	elif state == states.fall:
		if event.is_action_pressed("jump"):
			parent.subsequent_jump()
	elif state == states.wall_slide:
		if event.is_action_pressed("jump"):
			parent.wall_jump()
			set_state(states.jump)

func _state_logic(delta):
	if not movement_disabled:
		parent._update_move_direction()
		parent._update_wall_direction()
		if state != states.wall_slide:
			parent._handle_movement()
		parent._apply_gravity(delta)
		if state == states.wall_slide:
			parent._cap_gravity_wall_slide()
			parent._handle_wall_slide_sticking()
		parent._apply_movement(delta)

func _get_transition(delta):
	var direction = "_left" if parent.facing < 0 else "_right"
	match state:
		states.idle:
			if !parent._check_is_grounded():
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
			elif parent.interact_object is MovableBox and parent.interact_object.held:
				if parent.facing < 0 and parent.box_on_left:
					return states.idle_push
				elif parent.facing < 0 and not parent.box_on_left:
					return states.idle_pull
				elif parent.facing > 0 and parent.box_on_left:
					return states.idle_pull
				elif parent.facing > 0 and not parent.box_on_left:
					return states.idle_push
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent._check_is_grounded():
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
			elif !parent.anim_player.current_animation.ends_with(direction):
				return states.run
		states.jump:
			if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_double_jumping:
				return states.double_jump
			elif parent.velocity.y >= 0:
				return states.fall
			elif parent._check_is_grounded():
				return states.idle
		states.double_jump:
			if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
				parent.is_double_jumping = false
				return states.wall_slide
			elif parent.velocity.y >= 0:
				return states.fall
			elif parent._check_is_grounded():
				parent.is_double_jumping = false
				return states.idle
		states.fall:
			if (parent.wall_direction != 0 and parent.wall_direction == parent.facing) and parent.wall_slide_cooldown.is_stopped():
				parent.is_double_jumping = false
				return states.wall_slide
			elif parent._check_is_grounded():
				parent.is_double_jumping = false
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		states.wall_slide:
			if parent._check_is_grounded():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
		states.push:
			print('push')
			print(parent.velocity.x)
			if not parent.interact_object or not 'held' in parent.interact_object or not parent.interact_object.held:
				return states.idle
			elif parent.velocity.x == 0: 
				return states.idle_push
			elif (parent.facing < 0 and not parent.box_on_left) or (parent.facing > 0 and parent.box_on_left):
				return states.pull
		states.idle_push:
			if not parent.interact_object or not 'held' in parent.interact_object or not parent.interact_object.held:
				return states.idle
			elif parent.velocity.x != 0:
				if (parent.facing < 0 and not parent.box_on_left) or (parent.facing > 0 and parent.box_on_left):
					return states.pull
				elif (parent.facing < 0 and parent.box_on_left) or (parent.facing > 0 and not parent.box_on_left):
					return states.push
		states.pull:
			if not parent.interact_object or not 'held' in parent.interact_object or not parent.interact_object.held:
				return states.idle
			elif parent.velocity.x == 0:
				return states.idle_pull
			elif (parent.facing < 0 and parent.box_on_left) or (parent.facing > 0 and not parent.box_on_left):
				return states.push
		states.idle_pull:
			if not parent.interact_object or not 'held' in parent.interact_object or not parent.interact_object.held:
				return states.idle
			elif parent.velocity.x != 0:
				if (parent.facing < 0 and not parent.box_on_left) or (parent.facing > 0 and parent.box_on_left):
					return states.pull
				elif (parent.facing < 0 and parent.box_on_left) or (parent.facing > 0 and not parent.box_on_left):
					return states.push
	return null

func _enter_state(new_state, old_state):
	var direction = "_left" if parent.facing < 0 else "_right"
	if OS.is_debug_build():
		parent.get_node("StateLabel").text = states.keys()[new_state].to_lower() + direction
	else:
		parent.get_node("StateLabel").hide()
	match new_state:
		states.idle:
			parent.anim_player.play("idle" + direction)
		states.run:
			parent.anim_player.play("run" + direction)
		states.jump:
			parent.anim_player.play("jump" + direction)
		states.double_jump:
			parent.anim_player.play("jump" + direction)
		states.fall: ## TODO: Animations not found
			parent.anim_player.play("fall" + direction)
		states.wall_slide:
			parent.anim_player.play("wall_slide" + direction)
		states.push:
			parent.anim_player.play("push" + direction)
		states.idle_push:
			parent.anim_player.play("push_idle" + direction)
		states.pull:
			parent.anim_player.play("pull" + direction)
		states.idle_pull:
			parent.anim_player.play("pull_idle" + direction)

func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wall_slide_cooldown.start()

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)
