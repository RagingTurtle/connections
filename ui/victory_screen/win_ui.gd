extends CanvasLayer

signal next_requested

@onready var button: Button = $Panel/Button

func _ready() -> void:
	visible = false
	button.pressed.connect(_on_button_pressed)

	var manager = get_parent()
	if manager:
		if manager.has_signal("level_won"):
			manager.level_won.connect(func(): visible = true)
		if manager.has_signal("level_started"):
			manager.level_started.connect(func(): visible = false)
			
func _on_button_pressed() -> void:
	next_requested.emit()
