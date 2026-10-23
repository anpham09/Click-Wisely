extends Node2D

@export_range(0.0, 2.0, 0.05) var click_delay: float = 0.2

@onready var click_audio: AudioStreamPlayer = $ClickAudio


func _on_button_pressed() -> void:
	click_audio.play()
	await get_tree().create_timer(click_delay).timeout

	get_tree().change_scene_to_file("res://scenes/home_screen.tscn")
