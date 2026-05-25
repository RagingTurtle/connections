extends Node2D

@export var completion_image: CanvasItem
@export var rules: LevelRules = LevelRules.new()


func _ready() -> void:
	if not completion_image and has_node("Sprite2D"):
		completion_image = $Sprite2D as CanvasItem
		
	set_reveal_visibility(false)


func _on_level_completed() -> void:
	set_reveal_visibility(true)


func set_reveal_visibility(should_be_is_visible: bool) -> void:
	if completion_image:
		completion_image.visible = should_be_is_visible


func get_ordered_points() -> Array[ConnectionPoint]:
	var ordered_points: Array[ConnectionPoint] = []
	var all_dots := get_tree().get_nodes_in_group("connection")
	
	for node in all_dots:
		if is_ancestor_of(node) and node is ConnectionPoint:
			ordered_points.append(node as ConnectionPoint)
			
	ordered_points.sort_custom(sorted_points)
	
	return ordered_points


func sorted_points(a: ConnectionPoint, b: ConnectionPoint) -> bool:
	return a.point_number < b.point_number
