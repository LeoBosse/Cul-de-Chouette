@tool
extends HBoxContainer
class_name Rule

@export var rule_name:String = "rule name"
@export_multiline var short_description:String = "Short description"
@export_multiline var short_score:String = "Short score description"

@export_multiline var full_description:String = "Full description"


@export var in_use:bool = true
@export var selectable_player:bool = false
@export var overrides:Array[String] = []

@onready var short_text = $ShortDescription
@onready var players_list_menu = $MenuButton

signal select_player()

func _ready() -> void:
	rule_name = rule_name.to_lower()
	
	if not self is NeantRule and not overrides.has("neant"):
		#print("not neant")
		overrides.append("neant")
	for i in overrides.size():
		overrides[i] = overrides[i].to_lower()
	
	players_list_menu.disabled = not selectable_player
	
	short_text.text = rule_name.to_upper() + " :\n"
	short_text.text += short_description + "\n"
	short_text.text += "Score : " + short_score

func ComputePoints(_dice_values:Array) -> int:
	return 0


func check_validity(dice_values:Array) -> bool:
	var validities = []
	
	for rule in get_children():
		if not rule is Rule:
			continue
			
		validities.append(rule.check_validity(dice_values))
	
	var valid:bool = len(validities) > 0 and validities.all(func check(x): x)
	
	return valid

func GetPlayerScores(dice_values:Array[int]) -> Array[int]:
	"""Compute and return the points given to each players."""
	var scores:Array[int] = []
	scores.resize(players_list_menu.item_count)
	scores.fill(0)

	scores[GetPlayer()] += ComputePoints(dice_values)
	return scores
	
func SetUpPlayerOptions(players_list:Array) -> void :
	"""Should be called to fill in the players in the dropdown menu"""
	players_list_menu.clear()
	for p in players_list:
		players_list_menu.add_item(p)

func SetPlayer(player_id:int) -> void:
	"""Set the player concerned by the rule. Can be called to automatically set the current player."""
	players_list_menu.select(player_id)

func GetPlayer() -> int:
	"""Get the player selected by the dropdown menu."""
	return players_list_menu.selected


func _on_menu_button_item_selected(_index: int) -> void:
	select_player.emit()
