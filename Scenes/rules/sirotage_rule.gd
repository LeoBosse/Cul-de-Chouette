@tool
extends Rule
class_name SirotageRule

var ongoing_sirotage:bool = false
var successfull:bool = false

var success_description:String = "Vous avez transformé votre Chouette en Cul de Chouette !"
var success_score_description:String = "Les points du Cul de Chouette."
var fail_description:String = "Vous n'avez pas transformé votre Chouette !"
var fail_score_description:String = "Vous perdez les points de la Chouette."


func Setup(ongoing:bool, is_success:bool):
	ongoing_sirotage = ongoing
	successfull = is_success
	if successfull:
		short_description = success_description
		short_score = success_score_description
	else:
		short_description = fail_description
		short_score = fail_score_description
	UpdateText(rule_name, short_description, short_score)
	
func check_validity(_dice_values:Array, _players:Array=[], _current_player:int=-1) -> bool:
	if successfull:
		return true
	elif not successfull and ongoing_sirotage:
		return true
		
		#if %Rules/ContreSirop.in_use and %Sirotage.contre_sirop_player >= 0:
			#valid_rules.append(%Rules/ContreSirop)
		#if players[current_player].has_civet:
			#valid_rules.append(%Rules/CivetSirote)
	
	return false

func Clean():
	ongoing_sirotage = false
	successfull = false
