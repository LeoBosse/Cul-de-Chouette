@tool
extends Rule
class_name VeluteRule

func sum(accum, number):
	return accum + number

func check_validity(dice_values:Array) -> bool:
	## Check if the sum of to dices egal the third one
	
	if dice_values.reduce(sum) - 2 * dice_values.max() == 0:
		return true
	
	return false

func ComputePoints(dice_values:Array) -> int:
	return 2 * dice_values.max() ** 2
