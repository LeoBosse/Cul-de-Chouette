@tool
extends Rule
class_name CivetRule

var bet_value:int = 0
var bet_combinaison:int = 0:
	get():
		return %CombinaisonsOptionButton.selected
		
var cominaisons:Array = [[ChouetteRule], [VeluteRule], [ChouetteVeluteRule], [SuiteRule], [CulDeChouetteRule], [CulDeChouetteRule, SirotageSucessRule]]

var ongoing_bet:bool = false
var success:bool = false

signal lose_civet()

func ComputePoints(_dice_values:Array) -> int:
	if not success:
		return  -bet_value
	return bet_value

func CheckSuccess(dice_values:Array, players:Array=[], current_player:int=-1):
	var validity:bool = true
	for r in cominaisons[%CombinaisonsOptionButton.selected]:
		validity = validity and r.new().check_validity(dice_values, players, current_player)
	return validity

func check_validity(dice_values:Array, players:Array=[], current_player:int=-1) -> bool:
	if current_player <= -1 or current_player >= len(players):
		return false
	
	if ongoing_bet:
		success = CheckSuccess(dice_values, players, current_player)
		%BetValueLine.editable = false
		%CombinaisonsOptionButton.disabled = true
		return true
	
	if players[current_player].has_civet and dice_values.count(0) == 3:
		return true
		
	return false

func _on_bet_value_line_text_changed(new_text: String) -> void:
	if not new_text.is_valid_int():
		%BetValueLine.text = ""
	var new_bet_value:int = int(new_text)
	
	new_bet_value = max(0, new_bet_value)
	new_bet_value = min(102, new_bet_value)
	
	bet_value = new_bet_value
	
	%BetValueLine.text = str(bet_value)
	%BetValueLine.caret_column = len(%BetValueLine.text)
	
	if bet_value > 0:
		ongoing_bet = true


func Clean():
	bet_value = 0
	if ongoing_bet:
		lose_civet.emit()
	ongoing_bet = false
	success = false
	%BetValueLine.editable = true
	%BetValueLine.text = ""
	%CombinaisonsOptionButton.disabled = false
	%CombinaisonsOptionButton.selected = 0
