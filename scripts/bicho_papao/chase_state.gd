extends State

func physics_update(_delta: float) -> void:
	# If player breaks line of sight or leaves vision area
	if monster.player == null or not monster.can_see_player():
		state_machine.transition_to("Investigate")
		return
		
	monster.last_player_position = monster.player.global_position

	# Continuously track player's live positions
	monster.move_to(monster.player.global_position)
	monster.execute_movement(monster.chase_speed)
