@tool
extends Control
class_name Rule

@export var rule_name:String = "rule name"
@export_multiline var short_description:String = "Short description"
@export_multiline var short_score:String = "Short score description"

@export_multiline var full_description:String = "Full description"


@export var in_use:bool = true
@export var selectable_player:bool = false
@export var overrides:Array[String] = []

@onready var short_text = $RuleInPlay/ShortDescription
@onready var players_list_menu = $RuleInPlay/MenuButton

enum State{INGAME, SETUP}
@export var current_state:State:
	set(new_state):
		SetState(new_state)
		current_state = new_state

signal changed_rules()

func _ready() -> void:
	rule_name = rule_name.to_lower()
	
	if not self is NeantRule and not overrides.has("neant"):
		#print("not neant")
		overrides.append("neant")
	for i in overrides.size():
		overrides[i] = overrides[i].to_lower()
	
	players_list_menu.disabled = not selectable_player
	
	UpdateText(rule_name, short_description, short_score)
	
	$RuleInSetup.text = rule_name.capitalize()
	
func SetState(new_state:State):
	for c in get_children():
		c.visible = false
	
	if new_state == State.INGAME:
		$RuleInPlay.visible = true
		modulate = Color(1, 1, 1)
		size_flags_vertical = Control.SIZE_EXPAND_FILL
	elif new_state == State.SETUP:
		$RuleInSetup.visible = true
		size_flags_vertical = Control.SIZE_EXPAND_FILL
	
func UpdateText(new_rule_name:String, new_short_description:String, new_short_score:String):
	short_text.text = new_rule_name.to_upper() + " :\n"
	short_text.text += new_short_description + "\n"
	short_text.text += "Score : " + new_short_score

func ComputePoints(_dice_values:Array) -> int:
	return 0


func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	var validities = []
	
	for rule in get_children():
		if not rule is Rule:
			continue
			
		validities.append(rule.check_validity(dice_values))
	
	return len(validities) > 0 and validities.all(func check(x): x)

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
	changed_rules.emit()
	
func Clean():
	pass


func _on_rule_in_setup_toggled(toggled_on: bool) -> void:
	in_use = toggled_on
