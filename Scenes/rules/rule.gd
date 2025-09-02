@tool
extends Control
class_name Rule

@export var rule_name:String = "rule name"
@export_multiline var short_description:String = "Short description"
@export_multiline var short_score:String = "Short score description"

@export_multiline var full_description:String = "Full description"


@export var in_use:bool = true:
	set(new_value):
		$RuleInSetup.set_pressed_no_signal(new_value)
		in_use = new_value
		
@export var selectable_player:bool = false
@export var overrides:Array[String] = []
@export var prerequisites:Array[String] = []

@onready var short_text = $RuleInPlay/ShortDescription
@onready var players_list_menu = $RuleInPlay/MenuButton

enum State{INGAME, SETUP, DOCUMENTATION}
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
	
	for i in len(prerequisites):
		prerequisites[i] = prerequisites[i].to_lower()
	
	players_list_menu.disabled = not selectable_player
	
	UpdateText(rule_name, short_description, short_score)
	
	
	
	
func SetState(new_state:State):
	for c in get_children():
		c.visible = false
	#prints("set state ", rule_name, new_state)
	if new_state == State.INGAME:
		$RuleInPlay.visible = true
		modulate = Color(1, 1, 1)
		size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		#prints("rule min size: INGAME", rule_name, $RuleInPlay.get_combined_minimum_size().y, $RuleInPlay.get_minimum_size().y)
	
	elif new_state == State.SETUP:
		$RuleInSetup.visible = true
		size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	elif new_state == State.DOCUMENTATION:
		%RuleInDocumentation.visible = true
		%RuleInDocumentation/CheckButton.button_pressed = true
		
		size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		custom_minimum_size.y = %RuleInDocumentation.get_minimum_size().y
		
		#prints("rule min size: ", rule_name, get_combined_minimum_size().y, get_minimum_size().y)
		#prints("rule min size: RuleInDocumentation", rule_name, %RuleInDocumentation.get_combined_minimum_size().y, %RuleInDocumentation.get_minimum_size().y)
		#prints("rule min size: CheckButton", rule_name, %RuleInDocumentation/CheckButton.get_combined_minimum_size().y, %RuleInDocumentation/CheckButton.get_minimum_size().y)
		#print(%RuleInDocumentation/RichTextLabel.text)
		#prints("rule min size: RichTextLabel", rule_name, %RuleInDocumentation/RichTextLabel.get_combined_minimum_size().y, %RuleInDocumentation/RichTextLabel.get_minimum_size().y)
	
func UpdateText(new_rule_name:String, new_short_description:String, new_short_score:String):
	short_text.text = new_rule_name.to_upper() + " :\n"
	short_text.text += new_short_description + "\n"
	short_text.text += "Score : " + new_short_score
	
	$RuleInSetup.text = rule_name.capitalize()
	
	%RuleInDocumentation/CheckButton.text = rule_name.capitalize()
	#$RuleInDocumentation/RichTextLabel.clear()
	#$RuleInDocumentation/RichTextLabel.append_text(full_description)
	$RuleInDocumentation/RichTextLabel.text = full_description

func ComputePoints(_dice_values:Array) -> int:
	return 0


func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	var validities = []
	
	for rule in get_children():
		if not rule is Rule:
			continue
			
		validities.append(rule.check_validity(dice_values))
	
	var is_valid:bool = len(validities) > 0 and validities.all(func check(x): return x)
	
	return is_valid

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


func _on_documentation_check_button_toggled(toggled_on: bool) -> void:
	$RuleInDocumentation/RichTextLabel.visible = toggled_on
