@tool
extends Control
class_name GrelottineTab


var disabled:bool = false
var player_names:Array = []
var player_points:Array = []
var nb_players:int = -1
var challengee:int = -1
var challenger:int = -1

var player_bets:Array = []
var dice_values:Array[int] = [0, 0, 0]

var challenge_point:int = 0
var successfull:bool = false

var final_scores:Array = []

var ongoing_challenge:bool = false

var possible_combinaisons:Array = ["Chouette", "Velute", "Chouette Velute", "Cul de Chouette"]
var combinaisons:Array = [ChouetteRule, VeluteRule, ChouetteVeluteRule, CulDeChouetteRule]
var combinaison_points_factor = [33., 25., 8., 16.]
var choosen_combinaison:int = -1


signal grellotine_challenge
signal validating_grelottine(challengee, challenger, dice_values)
	
func Update(player_list:Array, current_player:int):
	
	challengee = current_player
	
	SetupInterface(CheckValidity(player_list, challengee))
	
	for i in range(nb_players):
		%DefiantPlayerOptionButton.set_item_disabled(i+1, not CheckValidChallenger(player_list, i))
		%PlayerBetList.get_child(i+1).visible = i != current_player
		player_points[i] = player_list[i].score

func Setup(player_list:Array):
	nb_players = len(player_list)
	player_names = []
	player_points = []
	player_bets = []
	final_scores = []
	
	for c in possible_combinaisons:
		$VBoxContainer/CombinaisonOptionButton.add_item(c)
	
	for i in range(nb_players):
		player_names.append(player_list[i])
		player_points.append(0)
		player_bets.append(0)
		final_scores.append(0)
		%DefiantPlayerOptionButton.add_item(player_names[i])
		var new_player_bet_node = %ExamplePlayerBet.duplicate(14)
		new_player_bet_node.visible = true
		new_player_bet_node.get_child(0).text = player_list[i]
		new_player_bet_node.get_child(1).item_selected.connect(_on_player_bet_selected.bind(i))
		%PlayerBetList.add_child(new_player_bet_node)

	for i in range(3):
		%DiceRollsContainer.get_child(i).button_group.pressed.connect(_on_dice_roll_pressed.bind(i))


func CheckValidChallenger(players, chalenger):
	if not players[chalenger].has_grelottine:
		return false
	if players[chalenger].score < 30:
		return false
	if chalenger == challengee:
		return false
		
	return true

func CheckValidity(players, chalengee, _chalenger=null) -> bool:
	
	#if not players[chalengee].has_grelottine:
		#return false
	if players[chalengee].score < 30:
		print("GRELOTTINE invalid : challengee score < 30")
		return false
	
	if not range(nb_players).any(func(x):return CheckValidChallenger(players, x)):
		print("GRELOTTINE invalid : no challengers")
		return false
	
	return true

func SetupInterface(valid:bool):
	
	%Description.visible = valid
	$VBoxContainer/HBoxContainer2.visible = valid
	$VBoxContainer/Description2.visible = valid
	$VBoxContainer/CombinaisonOptionButton.visible = valid
	%MiseLabel.visible = valid
	
	%PlayerBetList.visible = valid
	%DiceRollsContainer.visible = valid
	$VBoxContainer/ValidateButton.visible = valid
	
	%ErrorLabel.visible = not valid
	

func Clean():
	player_names = []
	player_points.fill(0)
	challengee = -1
	challenger = -1
	player_bets.fill(0)
	dice_values = [0, 0, 0]
	challenge_point = 0
	successfull = false
	final_scores.fill(0)
	choosen_combinaison = -1
	%MiseLabel.text = "Mise :"
	%CombinaisonOptionButton.select(0)
	%DefiantPlayerOptionButton.select(0)
	ongoing_challenge = false
	for i in range(nb_players):
		%PlayerBetList.get_child(i+1).get_node("OptionButton").selected = 0
	
	for d in %DiceRollsContainer.get_children():
		d.reset()

func ComputePoints():
	var scores:Array = []
	scores.resize(nb_players)
	scores.fill(0)
	
	## Set other players bet scores
	for i in range(nb_players):
		if not player_bets[i] is bool:
			continue
			
		if successfull == player_bets[i]:
			scores[i] += 25
		else:
			scores[i] -= 5
	
	## Challenger and challengee gain/lose the challenge points based on its success
	scores[challengee] += int(challenge_point * pow(-1, int(not successfull)))
	scores[challenger] += int(challenge_point * pow(-1, int(successfull)))
	
	return scores
	
func _on_dice_roll_pressed(dice:Node, roll_id:int):
	if dice.button_pressed:
		dice_values[roll_id] = dice.value
	else:
		dice_values[roll_id] = 0


func _on_player_bet_selected(index:int, player_id:int):
	player_bets[player_id] = index
	if index == 0:
		player_bets[player_id] = null
	elif index == 1:
		player_bets[player_id] = true
	elif index == 2:
		player_bets[player_id] = false


func _on_defiant_player_option_button_item_selected(index: int) -> void:
	if challenger != -1:
		%PlayerBetList.get_child(challenger + 1).visible = true
	%PlayerBetList.get_child(index).visible = false
	
	challenger = index - 1
	challenge_point = GetChallengeScore(challengee, challenger, choosen_combinaison)


func GetChallengeScore(defendant, attacker, comb_id):
	if defendant == -1 or attacker == -1 or comb_id == -1:
		prints("invalid challenge", defendant, attacker, comb_id)
		return 0
	
	var s:int = int(min(player_points[defendant], player_points[attacker]) * combinaison_points_factor[comb_id] / 100.)
	prints("New challenge score: ", s)
	%MiseLabel.text = "Mise : " + str(s)
	
	return s

func _on_visibility_changed() -> void:
	grellotine_challenge.emit()

func _on_combinaison_option_button_item_selected(index: int) -> void:
	choosen_combinaison = index - 1
	challenge_point = GetChallengeScore(challengee, challenger, choosen_combinaison)

func _on_validate_button_pressed() -> void:
	if choosen_combinaison == -1:
		print("no choosen combinaison")
		return
	if 0 in dice_values:
		print("not all dices selected")
		return
	
	ongoing_challenge = true
	
	successfull = combinaisons[choosen_combinaison].new().check_validity(dice_values) ## Check if challenge is a success or not
	
	final_scores = ComputePoints()
	
	prints("valid grelottine: ", successfull, final_scores)
	validating_grelottine.emit(challengee, challenger, dice_values)
	
