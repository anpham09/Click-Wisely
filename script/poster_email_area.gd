extends Area3D

var dialogue_resource = preload("res://scenes/poster_dialogue (2)/poster2.dialogue")
var usb_balloon_scene = preload("res://scenes/poster_dialogue (2)/balloon.tscn")

@onready var usb: StaticBody3D = $".."

func _on_body_entered(body: Node3D) -> void:
	#DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	if body.name == "ProtoController":
		var balloon = usb_balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(dialogue_resource, "start")
		
		usb.queue_free()
		
