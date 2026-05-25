extends Node2D

signal level_complete
signal line_started(start_position: Vector2)
signal connection_attempted(target_position: Vector2, is_valid: bool)

@onready var line: Node2D = $AnimatedLine
@onready var win_ui: CanvasLayer = $WinUI
@export var levels: Array[PackedScene]
@onready var win_sound: AudioStreamPlayer = $WinSound

var current_level_index: int = 0
var current_level: Node2D
var points_list: Array
var current_connection_point_index: int = 0
var wait_for_next: bool = false
var current_rules: LevelRules

func _ready() -> void:
	if levels.size() > 0:
		_instantiate_level(current_level_index)
	win_ui.next_requested.connect(next_button_pressed)

func _instantiate_level(index: int) -> void:
	current_level = levels[index].instantiate()
	add_child(current_level)
	load_level(current_level)
	level_complete.connect(current_level._on_level_complete)

func _input(event: InputEvent) -> void:
	if wait_for_next:
		return
		
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if line.has_method("is_busy") and line.is_busy():
			return
			
		get_tree().process_frame.connect(
			func(): _handle_generic_click(get_global_mouse_position()),
			CONNECT_ONE_SHOT
		)
	
func _on_connection_clicked(point: ConnectionPoint) -> void:
	if wait_for_next: 
		return
	if line.has_method("is_busy") and line.is_busy():
		return
		
	var next_index: int = current_rules.get_next_index(current_connection_point_index, points_list.size())
	var is_next: bool = point.point_number == points_list[next_index].point_number
	
	connection_attempted.emit(point.global_position, is_next)
	
	if is_next:
		point.connected()
		point.emit_particles()
		current_connection_point_index = next_index
		if current_rules.check_win_condition(current_connection_point_index, points_list.size()):
			if line.has_signal("animation_finished"):
				await line.animation_finished
			you_win()
		
func _handle_generic_click(click_pos: Vector2) -> void:
	if line.has_method("is_busy") and line.is_busy():
		return
		
	connection_attempted.emit(click_pos, false)
	$FailureSound.play()

func load_level(level: Node2D) -> void:
	wait_for_next = false
	win_ui.visible = false
	current_connection_point_index = 0 
	points_list.clear()
	
	if "rules" in level and level.rules is LevelRules:
		current_rules = level.rules
	else:
		current_rules = LevelRules.new()
		
	var all_dots = get_tree().get_nodes_in_group("connection")
	
	for node in all_dots:
		if level.is_ancestor_of(node) and node is ConnectionPoint:
			if not node.clicked.is_connected(_on_connection_clicked):
				node.clicked.connect(_on_connection_clicked)
			node.reset()
			points_list.append(node)
			
	points_list.sort_custom(sorted_points)
	
	if points_list.size() > 0:
		line_started.emit(points_list[current_connection_point_index].global_position)
	
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
