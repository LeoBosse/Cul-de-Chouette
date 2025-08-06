@tool
extends Rule
class_name ChouetteRule


func ComputePoints(dice_values:Array) -> int:
	return GetChouetteValue(dice_values) ** 2

func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	if dice_values.has(0):
		return false
	if GetChouetteValue(dice_values) != 0:
		return true
	return false

func GetChouetteValue(dice_values:Array) -> int:
	for i in range(2):
		if dice_values.count(dice_values[i]) == 2:
			return dice_values[i]
			
		#for j in range(i+1, 3):
			#if dice_values[i] == dice_values[j]:
				#return dice_values[i]
	return 0
