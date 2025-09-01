@tool
extends Control
class_name Game

var player_scene:PackedScene = load("res://Scenes/player.tscn")
var players:Array[Player]
var nb_players:int
var use_teams:bool = false
var nb_teams:int = 0
var team_names:Array = []
var team_scores:Array = []
var team_roll_scores:Array = []
signal game_is_won(Stats)

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

@onready var rules_node:Node = %RulesList

enum {PLAY, WIN, LOSE, DISQUALIFIED}
@onready var current_player_state:int = PLAY

var tabs_index:Dictionary = {"lancé": 0, "sirotage": 1, "stats": 2}

func _ready() -> void:
	
	#UpdateCurrentPlayerLabel()
	
	## Connect every dices used for choosing the 3 dice rolls to a function that stores the choice
	var i:int = 0
	for roll in %DiceRolls.get_children():
		roll.button_group.pressed.connect(_on_dice_roll_pressed.bind(i))
		i += 1
	
func Setup(new_player_names:Array, rules_dict:Array, teams:int):
	SetupPlayers(new_player_names, teams)
	SetupRules(rules_dict)
	%Stats.Setup(player_names)
	#prints("contre sirop", %RulesList.get_node_or_null("ContreSirop"), null, %RulesList.get_node_or_null("ContreSirop") != null)
	%Sirotage.Setup(player_names, %RulesList.get_node_or_null("ContreSirop") != null)
	%Bévue.Setup(player_names)
	%Rules.Setup(rules_dict.map(func(r):return r.duplicate()))

func SetupPlayers(new_player_names:Array, teams:int) -> void:
	nb_players = len(new_player_names)
	use_teams = teams > 0
	
	if use_teams:
		nb_teams = teams
		team_scores = range(nb_teams)
		team_scores.fill(0)
		team_names = range(nb_teams)
		team_roll_scores.resize(nb_teams)
		team_roll_scores.fill(0)
	else:
		$"TabContainer/Lancé/HBoxContainer/TabContainer".set_tab_hidden(1, true)
		
		for i in range(nb_teams):
			team_names[i] = "Equipe " + str(i + 1)
	
	roll_scores.resize(nb_players)
	roll_scores.fill(0)
	
	players = []
	for i in range(len(new_player_names)):
		var new_player:Player = player_scene.instantiate()
		new_player.player_name = new_player_names[i]
		new_player.index = len(players)
		new_player.state = PLAY
		if use_teams:
			new_player.team = i % teams
			prints(teams, i % teams)
		new_player.state
		players.append(new_player)
	UpdateCurrentPlayerLabel()

func SetupRules(rules_list:Array):
	for r in %RulesList.get_children():
		r.queue_free()
	
	for r in rules_list:
		r.current_state = r.State.INGAME
		r.visible = false
		
		if r.rule_name.to_lower() == "civet":
			r.lose_civet.connect(_on_civet_lose_civet)
		
		%RulesList.add_child(r)
	
	for r in %RulesList.get_children():
		r.SetUpPlayerOptions(player_names)
		r.changed_rules.connect(_on_rule_changed)
		
	#%RulesList.print_tree_pretty()
	if not %RulesList/SirotageRule.in_use:
		#%RulesList/SirotageRule.disabled = true
		$TabContainer.set_tab_hidden(tabs_index["sirotage"], true)
		#%RulesList/SirotageRule.in_use = false
		#%RulesList/sirotageSuccess.in_use = false
		#%RulesList/sirotageFail.in_use = false
		%RulesList/ContreSirop.in_use = false

func _on_rule_changed() -> void:
	UpdateRoll()

func _on_dice_roll_pressed(dice:Node, roll_value:int) -> void:
	"""Called when you click on a dice. 
	dice:[Node] """
	
	if dice.button_pressed:
		dice_values[roll_value] = dice.value
	else:
		dice_values[roll_value] = 0
	UpdateRoll(true)
	

func UpdateRoll(reset_player:bool=false):
	var valid_rules:Array = GetValidRules()
	
	for rule in %RulesList.get_children():
		rule.visible = false
		if rule in valid_rules:
			rule.visible = true
			if reset_player:
				#print("reseting to current" + str(current_player))
				rule.SetPlayer(current_player)
	
	#SetupSirotageRules(%Sirotage.successfull, %Sirotage.contre_sirop_player)
	roll_scores = ComputePoints(valid_rules)
	team_roll_scores = ComputeTeamsPoints(roll_scores)
	UpdateRollScoreLabel()
	
	#print(dice_values, " ", valid_rules, " ", roll_scores)

func ValidateDices():
	
	if dice_values.has(0):
		return 
	
	SetScores(roll_scores)
	
	PassTurn()
	SetDicesAccess(true)

func SetScores(points_list:Array, update_stats:bool = true):
	SetPlayerScores(points_list)
	if use_teams:
		SetTeamScores(ComputeTeamsPoints(points_list))
	
	if update_stats:
		%Stats.RegisterNewState(players, current_player)

func SetTeamScores(points_list:Array):
	"""Add the given points to the teams scores."""
	for i in range(nb_teams):
		team_scores[i] += points_list[i]
		if i != players[current_player].team and team_scores[i] > 343:
			team_scores[i] = 332

