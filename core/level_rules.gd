class_name LevelRules
extends Resource

@export var is_closed_loop: bool = true

func get_next_index(current_index: int, total_points: int) -> int:
	if total_points == 0:
		return 0
	return (current_index + 1) % total_points
	
func check_win_condition(current_index: int, total_points: int) -> bool:
	if is_closed_loop:
		return current_index == 0
	else:
		return current_index == total_points - 1
