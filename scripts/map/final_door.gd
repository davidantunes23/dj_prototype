extends Area2D

func interact(player: Player) -> void:
	var hand = player.get_hand()
	if hand != null and hand.get_type() == "key":
		get_tree().change_scene_to_file("res://scenes/map/escape_screen.tscn")

func can_interact(player: Player) -> bool:
	var current_hand = player.get_hand()
	return current_hand != null and current_hand.get_type() == "key"
