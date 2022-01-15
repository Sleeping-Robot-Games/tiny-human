extends RigidBody2D

class_name MovableBox

var player
var held = false
var infront_player

func _physics_process(delta):
	if held:
		var player_pos = player.global_position
		var idle_pos = Vector2(player_pos.x + infront_player, global_position.y)
		global_position += (idle_pos - global_position) /2 

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
	print(held)
	if held:
		let_go()
	else:
		grab()

func grab():
	held = true
	# find if box is on left or right
	player.box_on_left = global_position.x < player.global_position.x
	# then use the new facing direction to get infront_player var
	infront_player = -25 if player.box_on_left else 25
	player.move_speed = player.move_speed / 2
	
func let_go():
	held = false
	player.move_speed = player.move_speed * 2
