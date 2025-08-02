extends Control
class_name SirotageRule

@onready var player_names:Array = []
@onready var nb_players:int
@onready var sirotage_player:int
@onready var chouette_value:int = 0
@onready var player_bets:Array = []

@onready var value_names:Array = ["Linotte", "Alouette", "Fauvette", "Mouette", 'Bergeronnette', "Chouette"]

@export_multiline var valid_text:String = "Vous tentez un sirotage !\nFaites une WIN_VALUE pour le gagner.\nLes autres joueurs peuvent tenter de parier sur le résultat :"
@export_multiline var invalid_text:String = "Vous n'avez pas de chouette. Sirotage impossible !"

signal trying_sirotage

func Update(current_player:int, dice_values:Array):
	chouette_value = CheckValidity(dice_values)
	if chouette_value <= 0:
		%Description.text = invalid_text
		return
		
	%Description.text = valid_text.replace("WIN_VALUE", value_names[chouette_value - 1])
	
	sirotage_player = current_player
	prints("updating sirotage", current_player, nb_players)
	for i in range(nb_players):
		if i != sirotage_player:
			prints(i, sirotage_player, "can bet")
			%PlayerBetList.get_child(i+1).visible = true
		else:
			prints(i, sirotage_player, "cant bet")
			%PlayerBetList.get_child(i+1).visible = false

func Setup(player_list:Array):
	
	nb_players = len(player_list)
	player_names = []
	player_bets = []
	
	for i in range(nb_players):
		player_names.append(player_list[i])
		player_bets.append(0)
		var new_player_bet_node = %ExamplePlayerBet.duplicate(14)
		new_player_bet_node.visible = true
		new_player_bet_node.get_child(0).text = player_list[i]
		new_player_bet_node.get_child(1).item_selected.connect(_on_player_bet_selected.bind(i))
		%PlayerBetList.add_child(new_player_bet_node)

func CheckValidity(dice_values:Array) -> int:
	if CulDeChouetteRule.new().check_validity(dice_values):
		return -1
	
	var value:int = ChouetteRule.new().GetChouetteValue(dice_values)
	if value > 0:
		return value
		
	return 0
	

func ComputeScores(result:int):
	var scores:Array
	scores.resize(nb_players)
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
			
func _on_player_bet_selected(index:int, player_id:int):
	player_bets[player_id] = index

func _on_validate_button_pressed() -> void:
	var string_result:String = $VBoxContainer/ResultLineEdit.text
	if not string_result.is_valid_int():
		return 
	var result:int = int(string_result)
	if result < 1 or result > 6:
		return
	
	if result == chouette_value:
		print("sirotage gagné !")
	else:
		print("sirotage perdu !")
		

func _on_visibility_changed() -> void:
	if visible == false:
		return
		
	trying_sirotage.emit()
