@tool
extends Rule
class_name SirotageSucessRule


func check_validity(_dice_values:Array, players:Array=[], current_player:int=-1) -> bool:
	if players[current_player].sirotage_score > 0:
		return true
	return false
