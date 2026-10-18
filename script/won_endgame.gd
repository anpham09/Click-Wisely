extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.name == "ProtoController":
		get_tree().change_scene_to_file("res://scenes/endgame_won.tscn")
	
