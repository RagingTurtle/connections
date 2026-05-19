extends Node2D

@onready var start_connection_point: ConnectionPoint = $StartConnectionPoint
@onready var line: AnimatedLine = $AnimatedLine

func _ready() -> void:
	line.clear_and_start(start_connection_point.global_position)
	start_connection_point.remove_from_group("connection")
	for node in get_tree().get_nodes_in_group("connection"):
		if node is ConnectionPoint:
			node.clicked.connect(_on_connection_clicked)
				
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if line.active_tween and line.active_tween.is_running():
			return
			
		get_tree().process_frame.connect(
			func(): _handle_generic_click(get_global_mouse_position()),
			CONNECT_ONE_SHOT
		)
	
func _on_connection_clicked(point: ConnectionPoint) -> void:
	line.draw_to_target(point.global_position, true)
		
func _handle_generic_click(click_pos: Vector2) -> void:
	if not line.active_tween or not line.active_tween.is_running():
		line.draw_to_target(click_pos, false)
