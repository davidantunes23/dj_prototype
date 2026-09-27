extends State

@export var arrival_radius: float = 15.0

func enter() -> void:
	SoundEvents.player_made_sound.connect(_on_player_made_sound)

func exit() -> void:
	if SoundEvents.player_made_sound.is_connected(_on_player_made_sound):
		SoundEvents.player_made_sound.disconnect(_on_player_made_sound)

func _on_player_made_sound(sound_position: Vector2) -> void:
	monster.last_player_position = sound_position

func physics_update(_delta: float) -> void:
	# If player breaks line of sight or leaves vision area
	if monster.can_see_player():
		state_machine.transition_to("Chase")
		return

	# Continuously track player's live positions
	if monster.global_position.distance_to(monster.get_last_player_position()) <= arrival_radius:
		state_machine.transition_to("Patrol")
	else:
		monster.move_to(monster.get_last_player_position())
		monster.execute_movement()
