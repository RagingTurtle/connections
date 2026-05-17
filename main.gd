extends Node2D
@onready var line_2d: Line2D = $Line2D
@onready var start_sprite_2d: Sprite2D = $StartSprite2D
var move_tween: Tween 
var last_connection
const LINE_SPEED: float = 300.0
const CLICK_RADIUS: float = 8.0
func _ready() -> void:
	#line_2d.global_position = start_sprite_2d.global_position
	line_2d.add_point(start_sprite_2d.position)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if move_tween and move_tween.is_running():
			return
			
		var local_mouse_pos: Vector2 = line_2d.to_local(event.position)
		var previous_end_pos: Vector2 = line_2d.get_point_position(line_2d.get_point_count() - 1)
		var distance: float = previous_end_pos.distance_to(local_mouse_pos)
		var duration: float = distance / LINE_SPEED
		line_2d.add_point(previous_end_pos)
		var last_point_index: int = line_2d.get_point_count() - 1
		
		move_tween = create_tween()
		
		move_tween.tween_method(
			move_point.bind(last_point_index),
			previous_end_pos,
			local_mouse_pos,
			duration 
			)
		if not connection_clicked(event.position):
			move_tween.tween_method(
				move_point.bind(last_point_index),
				local_mouse_pos,
				previous_end_pos,
				duration 
				)
			move_tween.tween_callback(line_2d.remove_point.bind(last_point_index))
		else:
			last_connection.remove_from_group("connection")

func move_point(current_tween_pos: Vector2, index: int) -> void:
	line_2d.set_point_position(index, current_tween_pos)

func connection_clicked(click_pos: Vector2) -> bool:
	var connection_list = get_tree().get_nodes_in_group("connection")
	for node in connection_list:
		if node is Node2D:
			if node.position.distance_to(click_pos) <= CLICK_RADIUS:
				last_connection = node
				return true
	return false
