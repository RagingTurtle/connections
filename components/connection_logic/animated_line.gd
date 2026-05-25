class_name AnimatedLine
extends Line2D

signal animation_finished

const LINE_SPEED: float = 300.0
var active_tween: Tween 

func _ready() -> void:
	var manager = get_parent()
	if manager:
		if manager.has_signal("line_started"):
			manager.line_started.connect(clear_and_start)
		if manager.has_signal("connection_attempted"):
			manager.connection_attempted.connect(draw_to_target)

func is_busy() -> bool:
	return active_tween != null and active_tween.is_running()
	
func clear_and_start(start_global_pos: Vector2) -> void:
	clear_points()
	add_point(to_local(start_global_pos))
	
func draw_to_target(target_global_pos: Vector2, is_valid: bool) -> void:
	if is_busy():
		active_tween.kill()
	
	var local_target: Vector2 = to_local(target_global_pos)
	var last_idx: int = get_point_count() - 1
	var start_local_pos: Vector2 = get_point_position(last_idx)
	
	var distance: float = start_local_pos.distance_to(local_target)
	
	if distance < 0.01:
		return
		
	var duration: float = distance / LINE_SPEED
	active_tween = create_tween()
	
	var point_index: int = get_point_count()
	add_point(start_local_pos)
		
	active_tween.tween_method(
		_update_point_position.bind(point_index),
		start_local_pos,
		local_target,
		duration
	)
	
	if not is_valid:
		active_tween.tween_method(
			_update_point_position.bind(point_index),
			local_target,
			start_local_pos,
			duration
		)
		active_tween.tween_callback(remove_point.bind(point_index))
	else:
		active_tween.tween_callback(func(): animation_finished.emit())
		
func _update_point_position(current_pos: Vector2, index: int) -> void:
	set_point_position(index, current_pos)
