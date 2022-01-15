extends Node2D

var follow_speed = 5 # smaller is faster

func _physics_process(delta):
	position += (get_global_mouse_position() - position) / follow_speed
	# offset needed?
	# see: https://godotengine.org/qa/11538/get-mouse-position-in-world
	#offset = get_local_mouse_position()
