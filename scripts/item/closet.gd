extends Area2D


@onready var sprite_normal = $SpriteNormal
@onready var sprite_broken = $SpriteBroken
@onready var noise_timer = $NoiseTimer

var is_destroyed := false
var player_inside := false
var hidden_player: Player = null

func _ready() -> void:
	add_to_group("closet")
	body_entered.connect(_on_body_entered)
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
		
func _on_noise_timer_timeout() -> void:
	SoundEvents.emit_sound(global_position)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("monster") and player_inside and not is_destroyed:
		is_destroyed = true
		sprite_normal.visible = false
		sprite_broken.visible = true
		noise_timer.stop()
	
	if hidden_player:
		hidden_player.set_hidden_state(false)
		hidden_player.apply_catch_penalty()
		hidden_player = null
 
