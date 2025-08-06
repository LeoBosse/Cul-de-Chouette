@tool
extends Rule
class_name ChouetteVeluteRule


func ComputePoints(dice_values:Array) -> int:
	return $VeluteRule.ComputePoints(dice_values)


func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	if dice_values.has(0):
		return false
	
	var validity = true
	
	for rule in get_children():
		if not rule is Rule:
			continue
			
		validity = validity and rule.check_validity(dice_values)
	
	return validity
