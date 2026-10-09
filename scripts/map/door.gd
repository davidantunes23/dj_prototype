extends Area2D

@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var topsprite: Sprite2D = $"../Sprite2D2"
@onready var occlusion: LightOccluder2D = $"../LightOccluder2D"
@onready var door_collision: CollisionShape2D = $"../CollisionShape2D"
@onready var open_sound: AudioStreamPlayer2D = $"../Open"
@onready var close_sound: AudioStreamPlayer2D = $"../Close"

var is_open := false
var player_inside := false
var monster_inside := false

func _ready() -> void:
	add_to_group("door")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	#_set_open(false)

func can_interact(player: Player) -> bool:
	return not is_open

func interact(player: Player) -> void:
	if is_open:
		return
	_set_open(true)
	SoundEvents.emit_sound(global_position, "door")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
	if body.is_in_group("monster"):
		monster_inside = true
		if is_open:
			return
		_set_open(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		if is_open and !monster_inside:
			_set_open(false)
	if  body.is_in_group("monster"):
		monster_inside = false
		if is_open:
			_set_open(false)

func _set_open(value: bool) -> void:
	if value:
		open_sound.play()
	else:
		close_sound.play()
	is_open = value
	sprite.visible = !value
	if topsprite != null:
		topsprite.visible = !value
	occlusion.visible = !value
	# Disable the blocking collision while open so the player can walk through
	door_collision.set_deferred("disabled", value)
