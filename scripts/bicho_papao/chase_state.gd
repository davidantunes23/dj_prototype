extends State
@onready var laugh_sound: AudioStreamPlayer = $Laugh

func physics_update(_delta: float) -> void:
	# If player breaks line of sight or leaves vision area
	if monster.player != null:
		monster.last_player_position = monster.player.global_position
	if not monster.can_see_player():
		state_machine.transition_to("Investigate")
		return

	# Continuously track player's live positions
	monster.move_to(monster.player.global_position)
	monster.execute_movement(monster.chase_speed)
	
func enter() -> void:
	laugh_sound.play()
