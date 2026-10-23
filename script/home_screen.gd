extends Node2D


@onready var click_audio: AudioStreamPlayer = $ClickAudio


func _on_button_pressed() -> void:
	click_audio.play()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