func SetPlayerScores(points_list:Array):
	"""Add the given points to the player scores."""
	for i in range(nb_players):
		players[i].score += points_list[i]
		if i != current_player and players[i].score > 343:
			players[i].score = 332
		

func WinLoseCondition():
	if not use_teams:
		if player_scores[current_player] >= 343:
			return WIN
		elif player_scores[current_player] <= -343:
			return DISQUALIFIED
	else:
		if team_scores[players[current_player].team] >= 343:
			return WIN
		elif team_scores[players[current_player].team] <= -343:
			return DISQUALIFIED
	
	return PLAY

func NewRound() -> bool:
	return current_player == nb_players - 1
	
func PassTurn():
	
	current_player_state = WinLoseCondition()
	if current_player_state == WIN:
		#prints(players[current_player].player_name, "won!")
		prints(%Stats, %Stats.player_names)
		game_is_won.emit(%Stats.GetExport())
		
		
	roll_scores.fill(0)
	team_roll_scores.fill(0)
	UpdateRollScoreLabel()
	
	%Sirotage.Clean()
	for i in range(nb_players):
		players[i].sirotage_score = 0
	
	for rule in %RulesList.get_children():
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
	SetScoreLabelText(%PlayerRollScoreLabel, player_names, player_scores, roll_scores)
	if use_teams:
		SetScoreLabelText(%TeamRollScoreLabel, team_names, team_scores, team_roll_scores)
	
	

func SetScoreLabelText(label_node:RichTextLabel, entry_names:Array, current_scores:Array, roll_score:Array):
	label_node.text = ""
	var unchanged_score_string:String = "%s :\t%d\t"
	var greater_score_string:String = "\t +%d\t\t (%d)\t"
	var lower_score_string:String = "\t %d\t\t (%d)\t"
	
	for i in range(len(entry_names)):
		label_node.text += unchanged_score_string % [entry_names[i], current_scores[i]]
		if roll_score[i] > 0:
			label_node.text += greater_score_string % [roll_score[i], current_scores[i] + roll_score[i]]
		elif roll_score[i] < 0:
			label_node.text += lower_score_string % [roll_score[i], current_scores[i] + roll_score[i]]
		
		if players[i].has_civet:
			label_node.text += " \tC"
		label_node.text += "\n"
	

func GetValidRules() -> Array:
	var valid_rules:Array[Rule] = []
		
	for r in %RulesList.get_children():
		if r.check_validity(dice_values.duplicate(), players, current_player) and r.in_use:
			valid_rules.append(r)
	
	#prints("sirotage: ", %Sirotage.successfull, %Sirotage.already_rolled)
	#prints("valid rules: ", valid_rules)
	
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
	
	#print(valid_rules, " ", overridden_rules, " ", winning_rules)
	return winning_rules

func SetDicesAccess(enabled:bool):
	for r in %DiceRolls.get_children():
		r.SetAccess(enabled)
	
func ComputeTeamsPoints(player_score:Array) -> Array[int]:
	var scores:Array[int] = []
	scores.resize(nb_teams)
	scores.fill(0)
	
	if not use_teams:
		return scores
	
	print(player_score)
	for i in range(len(player_score)):
		prints(i, players[i].player_name, players[i].team, player_score[i])
		scores[players[i].team] += player_score[i]
		print(scores)
	
	return scores
	
func ComputePoints(valid_rules) -> Array[int]:
	var scores:Array[int] = []
	scores.resize(nb_players)
	scores.fill(0)
		
	for r in valid_rules:
		var rule_scores:Array[int] = r.GetPlayerScores(dice_values)
		for i in range(nb_players):
			scores[i] += rule_scores[i]
	
	for i in range(nb_players):
		scores[i] += %Sirotage.scores[i]
	
	return scores


func _on_validate_roll_button_pressed() -> void:
	ValidateDices()


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
	%RulesList/SirotageRule.Setup(true, successfull)
	
	### Setup the Contre-Sirop rule
	%RulesList/ContreSirop.Setup(successfull, contre_sirop_player)
	
	## Give a Civet to the current player if it applies
	if not successfull and dices.count(6) == 2:
		%RulesList/CivetSiroteRule.ongoing_sirotage = true
		players[current_player].has_civet = true
	
	## Return to the main game tab
	$TabContainer.current_tab = 0
	
	## Update roll to view the rules applying with the sirotage roll
	UpdateRoll()


func _on_civet_lose_civet() -> void:
	players[current_player].has_civet = false


func _on_bévue_bevue(player: int) -> void:
	var new_scores:Array = range(nb_players)
	new_scores.fill(0)
	new_scores[player] = -10
	SetScores(new_scores)
	#players[player].score -= 10
	#prints(players[player].score)
	_on_rule_changed()
	


func _on_stats_undoing_turn(point_correction:Array, old_player:int, civets:Array) -> void:
	#prints("undoing", current_player, old_player)
	SetScores(point_correction, false)
	current_player = old_player
	for i in nb_players:
		players[i].has_civet = civets[i]
	UpdateCurrentPlayerLabel()
	UpdateRollScoreLabel()
	
