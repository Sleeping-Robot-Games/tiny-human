extends RigidBody2D
class_name MovableBox

var held = false


func _on_GrabArea_body_entered(body):
	if body.name == 'Player':
		body.interact_object = self


func _on_GrabArea_body_exited(body):
	if body.name == 'Player':
		body.interact_object = null

func action():
	held = !held
	if held:
		mode = RigidBody2D.MODE_STATIC
		
		print('holding')
	else:
		print('let go')
