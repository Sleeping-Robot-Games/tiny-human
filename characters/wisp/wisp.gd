extends Node2D

var is_idle = true
var follow_speed = 10 # smaller is faster
#var cursor = load("res://characters/wisp/cursor.png")
onready var prev_mouse_pos = get_viewport().get_mouse_position()

func _ready():
	# hide mouse cursor?
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# replace mouse cursor?
	#Input.set_custom_mouse_cursor(cursor)
	pass

# offset adjustment needed?
# see: https://godotengine.org/qa/11538/get-mouse-position-in-world
func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	
	# determine if mouse is idle or not
	if mouse_pos != prev_mouse_pos:
		is_idle = false
		$IdleMouseTimer.stop()
	elif $IdleMouseTimer.time_left == 0:
		$IdleMouseTimer.start()
	
	# move towards player if mouse is idle, otherwise move towards mouse
	if is_idle:
		modulate.a = 0.25
		var player_node = get_parent()
		var player_pos = player_node.global_position
		var behind_player = 20 if player_node.facing < 0 else -20
		var idle_pos = Vector2(player_pos.x + behind_player, player_pos.y + 5)
		global_position += (idle_pos - global_position) / follow_speed
	else:
		modulate.a = 0.5
		global_position += (get_global_mouse_position() - global_position) / follow_speed
	
	# setup current mouse position as next frame's previous mouse position
	prev_mouse_pos = mouse_pos

func _on_IdleMouseTimer_timeout():
	is_idle = true
