extends Area3D

var dialogue_resource = preload("res://scenes/usb_confidential_dialogue/usb.dialogue")
var usb_balloon_scene = preload("res://scenes/usb_confidential_dialogue/balloon.tscn")
@onready var paper_fwoosh: AudioStreamPlayer = $"../../../../ProtoController/PaperFwoosh"

@onready var usb: StaticBody3D = $".."
@onready var proto_controller: CharacterBody3D = $"../../../../ProtoController"

func _on_body_entered(body: Node3D) -> void:
	#DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	if body.name == "ProtoController":
		paper_fwoosh.play()
		var balloon = usb_balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(dialogue_resource, "start", [body])
		#balloon.start(dialogue_resource, "start")
		
		usb.queue_free()
		
		
