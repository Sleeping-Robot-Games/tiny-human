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
		player = body
		body.interact_object = self

func _on_GrabArea_body_exited(body):
	if body.name == 'Player':
		if held:
			let_go()
		body.interact_object = null

func action():
	if held:
		let_go()
	else:
		grab()
		
func grab():
	held = true
	infront_player = -30 if player.facing < 0 else 30
	player.move_speed = player.move_speed / 2
	
func let_go():
	held = false
	player.move_speed = player.move_speed * 2
	
	
