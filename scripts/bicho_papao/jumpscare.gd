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

func trigger() -> void:
	if is_active:
		return
	is_active = true
	visible = true
	audio_player.play()
	await get_tree().create_timer(display_duration).timeout
	visible = false
	is_active = false
