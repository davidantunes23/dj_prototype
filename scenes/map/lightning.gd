extends Node2D

@onready var thunder: AudioStreamPlayer = $Thunder

@export var min_interval: float = 4.0
@export var max_interval: float = 12.0
@export var peak_energy: float = 4.0
@export var base_energy: float = 0.0
@export_range(0.0, 0.3) var per_light_delay: float = 0.04 # slight offset so lights don't all fire in perfect sync
@export_range(0.0, 1.0) var energy_variation: float = 0.3 # random variation of peak per light

var _lights: Array[PointLight2D] = []

func _ready() -> void:
	randomize()
	for child in get_children():
		if child is PointLight2D:
			_lights.append(child)
			child.energy = base_energy
	_strike_loop()

func _strike_loop() -> void:
	while is_inside_tree():
		await get_tree().create_timer(randf_range(min_interval, max_interval)).timeout
		_strike()

func _strike() -> void:
	for light in _lights:
		var peak := peak_energy * randf_range(1.0 - energy_variation, 1.0)
		var tween := create_tween()

		# Optional small random delay per light for a more organic look
		tween.tween_interval(randf() * per_light_delay)

		# Main flash: near-instant ramp up
		tween.tween_property(light, "energy", peak, 0.03)
		# Quick dip
		tween.tween_property(light, "energy", peak * 0.2, 0.05)
		# Second, slightly weaker flash
		tween.tween_property(light, "energy", peak * 0.8, 0.03)
		# Small flicker
		tween.tween_property(light, "energy", peak * 0.4, 0.04)
		# Final short pulse
		tween.tween_property(light, "energy", peak * 0.6, 0.02)
		# Slow fade out
		tween.tween_property(light, "energy", base_energy, randf_range(0.25, 0.5)) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(randf_range(0, 1.5)).timeout
	thunder.play()
