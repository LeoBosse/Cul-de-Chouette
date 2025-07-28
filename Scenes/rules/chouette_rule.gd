@tool
extends Rule
class_name ChouetteRule


func ComputePoints(dice_values:Array) -> int:
	return GetChouetteValue(dice_values) ** 2

func check_validity(dice_values:Array) -> bool:
	if GetChouetteValue(dice_values) != 0:
		return true
	return false

func GetChouetteValue(dice_values:Array) -> int:
	for i in range(2):
		for j in range(i+1, 3):
			if dice_values[i] == dice_values[j]:
				return dice_values[i]
	return 0
