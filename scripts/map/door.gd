extends Area2D

func interact(player: Player) -> void:
	var hand = player.get_hand()
	if hand != null and hand.get_type() == "key":
		print("exit") # TODO end
