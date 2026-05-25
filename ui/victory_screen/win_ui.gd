extends CanvasLayer

signal next_requested

@onready var button: Button = $Panel/Button

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	next_requested.emit()
