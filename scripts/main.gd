extends Node2D

signal level_complete

@onready var line: AnimatedLine = $AnimatedLine
@onready var win_ui: CanvasLayer = $WinUI
@export var levels: Array[PackedScene]
@onready var win_sound: AudioStreamPlayer = $WinSound

var current_level_index: int = 0
var current_level: Node2D
var points_list: Array
var current_connection_point_index: int = 0
var wait_for_next: bool = false

func _ready() -> void:
	if levels.size() > 0:
		_instantiate_level(current_level_index)
	win_ui.get_node("Panel/Button").pressed.connect(next_button_pressed)

func _instantiate_level(index: int) -> void:
	current_level = levels[index].instantiate()
	add_child(current_level)
	load_level(current_level)
	level_complete.connect(current_level._on_level_complete)

func _input(event: InputEvent) -> void:
	if wait_for_next:
		return
		
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if line.active_tween and line.active_tween.is_running():
			return
			
		get_tree().process_frame.connect(
			func(): _handle_generic_click(get_global_mouse_position()),
			CONNECT_ONE_SHOT
		)
	
func _on_connection_clicked(point: ConnectionPoint) -> void:
	if wait_for_next: 
		return
	if line.active_tween and line.active_tween.is_running():
		return
		
	var next_index: int = (current_connection_point_index + 1) % points_list.size()
	var is_next: bool = point.point_number == points_list[next_index].point_number
	
	line.draw_to_target(point.global_position, is_next)
	
	if is_next:
		point.connected()
		point.emit_particles()
		current_connection_point_index = next_index
		if current_connection_point_index == 0:
			line.active_tween.finished.connect(you_win, CONNECT_ONE_SHOT)
		
func _handle_generic_click(click_pos: Vector2) -> void:
	if not line.active_tween or not line.active_tween.is_running():
		line.draw_to_target(click_pos, false)
		$FailureSound.play()

func load_level(level: Node2D) -> void:
	wait_for_next = false
	win_ui.visible = false
	current_connection_point_index = 0 
	
	if level.has_node("Sprite2D"):
		level.get_node("Sprite2D").visible = false

	points_list.clear()
	for child in level.get_children():
		if child is ConnectionPoint:
			if not child.clicked.is_connected(_on_connection_clicked):
				child.clicked.connect(_on_connection_clicked)
			child.reset()
			points_list.append(child)
			
	points_list.sort_custom(sorted_points)
	
	if points_list.size() > 0:
		line.clear_and_start(points_list[current_connection_point_index].global_position)
	
func sorted_points(a: ConnectionPoint, b: ConnectionPoint) -> bool:
	return a.point_number < b.point_number

func you_win() -> void:
	level_complete.emit()
	win_sound.play()
	win_ui.visible = true
	wait_for_next = true

func next_button_pressed() -> void:
	current_level.queue_free()
	current_level_index = (current_level_index + 1) % levels.size()
	_instantiate_level(current_level_index)
