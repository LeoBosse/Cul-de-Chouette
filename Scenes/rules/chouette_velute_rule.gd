@tool
extends Rule
class_name ChouetteVeluteRule


func ComputePoints(dice_values:Array) -> int:
	return $VeluteRule.ComputePoints(dice_values)


func check_validity(dice_values:Array) -> bool:
	var validity = true
	
	for rule in get_children():
		if not rule is Rule:
			continue
			
		validity = validity and rule.check_validity(dice_values)
	
	return validity
