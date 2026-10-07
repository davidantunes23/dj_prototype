extends AudioStreamPlayer2D
class_name MonsterFootsteps

@export var footstep_sounds: Array[AudioStream] = []
@export var step_distance: float = 40.0   # distance traveled between footsteps

@export_group("Volume falloff")
@export var loud_distance: float = 75     # at/below this distance -> full volume
@export var silent_distance: float = 400  # at/beyond this distance -> silent
@export var volume_db_near: float = 15
@export var volume_db_far: float = -40.0

var _monster: CharacterBody2D
var _player: Node2D
var _last_position: Vector2
var _distance_traveled: float = 0.0

func _ready() -> void:
	_monster = get_parent() as CharacterBody2D
	_last_position = _monster.global_position
	_find_player()
	max_distance = silent_distance * 4.0 # keep Godot's own falloff out of the way

func _physics_process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_find_player()
		return

	var moved: float = _monster.global_position.distance_to(_last_position)
	_last_position = _monster.global_position

	_distance_traveled += moved
	if _distance_traveled >= step_distance:
		_distance_traveled = 0.0
		_play_footstep()

func _play_footstep() -> void:
	if footstep_sounds.is_empty():
		return
	stream = footstep_sounds.pick_random()
	volume_db = _volume_for_distance(_monster.global_position.distance_to(_player.global_position))
	play()

func _volume_for_distance(distance: float) -> float:
	var t: float = clampf(inverse_lerp(loud_distance, silent_distance, distance), 0.0, 1.0)
	return lerp(volume_db_near, volume_db_far, t)

func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
