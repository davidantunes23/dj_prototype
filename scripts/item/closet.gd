extends Area2D


@onready var sprite_normal = $SpriteNormal
@onready var sprite_broken = $SpriteBroken
@onready var noise_timer = $NoiseTimer
@onready var noise_market = $Marker2d

var is_destroyed := false
var player_inside := false
var hidden_player: Player = null

func _ready() -> void:
	add_to_group("closet")
	noise_timer.timeout.connect(_on_noise_timer_timeout)

func can_interact(player: Player) -> bool:
	if is_destroyed: return false
	return !player_inside or hidden_player == player

func interact(player: Player) -> void:
	if is_destroyed: return
	
	if !player_inside:
		player_inside = true
		hidden_player = player
		player.set_hidden_state(true)
		noise_timer.start()
	else:
		player_inside = false
		player.set_hidden_state(false)
		hidden_player = null
		noise_timer.stop()

func break_closet() -> void:
	if is_destroyed: return
	
	is_destroyed = true
	sprite_normal.visible = false
	sprite_broken.visible = true
	noise_timer.stop()
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	if player_inside and hidden_player != null:
		hidden_player.set_hidden_state(false) 

func _on_noise_timer_timeout() -> void:
	# TODO: Put closet noise here
	SoundEvents.emit_sound(noise_market.global_position)
