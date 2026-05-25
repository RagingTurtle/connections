extends CanvasLayer

@export var start_scene: PackedScene

func _on_button_pressed() -> void:
	if start_scene:
		get_tree().change_scene_to_packed(start_scene)
	else:
		push_error("Main Menu Error: 'start_scene' is not assigned in the Inspector.")
