@tool
extends Rule
class_name GrelottineRule


var ongoing_challenge:bool = false
var success_description:String = "Défi Grelottine réussi !\n Points mis en jeu : POINTS\n"
var fail_description:String = "Défi Grelottine perdu !\n Points mis en jeu : POINTS\n"
var success_score:String = "Les points du défi + les points de la combinaison."


func UpdateDescription(success:bool, mise:int):
	if success:
		UpdateText(rule_name, success_description.replace("POINTS", str(mise)), success_score)
	elif not success:
		UpdateText(rule_name, fail_description.replace("POINTS", str(mise)), success_score)

func ComputePoints(_dice_values:Array) -> int:
	return 0


func check_validity(dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	if ongoing_challenge:
		return true
	if dice_values.has(0):
		return false

	return true

func Clean():
	UpdateText(rule_name, short_description, short_score)
