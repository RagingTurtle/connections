class_name ConnectionPoint
extends Area2D

signal clicked(point: ConnectionPoint)

var is_connected: bool = false

func _ready() -> void:
	input_pickable = true
	
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		is_connected = true
		clicked.emit(self)
		input_pickable = false
