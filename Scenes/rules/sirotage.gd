extends Control
class_name SirotageTab

var disabled:bool = false
var player_names:Array = []
var nb_players:int
var sirotage_player:int
var chouette_value:int = 0
var player_bets:Array = []
var dice_values:Array = []
var scores:Array = []

var value_names:Array = ["Linotte", "Alouette", "Fauvette", "Mouette", 'Bergeronnette', "Chouette"]

var successfull:bool = false
var already_rolled:bool = false

var contre_sirop_player:int

@export_multiline var valid_text:String = "Vous tentez un sirotage !\nFaites une WIN_VALUE pour le gagner.\nLes autres joueurs peuvent tenter de parier sur le résultat :"
@export_multiline var invalid_text:String = "Vous n'avez pas de chouette. Sirotage impossible !"

signal trying_sirotage
signal validating_sirotage(succesfull:bool, sirotage_scores:Array, dice_values:Array, contre_sirop:int)

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
			%ContreSiropWinnerButton.set_item_disabled(i + 1, false)
		else:
			#prints(i, sirotage_player, "cant bet")
			%PlayerBetList.get_child(i+1).visible = false
			%ContreSiropWinnerButton.set_item_disabled(i + 1, true)


func Setup(player_list:Array, contre_sirop:bool):
	
	%ContreSiropWinnerButton.visible = contre_sirop
	
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
		%ContreSiropWinnerButton.add_item(player_names[-1])
		
		
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
	for i in range(nb_players):
		if i == sirotage_player:
			if chouette_value == result:
				scores[i] += 0 #CulDeChouetteRule.new().ComputePoints([chouette_value, chouette_value, chouette_value])
			else:
				scores[i] -= 2 * ChouetteRule.new().ComputePoints([chouette_value, chouette_value, result])
		else:
			if player_bets[i] != 0:
				scores[i] -= 5
			if player_bets[i] == result:
				scores[i] += 25

	if %ContreSiropWinnerButton.selected > 0 and chouette_value != result:
		scores[%ContreSiropWinnerButton.selected - 1] += int(.2 * CulDeChouetteRule.new().ComputePoints([chouette_value, chouette_value, chouette_value]))
		
	return scores
			
func _on_player_bet_selected(index:int, player_id:int):
	player_bets[player_id] = index

func _on_validate_button_pressed() -> void:
	var string_result:String = $VBoxContainer/ResultLineEdit.text
	if not string_result.is_valid_int():
		%ErrorLabel.visible = true
		return 
	var result:int = int(string_result)
	if result < 1 or result > 6:
		%ErrorLabel.visible = true
		return
	
	%ErrorLabel.visible = false
	
	for i in range(3):
		if dice_values[i] != chouette_value:
			dice_values[i] = result
	
	scores = ComputeScores(result)
	
	contre_sirop_player = %ContreSiropWinnerButton.selected - 1
	
	prints("VALIDATE SIROTAGE, scores:", scores)
	successfull = result == chouette_value
	already_rolled = true
	SetInterfaceResponsive(false)
	
	validating_sirotage.emit(successfull, scores, dice_values, contre_sirop_player)
	

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
	$VBoxContainer/HBoxContainer.visible = valid
	
	if not valid:
		%Description.text = invalid_text
	else:
		%Description.text = valid_text.replace("WIN_VALUE", value_names[chouette_value - 1])
	
	


func Clean():
	scores.fill(0)
	player_bets.fill(0)
	dice_values.fill(0)
	chouette_value = 0
	successfull = false
	contre_sirop_player = -1
	$VBoxContainer/ResultLineEdit.text = ""
	already_rolled = false
	SetInterfaceResponsive(true)
	%ContreSiropWinnerButton.select(0)
	%ErrorLabel.visible = false
	for i in range(nb_players):
		%PlayerBetList.get_child(i+1).get_node("OptionButton").selected = 0
