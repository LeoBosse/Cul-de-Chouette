@tool
extends Rule
class_name ArtichetteRule


func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	return dice_values.count(3) == 2 and dice_values.count(4) == 1


func ComputePoints(_dice_values:Array) -> int:
	if $RuleInPlay/CheckButton.button_pressed:
		return 16
	return -16


func _on_check_button_toggled(_toggled_on: bool) -> void:
	changed_rules.emit()
