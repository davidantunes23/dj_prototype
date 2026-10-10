extends CanvasLayer

@export var jumpscare_image: Texture2D
@export var jumpscare_sound: AudioStream
@export var display_duration: float = 1.5

@onready var image_rect: TextureRect = %JumpscareImage
@onready var audio_player: AudioStreamPlayer = %JumpscareAudio

var is_active: bool = false

func _ready() -> void:
	visible = false
	if jumpscare_image:
		image_rect.texture = jumpscare_image
	if jumpscare_sound:
		audio_player.stream = jumpscare_sound
		
	image_rect.pivot_offset = image_rect.size / 2.0

func trigger(catch_count: int) -> void:
	if is_active:
		return
	
	is_active = true
	visible = true
	
	if catch_count == 1:
		image_rect.scale = Vector2(1.0, 1.0)
		image_rect.modulate = Color(0.8, 0.8, 0.8, 0.9)
		
	elif catch_count == 2:
		image_rect.scale = Vector2(1.3, 1.3)
		image_rect.modulate = Color(1.0, 0.5, 0.5, 1.0)
	
	elif catch_count == 3:
		image_rect.scale = Vector2(1.8, 1.8)
		image_rect.modulate = Color(0.8, 0.1, 0.1, 1.0)
	
	elif catch_count <= 4:
		image_rect.scale = Vector2(3.0, 3.0)
		image_rect.modulate = Color(0.4, 0.0, 0.0, 1.0)
		
	audio_player.play()
	await get_tree().create_timer(display_duration).timeout
	
	visible = false
	is_active = false
