class_name ConnectionPoint
extends Area2D

signal point_clicked(point: ConnectionPoint)

@export var _point_number: int = 0
@export var label_display: Label
@export var click_radius: float = 35.0

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


func _unhandled_input(event: InputEvent) -> void:
	if not input_pickable:
		return
		
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var local_click_pos := to_local(get_global_mouse_position())
		
		if local_click_pos.length() <= click_radius:
			point_clicked.emit(self)
			get_viewport().set_input_as_handled()


func connected() -> void:
	if point_number != 0:
		input_pickable = false


func reset() -> void:
	input_pickable = true


func emit_particles() -> void:
	sparkle_player.play()
	particles.restart()
