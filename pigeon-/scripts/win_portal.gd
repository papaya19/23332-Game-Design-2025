extends Area2D


func _on_body_entered(body):
	if body.name == 'newPlayer':
		call_deferred("change_scene")
		
func change_scene():
	get_tree().change_scene_to_file("res://scenes/win.tscn")
