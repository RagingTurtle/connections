class_name ConnectionPoint
extends Area2D

signal clicked(point: ConnectionPoint)

@export var _point_number: int = 0
@export var label_display: Label

var point_number: int:
	get:
		return _point_number
	set(value):
		_point_number = value
		if label_display:
			label_display.text = str(_point_number)

@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var sparkle_player: AudioStreamPlayer2D = $SparklePlayer

func _ready() -> void:
	input_pickable = true
	point_number = _point_number
	
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
		get_viewport().set_input_as_handled()

func connected() -> void:
	if point_number != 0:
		input_pickable = false

func reset() -> void:
		input_pickable = true
	
func emit_particles() -> void:
	sparkle_player.play()
	particles.restart()
