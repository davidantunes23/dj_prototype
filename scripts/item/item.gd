extends Area2D
class_name Item

var held: bool = false
var parent_initial: Node
var transform_initial: Transform2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_initial = get_parent()
	transform_initial = transform

func _on_body_entered(body: Node2D) -> void:
	if held == false and body is Player:
		held = body.try_pickup(self)
		if held:
			call_deferred("attach", body)

func get_type() -> String:
	return "base"

func attach(player: Player) -> void:
	reparent(player.get_item_holder(), false)
	self.position = Vector2.ZERO

func drop(position: Vector2) -> void:
	held = false

	reparent(parent_initial, true)
	self.scale = transform_initial.get_scale()
