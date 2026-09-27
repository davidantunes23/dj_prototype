extends Node
# Autoload singleton (register in Project Settings > Autoload as "SoundEvents").
#
# A simple global signal bus so any script can announce "the player made a
# noise here" without needing a direct reference to every monster in the
# scene, and without the monster needing a reference to the player.

signal player_made_sound(sound_position: Vector2)

func emit_sound(sound_position: Vector2) -> void:
	player_made_sound.emit(sound_position)
