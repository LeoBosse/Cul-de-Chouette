@tool
extends Rule
class_name SoufletteRule

enum results {FIRST=50, SEC=40, THIRD=30, LOST=-30}

@onready var result = -1
@onready var challenged_player:int = -1

func GetPlayerScores(dice_values:Array[int]) -> Array[int]:
	"""Compute and return the points given to each players."""
	var scores:Array[int] = super(dice_values)
	
	scores.fill(0)
	
	if challenged_player == -1 or result == -1:
		return scores

	scores[GetPlayer()] -= ComputePoints(dice_values)
	scores[challenged_player] += ComputePoints(dice_values)
	
	return scores

func ComputePoints(_dice_values:Array) -> int:
	return result
		
		
func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	if dice_values.has(4) and dice_values.has(2) and dice_values.has(1):
		return true
	
	return false

func SetUpPlayerOptions(players_list:Array) -> void :
	"""Should be called to fill in the players in the dropdown menu"""
	players_list_menu.clear()
	%MenuButton2.clear()
	for p in players_list:
		players_list_menu.add_item(p)
		%MenuButton2.add_item(p)

func SetPlayer(player_id:int) -> void:
	"""Set the player concerned by the rule. Can be called to automatically set the current player."""
	players_list_menu.select(player_id)
	challenged_player = player_id
	%MenuButton2.select(player_id)
	
func _on_menu_button_item_selected(_index: int) -> void:
	changed_rules.emit()

func _on_result_item_selected(index: int) -> void:
	if index == 0:
		result = results.FIRST
	elif index == 1:
		result = results.SEC
	elif index == 2:
		result = results.THIRD
	elif index == 3:
		result = results.LOST
	changed_rules.emit()


func _on_challenged_player_item_selected(index: int) -> void:
	challenged_player = index
	changed_rules.emit()
