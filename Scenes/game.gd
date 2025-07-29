@tool
extends Control
class_name Game

@onready var dice_values:Array[int] = [0, 0, 0]

@export var players:Array = ["Alice", "Bob", "Charlie", "Denise"]:
	set(value):
		players = value
		nb_players = len(players)
@onready var nb_players:int = len(players)

@onready var roll_scores:Array
@onready var player_scores:Array

@onready var current_player:int = 0:
	get():
		return current_player % nb_players

@onready var rules_node:Node = $ScrollContainer/Rules


func _ready() -> void:
	roll_scores.resize(nb_players)
	roll_scores.fill(0)
	player_scores.resize(nb_players)
	player_scores.fill(0)
	
	$CurrentPlayerLabel.text = players[0]
	
	## Connect every dices used for choosing the 3 dice rolls to a function that stores the choice
	var i:int = 0
	for roll in $DiceRolls.get_children():
		roll.button_group.pressed.connect(_on_dice_roll_pressed.bind(i))
		i += 1
	
	for r in rules_node.get_children():
		r.SetUpPlayerOptions(players)
		r.select_player.connect(_on_rule_player_changed)

func _on_rule_player_changed() -> void:
	UpdateRoll()

func _on_dice_roll_pressed(dice, roll_value) -> void:
	if dice.button_pressed:
		dice_values[roll_value] = dice.value
	else:
		dice_values[roll_value] = 0
	UpdateRoll(true)
	

func UpdateRoll(reset_player:bool=false):
	var valid_rules:Array = GetValidRules()
	
	for rule in rules_node.get_children():
		rule.visible = false
		if rule in valid_rules:
			rule.visible = true
			if reset_player:
				print("reseting to current" + str(current_player))
				rule.SetPlayer(current_player)
	
	roll_scores = ComputePoints(valid_rules)
	UpdateRollScoreLabel()
	
	print(dice_values, " ", valid_rules, " ", roll_scores)

func ValidateDices():
	for i in range(nb_players):
		player_scores[i] += roll_scores[i]
	
	$PlayersScoreLabel.text = str(player_scores)
	
	PassTurn()

func PassTurn():
	current_player += 1
	$CurrentPlayerLabel.text = players[current_player]
	
	roll_scores.fill(0)
	UpdateRollScoreLabel()
	
	for rule in rules_node.get_children():
		rule.visible = false
	
	for roll in $DiceRolls.get_children():
		roll.reset()
	dice_values.fill(0)

func UpdateRollScoreLabel():
	$RollScoreLabel.text = "Roll score :\n" + str(roll_scores)
	
func GetValidRules() -> Array:
	var valid_rules:Array[Rule] = []
	if dice_values.has(0):
		return valid_rules
		
	for r in rules_node.get_children():
		if r.check_validity(dice_values.duplicate()):
			valid_rules.append(r)
	
	return RulesOverride(valid_rules)


func RulesOverride(valid_rules:Array) -> Array:
	var overridden_rules:Array = []
	for rule in valid_rules:
		for overruled in rule.overrides:
			if not overridden_rules.has(overruled):
				overridden_rules.append(overruled)
	
	var winning_rules:Array = []
	for r in valid_rules:
		if not overridden_rules.has(r.rule_name):
			winning_rules.append(r)
	
	print(valid_rules, " ", overridden_rules, " ", winning_rules)
	return winning_rules


func ComputePoints(valid_rules) -> Array[int]:
	var scores:Array[int] = []
	for i in range(nb_players):
		scores.append(0)
		
	for r in valid_rules:
		print(r)
		var rule_scores:Array[int] = r.GetPlayerScores(dice_values, current_player)
		for i in range(nb_players):
			scores[i] += rule_scores[i]
			
	return scores


func _on_validate_roll_button_pressed() -> void:
	ValidateDices()
