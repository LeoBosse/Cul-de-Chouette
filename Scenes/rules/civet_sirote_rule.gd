@tool
extends Rule
class_name CivetSiroteRule

var ongoing_sirotage:bool = false

func check_validity(_dice_values:Array, players:Array=[], current_player:int=-1) -> bool:
	if players[current_player].has_civet and ongoing_sirotage:
		return true
	return false


func Clean():
	ongoing_sirotage = false
