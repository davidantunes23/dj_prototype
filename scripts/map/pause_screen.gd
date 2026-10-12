extends CanvasLayer

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		get_tree().paused = true
		show()
		
	elif event.is_action_pressed("ui_accept") and get_tree().paused:
		get_tree().paused = false
		hide()
