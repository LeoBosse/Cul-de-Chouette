extends Rule
class_name ContreSiropRule

var player_id:int = -1

func check_validity(_dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	return player_id >= 0
	

func Setup(successfull:bool, contre_sirop_player:int):
	## Setup the Contre-Sirop rule
	if not successfull and contre_sirop_player >= 0:
		player_id = contre_sirop_player
		SetPlayer(contre_sirop_player)


func Clean():
	player_id = -1
