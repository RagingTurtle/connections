extends Area2D

signal background_clicked(click_position: Vector2)


func _ready() -> void:
	input_pickable = true


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		background_clicked.emit(get_global_mouse_position())
		get_viewport().set_input_as_handled()
