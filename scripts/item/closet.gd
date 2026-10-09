extends Area2D


@onready var noise_timer = $"../NoiseTimer"
@onready var noise_market = $"../Marker2d"

@onready var timeout_noise = $"../TimeoutSound"

@onready var animation = $"../AnimationPlayer"

var is_destroyed := false
var player_inside := false
var hidden_player: Player = null

func _ready() -> void:
	add_to_group("closet")
	noise_timer.timeout.connect(_on_noise_timer_timeout)

func can_interact(player: Player) -> bool:
	if is_destroyed or animation.is_playing(): return false
	return !player_inside or hidden_player == player

func interact(player: Player) -> void:
	if is_destroyed or animation.is_playing(): return
	
	if !player_inside:
		player_inside = true
		hidden_player = player
		animation.play("open")
		
		noise_timer.stop()
		noise_timer.start()
	else:
		animation.play("exit")

func _on_noise_timer_timeout() -> void:
	timeout_noise.play()
	SoundEvents.emit_sound(noise_market.global_position, "closet")

func _hide_player():
	if hidden_player:
		hidden_player.set_hidden_state(true)
	noise_timer.start()
	
func _show_player():
	if hidden_player:
		hidden_player.set_hidden_state(false)
	player_inside = false
	hidden_player = null
	noise_timer.stop()
	
func _hide_monster():
	pass
	
func _show_monster():
	pass
	
func get_break_target_position() -> Vector2:
	if noise_market:
		return noise_market.global_position
	return global_position

func break_closet() -> void:
	if is_destroyed: return
	
	is_destroyed = true
	noise_timer.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	
	animation.play("break")
	
	await animation.animation_finished
	
	if player_inside and hidden_player != null:
		hidden_player.set_hidden_state(false)
