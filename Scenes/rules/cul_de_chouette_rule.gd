@tool
extends Rule
class_name CulDeChouetteRule


func check_validity(dice_values:Array) -> bool:
	if dice_values[0] == dice_values[1] and dice_values[0] == dice_values[2]:
		return true
	
	return false


func ComputePoints(dice_values:Array) -> int:
	return 40 + 10 * dice_values[0]
