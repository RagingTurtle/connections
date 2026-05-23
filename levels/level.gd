extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.visible = false
	
func _on_level_complete() -> void:
	sprite_2d.visible = true
