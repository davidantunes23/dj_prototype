extends Control

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	anim_player.play("intro")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/map/audio_screen.tscn")
