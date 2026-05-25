extends CanvasLayer

const MAIN = preload("uid://bt6a6rx0rdsas")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN)
