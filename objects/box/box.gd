extends RigidBody2D
class_name MovableBox

var player
var held = false
var infront_player


func _physics_process(delta):
	if held:
		var player_pos = player.global_position
		var idle_pos = Vector2(player_pos.x + infront_player, global_position.y)
		global_position += (idle_pos - global_position) / 2

func _on_GrabArea_body_entered(body):
	if body.name == 'Player':
		print('enter')
		player = body
		body.interact_object = self

func _on_GrabArea_body_exited(body):
	if body.name == 'Player':
		print('exit')
		#player = null
		body.interact_object = null
		# mode = RigidBody2D.MODE_RIGID

func action():
	held = !held
	if held:
		print('holding')
		mode = RigidBody2D.MODE_STATIC
		infront_player = -35 if player.facing < 0 else 35
		player.move_speed = player.move_speed / 2
	else:
		print('let go')
		mode = RigidBody2D.MODE_RIGID
		player.move_speed = player.move_speed * 2
