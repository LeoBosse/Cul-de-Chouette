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
		return floori(current_player / nb_players)

@onready var rules_node:Node = %Rules

enum {PLAY, WIN, LOSE, DISQUALIFIED}
@onready var current_player_state:int = PLAY

var tabs_index:Dictionary = {"lancé": 0, "sirotage": 1, "stats": 2}

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

func Setup(new_player_names:Array, rules_dict:Dictionary):
	SetupRules(rules_dict)
	SetupPlayers(new_player_names)
	%Stats.Setup(player_names)
	prints("contre sirop", %Rules.get_node_or_null("ContreSirop"), null, %Rules.get_node_or_null("ContreSirop") != null)
	%Sirotage.Setup(player_names, %Rules.get_node_or_null("ContreSirop") != null)

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

func SetupRules(rules_dict:Dictionary):
	for r in %Rules.get_children():
		if r.rule_name.to_lower() in rules_dict:
			r.in_use = rules_dict[r.rule_name.to_lower()]
		
		prints("Rules setup: ", r.rule_name, r.in_use)
		#if not r.in_use:
			#r.queue_free()
	
	if not rules_dict["sirotage"]:
		%Sirotage.disabled = true
		$TabContainer.set_tab_hidden(tabs_index["sirotage"], true)
		%Rules/Sirotage.in_use = false
		%Rules/SirotageSuccess.in_use = false
		%Rules/SirotageFail.in_use = false
		%Rules/ContreSirop.in_use = false

func _on_rule_player_changed() -> void:
	UpdateRoll()

func _on_dice_roll_pressed(dice:Node, roll_value:int) -> void:
	"""Called when you click on a dice. 
	dice:[Node] """
	
	prints("DICE ROLL PRESSED", dice, roll_value)
	
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
	
	#SetupSirotageRules(%Sirotage.successfull, %Sirotage.contre_sirop_player)
	roll_scores = ComputePoints(valid_rules)
	UpdateRollScoreLabel()
	
	print(dice_values, " ", valid_rules, " ", roll_scores)

func ValidateDices():
	
	if dice_values.has(0):
		return 
	
	for i in range(nb_players):
		players[i].score += roll_scores[i]
	
	PassTurn()
	SetDicesAccess(true)

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
		
		
	roll_scores.fill(0)
	UpdateRollScoreLabel()
	
	%Sirotage.Clean()
	for i in range(nb_players):
		players[i].sirotage_score = 0
	
	for rule in rules_node.get_children():
		rule.Clean()
		rule.visible = false
	
	for roll in %DiceRolls.get_children():
		roll.reset()
	dice_values.fill(0)
	
	current_player += 1
	UpdateCurrentPlayerLabel()
	
	UpdateRoll(true)

func UpdateCurrentPlayerLabel():
	%CurrentPlayerLabel.text = "Au tour de : " + player_names[current_player]
	
func UpdateRollScoreLabel():
	%RollScoreLabel.text = ""
	var unchanged_score_string:String = "%s :\t%d\t"
	var greater_score_string:String = "\t +%d\t\t (%d)\t"
	var lower_score_string:String = "\t %d\t\t (%d)\t"
	
	for i in range(nb_players):
		%RollScoreLabel.text += unchanged_score_string % [player_names[i], player_scores[i]]
		if roll_scores[i] > 0:
			%RollScoreLabel.text += greater_score_string % [roll_scores[i], player_scores[i] + roll_scores[i]]
		elif roll_scores[i] < 0:
			%RollScoreLabel.text += lower_score_string % [roll_scores[i], player_scores[i] + roll_scores[i]]
		
		if players[i].has_civet:
			%RollScoreLabel.text += " \tC"
		%RollScoreLabel.text += "\n"
	
func GetValidRules() -> Array:
	var valid_rules:Array[Rule] = []
		
	for r in rules_node.get_children():
		if r.check_validity(dice_values.duplicate(), players, current_player) and r.in_use:
			valid_rules.append(r)
	
	#prints("sirotage: ", %Sirotage.successfull, %Sirotage.already_rolled)
	prints("valid rules: ", valid_rules)
	
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

func SetDicesAccess(enabled:bool):
	for r in %DiceRolls.get_children():
		r.SetAccess(enabled)
	

func ComputePoints(valid_rules) -> Array[int]:
	var scores:Array[int] = []
	scores.resize(nb_players)
	scores.fill(0)
		
	for r in valid_rules:
		print(r)
		var rule_scores:Array[int] = r.GetPlayerScores(dice_values)
		for i in range(nb_players):
			scores[i] += rule_scores[i]
	
	for i in range(nb_players):
		scores[i] += %Sirotage.scores[i]
	
	return scores


func _on_validate_roll_button_pressed() -> void:
	ValidateDices()


func _on_stats_button_pressed() -> void:
	%GameStats.visible = true


func _on_sirotage_trying_sirotage() -> void:
	%Sirotage.Update(current_player, dice_values)
	

func _on_sirotage_validating_sirotage(successfull:bool, sirotage_scores: Array, dices: Array, contre_sirop_player: int) -> void:
	
	## Update scores with sirotage results
	for i in range(nb_players):
		players[i].sirotage_score += sirotage_scores[i]
	
	## Update dices with sirotage results and set them to non editable.
	for i in range(3):
		%DiceRolls.get_child(i).SelectDice(dices[i])
	SetDicesAccess(false)
	
	## Setup the sirotage rule. Change its text based on the success of the bet.
	%Rules/Sirotage.Setup(true, successfull)
	
	### Setup the Contre-Sirop rule
	%Rules/ContreSirop.Setup(successfull, contre_sirop_player)
	
	## Give a Civet to the current player if it applies
	if not successfull and dices.count(6) == 2:
		%Rules/CivetSirote.ongoing_sirotage = true
		players[current_player].has_civet = true
	
	## Return to the main game tab
	$TabContainer.current_tab = 0
	
	## Update roll to view the rules applying with the sirotage roll
	UpdateRoll()


func _on_civet_lose_civet() -> void:
	players[current_player].has_civet = false
