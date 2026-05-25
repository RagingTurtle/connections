extends Node2D

@export var completion_image: CanvasItem

func _ready() -> void:
	if not completion_image and has_node("Sprite2D"):
		completion_image = $Sprite2D
		
	set_reveal_visibility(false)
	
func _on_level_complete() -> void:
	set_reveal_visibility(true)
	
func set_reveal_visibility(is_visible: bool) -> void:
	if completion_image:
		completion_image.visible = is_visible
