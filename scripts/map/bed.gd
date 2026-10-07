extends Area2D

@onready var sprite_closed = $"../ClosedSprite2D"
@onready var sprite_open = $"../Sprite2D2"
@onready var sprite_decoy = $"../DecoySprite"

var used = false

func _ready() -> void:
	add_to_group("bed")
	body_entered.connect(_on_body_entered)

func interact(player: Player) -> void:
	if used: return

	var hand = player.get_hand()
	if hand != null and hand.get_type() == "decoy":
		used = true
		sprite_open.visible = false
		sprite_closed.visible = true
		sprite_decoy.visible = true

		player.hand.queue_free()
		player.hand = null

		SoundEvents.emit_sound(global_position)
		
func can_interact(player: Player) -> bool:
	if used: return false
	
	var current_hand = player.get_hand()
	return current_hand != null and current_hand.get_type() == "decoy"

func _on_body_entered(body: Node2D) -> void:
	if used and body.is_in_group("monster"):
		sprite_closed.visible = false
		sprite_decoy.visible = false
		sprite_open.visible = true
		
func remove_decoy() -> void:
	if used:
		sprite_closed.visible = false
		sprite_decoy.visible = false
		sprite_open.visible = true
