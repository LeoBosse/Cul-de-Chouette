@tool
extends Control
class_name Game

var player_scene:PackedScene = load("res://Scenes/player.tscn")
var players:Array[Player]
var nb_players:int

signal game_is_won(winner_name, winner_score)

@onready var dice_values:Array[int] = [0, 0, 0]

@onready var player_names:Array:
	get():
		var names:Array = players.map(func(element:Player) -> String: return element.player_name)
		return names

@onready var player_scores:Array:
	get():
		return players.map(func(element:Player): return element.score as int)
		
@onready var roll_scores:Array[int]

@onready var current_player:int = 0:
	get():
		return current_player % nb_players

@onready var current_round:int = 0:
	get():
		return int(current_player / nb_players) 

@onready var rules_node:Node = %Rules

enum {PLAY, WIN, LOSE, DISQUALIFIED}
@onready var current_player_state:int = PLAY

func _ready() -> void:
	if not nb_players:
		SetupPlayers(["Alice", "Bob", "Charlie", "Denise"])
	
	roll_scores.resize(nb_players)
	roll_scores.fill(0)
	
	#UpdateCurrentPlayerLabel()
	
	## Connect every dices used for choosing the 3 dice rolls to a function that stores the choice
	var i:int = 0
	for roll in %DiceRolls.get_children():
		roll.button_group.pressed.connect(_on_dice_roll_pressed.bind(i))
		i += 1
	
	for r in rules_node.get_children():
		r.SetUpPlayerOptions(player_names)
		r.select_player.connect(_on_rule_player_changed)

func SetupPlayers(new_player_names:Array) -> void:
	nb_players = len(new_player_names)
	players = []
	for n in new_player_names:
		var new_player:Player = player_scene.instantiate()
		new_player.player_name = n
		new_player.index = len(players)
		new_player.state = PLAY
		players.append(new_player)
	UpdateCurrentPlayerLabel()
	%Stats.Setup(player_names)
	%Sirotage.Setup(player_names)

func SetupRules(rules_dict:Dictionary):
	for r in %Rules.get_children():
		if r.rule_name.to_lower() in rules_dict:
			r.in_use = rules_dict[r.rule_name]
		
		if not r.in_use:
			r.queue_free()
			
		prints(r.rule_name, r.in_use)

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
		players[i].score += roll_scores[i]
	
	PassTurn()

func WinLoseCondition():
	if player_scores[current_player] >= 343:
		return WIN
	elif player_scores[current_player] <= -343:
		return DISQUALIFIED
	
	return PLAY

func NewRound() -> bool:
	return current_player == nb_players - 1
	
func PassTurn():
	
	%Stats.UpdateScore(NewRound(), player_scores)
	
	current_player_state = WinLoseCondition()
	if current_player_state == WIN:
		prints(players[current_player].player_name, "won!")
		game_is_won.emit(player_names[current_player], player_scores[current_player])
		
		
	current_player += 1
	UpdateCurrentPlayerLabel()
	
	roll_scores.fill(0)
	UpdateRollScoreLabel()
	
	for rule in rules_node.get_children():
		rule.visible = false
	
	for roll in %DiceRolls.get_children():
		roll.reset()
	dice_values.fill(0)

func UpdateCurrentPlayerLabel():
	%CurrentPlayerLabel.text = "Au tour de : " + player_names[current_player]
	
func UpdateRollScoreLabel():
	%RollScoreLabel.text = ""
	var unchanged_score_string:String = "%s :\t%d"
	var greater_score_string:String = "\t +%d\t\t (%d)"
	var lower_score_string:String = "\t %d\t\t (%d)"
	
	for i in range(nb_players):
		%RollScoreLabel.text += unchanged_score_string % [player_names[i], player_scores[i]]
		if roll_scores[i] > 0:
			%RollScoreLabel.text += greater_score_string % [roll_scores[i], player_scores[i] + roll_scores[i]]
		elif roll_scores[i] < 0:
			%RollScoreLabel.text += lower_score_string % [roll_scores[i], player_scores[i] + roll_scores[i]]
		%RollScoreLabel.text += "\n"
	
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
		var rule_scores:Array[int] = r.GetPlayerScores(dice_values)
		for i in range(nb_players):
			scores[i] += rule_scores[i]
			
	return scores


func _on_validate_roll_button_pressed() -> void:
	ValidateDices()


func _on_stats_button_pressed() -> void:
	%GameStats.visible = true


func _on_sirotage_trying_sirotage() -> void:
	%Sirotage.Update(current_player, dice_values)
	
