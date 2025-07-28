@tool
extends Rule
class_name SoufletteRule


func ComputePoints(_dice_values:Array) -> int:
	return 0


func check_validity(dice_values:Array) -> bool:
	
	if dice_values.has(4) and dice_values.has(2) and dice_values.has(1):
		return true
	
	return false
