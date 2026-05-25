extends Node2D

signal level_completed
signal line_started(start_position: Vector2)
signal connection_attempted(target_position: Vector2, is_valid: bool)
signal level_started
signal level_won

@export var win_ui: CanvasLayer
@export var levels: Array[PackedScene]

@onready var line: Node2D = $AnimatedLine
@onready var win_sound: AudioStreamPlayer = $WinSound

var current_level_index: int = 0
var current_level: Node2D
var points_list: Array[ConnectionPoint] = []
var current_connection_point_index: int = 0
var wait_for_next: bool = false
var current_rules: LevelRules


func _ready() -> void:
	if levels.size() > 0:
		_instantiate_level(current_level_index)
		
	if win_ui and win_ui.has_signal("next_requested"):
		win_ui.next_requested.connect(next_button_pressed)
	
	if has_node("InteractionBackground"):
		var background := $InteractionBackground as Area2D
		background.background_clicked.connect(_handle_generic_click)


func _instantiate_level(index: int) -> void:
	current_level = levels[index].instantiate() as Node2D
	add_child(current_level)
	
	if current_level.has_method("_on_level_completed"):
		level_completed.connect(current_level._on_level_completed)
		
	load_level(current_level)


func _on_connection_clicked(point: ConnectionPoint) -> void:
	if wait_for_next: 
		return
		
	if line.has_method("is_busy") and line.is_busy():
		return
		
	var next_index := current_rules.get_next_index(current_connection_point_index, points_list.size())
	var is_next := point.point_number == points_list[next_index].point_number
	
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
	if wait_for_next or (line.has_method("is_busy") and line.is_busy()):
		return
		
	connection_attempted.emit(click_pos, false)
	
	if has_node("FailureSound"):
		var failure_sound := $FailureSound as AudioStreamPlayer
		failure_sound.play()


func load_level(level: Node2D) -> void:
	wait_for_next = false
	level_started.emit()
	current_connection_point_index = 0 
	
	if "rules" in level and level.rules is LevelRules:
		current_rules = level.rules as LevelRules
	else:
		current_rules = LevelRules.new()
		
	points_list = level.get_ordered_points()
	
	for node in points_list:
		var connection_point := node as ConnectionPoint
		if not connection_point.point_clicked.is_connected(_on_connection_clicked):
			connection_point.point_clicked.connect(_on_connection_clicked)
		connection_point.reset()
		
	if points_list.size() > 0:
		var start_point := points_list[current_connection_point_index] as ConnectionPoint
		line_started.emit(start_point.global_position)


func you_win() -> void:
	wait_for_next = true
	level_completed.emit()
	
	if win_sound:
		win_sound.play()
		
	level_won.emit()


func next_button_pressed() -> void:
	if is_instance_valid(current_level):
		if current_level.has_method("_on_level_completed") and level_completed.is_connected(current_level._on_level_completed):
			level_completed.disconnect(current_level._on_level_completed)
		current_level.queue_free()
	
	current_level_index = (current_level_index + 1) % levels.size()
	_instantiate_level(current_level_index)
