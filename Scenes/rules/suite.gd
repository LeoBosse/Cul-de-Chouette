@tool
extends Rule
class_name SuiteRule


func ComputePoints(_dice_values:Array) -> int:
	return -10


func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	if dice_values.has(0):
		return false
		
	dice_values.sort()
	if dice_values[2] - dice_values[1] == 1 and dice_values[1] - dice_values[0] == 1:
		return true
	
	return false
