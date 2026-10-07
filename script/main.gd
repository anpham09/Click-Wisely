extends Node3D

@onready var canvas_layer: CanvasLayer = %CanvasLayer

var dialogue_resource = preload("res://scenes/usb_dialogue/usb.dialogue")

var balloon_scene = preload("res://addons/dialogue_manager/balloon.tscn")

func _ready() -> void:
	#try()
	pass

#func try():
	#var balloon = balloon_scene.instantiate()
	#canvas_layer.add_child(balloon)
	#balloon.start(dialogue_resource, "start")
	


#func _on_area_3d_body_entered(body: Node3D) -> void:
	#DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	
