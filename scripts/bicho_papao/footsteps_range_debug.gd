@tool
extends Node2D
class_name FootstepRangeDebug

## Editor-only visual aid: draws two rings showing where footstep volume
## goes from full to silent, read live from a FootstepPlayer node so
## there's nothing to keep in sync by hand. Pure drawing, no gameplay
## logic here — safe to run in the editor.
##
## Place as a sibling of FootstepPlayer (both children of the monster) and
## leave this node's position at (0, 0) so the rings center on the monster.

@export var footstep_player_path: NodePath = "../Footsteps"

func _process(_delta: float) -> void:
	queue_redraw() # keeps the rings live as you tweak values in the Inspector

func _draw() -> void:
	var footsteps := get_node_or_null(footstep_player_path)
	if footsteps == null:
		return
	_draw_ring(footsteps.get("loud_distance"), Color.RED, "footsteps: full volume")
	_draw_ring(footsteps.get("silent_distance"), Color(1.0, 0.4, 0.4, 0.6), "footsteps: silent")

func _draw_ring(radius, color: Color, label: String) -> void:
	if radius == null or radius <= 0.0:
		return
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, color, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(6, -radius + 14), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
