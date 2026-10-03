extends Control

@onready var audio = $AudioStreamPlayer

func _ready() -> void:
	audio.play()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/map/start_screen.tscn")
