extends Area3D

var dialogue_resource = preload("res://scenes/usb_dialogue/usb.dialogue")
var usb_balloon_scene = preload("res://scenes/usb_dialogue/balloon.tscn")

@onready var usb: StaticBody3D = $".."
@onready var proto_controller: CharacterBody3D = $"../../../../ProtoController"



func _on_body_entered(body: Node3D) -> void:
	#DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	if body.name == "ProtoController":
		var balloon = usb_balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(dialogue_resource, "start")
		
		proto_controller.add_item()
		usb.queue_free()
		proto_controller.check_items()
		
