extends Node2D

@export_range(0.0, 2.0, 0.05) var click_delay: float = 0.05

@onready var click_audio: AudioStreamPlayer = $ClickAudio
@onready var credits_button: Button = $CreditsButton


func _on_button_pressed() -> void:
	click_audio.play()
	await get_tree().create_timer(click_delay).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_credits_button_pressed() -> void:
	click_audio.play()
	await get_tree().create_timer(click_delay).timeout
	get_tree().change_scene_to_file("res://scenes/credit_screen.tscn")
