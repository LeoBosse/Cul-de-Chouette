extends Control
class_name SirotageRule

var player_names:Array = []
var nb_players:int
var sirotage_player:int
var chouette_value:int = 0
var player_bets:Array = []
var dice_values:Array = []
var scores:Array = []

var value_names:Array = ["Linotte", "Alouette", "Fauvette", "Mouette", 'Bergeronnette', "Chouette"]

var already_rolled = false

@export_multiline var valid_text:String = "Vous tentez un sirotage !\nFaites une WIN_VALUE pour le gagner.\nLes autres joueurs peuvent tenter de parier sur le résultat :"
@export_multiline var invalid_text:String = "Vous n'avez pas de chouette. Sirotage impossible !"

signal trying_sirotage
signal validating_sirotage(sirotage_scores:Array, dice_values:Array)

func Update(current_player:int, dices:Array):
	dice_values = dices
	chouette_value = CheckValidity(dices)
	SetupInterface(chouette_value > 0)
	
	
	sirotage_player = current_player
	#prints("updating sirotage", current_player, nb_players)
	for i in range(nb_players):
		if i != sirotage_player:
			#prints(i, sirotage_player, "can bet")
			%PlayerBetList.get_child(i+1).visible = true
		else:
			#prints(i, sirotage_player, "cant bet")
			%PlayerBetList.get_child(i+1).visible = false


func Setup(player_list:Array):
	
	nb_players = len(player_list)
	player_names = []
	player_bets = []
	
	for i in range(nb_players):
		player_names.append(player_list[i])
		player_bets.append(0)
		scores.append(0)
		var new_player_bet_node = %ExamplePlayerBet.duplicate(14)
		new_player_bet_node.visible = true
		new_player_bet_node.get_child(0).text = player_list[i]
		new_player_bet_node.get_child(1).item_selected.connect(_on_player_bet_selected.bind(i))
		%PlayerBetList.add_child(new_player_bet_node)

func CheckValidity(dices:Array) -> int:
	"""Return an int. 
			-1 : cul de chouette -> can't bet
			0 : no 2 dices identical
			> 0 : the value of the chouette."""
	if CulDeChouetteRule.new().check_validity(dices):
		return -1
	
	var value:int = ChouetteRule.new().GetChouetteValue(dices)
	if value > 0:
		return value
		
	return 0
	

func ComputeScores(result:int) -> Array:
	scores.fill(0)
	var player_point:int = 0
	for i in range(nb_players):
		if i == sirotage_player:
			player_point = CulDeChouetteRule.new().ComputePoints([chouette_value, chouette_value, chouette_value])
			if chouette_value == result:
				scores[i] += player_point
			else:
				scores[i] -= player_point
		else:
			if player_bets[i] != 0:
				scores[i] -= 5
			if player_bets[i] == result:
				scores[i] += 25
	return scores
			
func _on_player_bet_selected(index:int, player_id:int):
	player_bets[player_id] = index

func _on_validate_button_pressed() -> void:
	var string_result:String = $VBoxContainer/ResultLineEdit.text
	if not string_result.is_valid_int():
		return 
	var result:int = int(string_result)
	if result < 1 or result > 6:
		return
	
	for i in range(3):
		if dice_values[i] != chouette_value:
			dice_values[i] = result
	
	scores = ComputeScores(result)
	
	prints("VALIDATE SIROTAGE, scores:", scores)
	validating_sirotage.emit(scores, dice_values)
	already_rolled = true
	SetInterfaceResponsive(false)
	

func SetInterfaceResponsive(enabled:bool):
	$VBoxContainer/ValidateButton.disabled = not enabled
	$VBoxContainer/ResultLineEdit.editable = enabled
	for i in range(nb_players):
		%PlayerBetList.get_child(i+1).get_node("OptionButton").disabled = not enabled
	
	
	
func _on_visibility_changed() -> void:
	if visible == false:
		return
		
	trying_sirotage.emit()


func SetupInterface(valid:bool):
	%Description.visible = true
	%PlayerBetList.visible = valid
	$VBoxContainer/ResultLineEdit.visible = valid
	$VBoxContainer/ValidateButton.visible = valid
	
	if not valid:
		%Description.text = invalid_text
	else:
		%Description.text = valid_text.replace("WIN_VALUE", value_names[chouette_value - 1])
	
	


func Clean():
	scores.fill(0)
	player_bets.fill(0)
	dice_values.fill(0)
	chouette_value = 0
	$VBoxContainer/ResultLineEdit.text = ""
	already_rolled = false
	SetInterfaceResponsive(true)
	for i in range(nb_players):
		%PlayerBetList.get_child(i+1).get_node("OptionButton").selected = 0
