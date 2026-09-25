extends State

func physics_update(_delta: float) -> void:
	# If player breaks line of sight or leaves vision area
	if not monster.can_see_player():
		# Transition to Search state if ready, or fallback to Patrol
		if state_machine.states.has("search"):
			state_machine.transition_to("Search")
		else:
			state_machine.transition_to("Patrol")
		return

	# Continuously track player's live positionsw
	monster.move_to(monster.player.global_position)
	monster.execute_movement(monster.chase_speed)
