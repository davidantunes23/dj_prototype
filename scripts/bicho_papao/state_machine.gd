extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Wait for the parent (Monster) to be fully ready before initializing
	await owner.ready
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.monster = owner as CharacterBody2D
			child.state_machine = self
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state
		_update_debug_label()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func transition_to(target_state_name: String) -> void:
	var key = target_state_name.to_lower()
	if not states.has(key):
		push_warning("State Machine: State '%s' does not exist." % target_state_name)
		return
		
	var new_state: State = states[key]
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter()
	_update_debug_label()

func _update_debug_label() -> void:
	if owner.has_node("DebugLabel") and current_state:
		owner.get_node("DebugLabel").text = current_state.name
