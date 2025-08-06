@tool
extends Rule
class_name NeantRule


func ComputePoints(_dice_values:Array) -> int:
	return 0


func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	if dice_values.has(0):
		return false
	return true
