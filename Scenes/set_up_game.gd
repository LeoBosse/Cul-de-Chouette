extends Control

@onready var nb_players:int = 1

signal launch_new_game(players:Array, rules:Dictionary)

func _ready() -> void:
	for r in %Rules.get_children():
		r.current_state = r.State.SETUP
		r.get_node("RuleInSetup").toggled.connect(_on_rule_toggled.bind(r.rule_name))
	
	_on_nb_players_text_changed($VBoxContainer/ScrollContainer/Options/NbPlayers/TextEdit.text)

func _on_rule_toggled(toggled_on:bool, rule_name:String):
	"""When toogling a rule ON/OFF, checks if there are any other rules dependent on it. In that case, switches all rules ON/OFF."""
	for r in %Rules.get_children():
		if r.rule_name == rule_name:
			continue
		if r.prerequisites.has(rule_name.to_lower()):
			r.in_use = toggled_on
		

func _on_nb_players_text_changed(new_text: String) -> void:
	"""When entering or changing the number of players for the new game, setup the options and make them visible."""
	if new_text.is_valid_int():
		nb_players = int(new_text)
		UpdateSettings()
		
		%PlayerNames.visible = true
		%Rules.visible = true
		%CreateGameButton.visible = true


func UpdateSettings():
	"""Duplicate the first node of player names to match number of players"""
	for i in range(1, %PlayerNames.get_child_count()):
		%PlayerNames.get_child(i).queue_free()
		
	for i in range(1, nb_players):
		#print("adding player")
		var new_player = %PlayerNames/"Joueur 1".duplicate(8)
		new_player.get_node("Label").text = "Joueur " + str(i+1)
		new_player.get_node("TextEdit").placeholder_text = "Joueur " + str(i+1)
		%PlayerNames.add_child(new_player)

func GetPlayers() -> Array:
	"""Return an array with the name of all players named in the options"""
	var players:Array = []
	var player_name:String = ""
	for j in %PlayerNames.get_children():
		player_name = j.get_child(1).text.to_lower()
		if player_name:
			players.append(player_name)
		else:
			players.append(j.get_child(1).placeholder_text.to_lower())
	return players


func GetRules() -> Array:
	"""Return a dictionary with the name of all rules and a bool ON/OFF"""
	var rules:Array = []
	for r in %Rules.get_children():
		rules.append(r.duplicate())
	return rules
	
func _on_create_game_button_pressed() -> void:
	"""Create a new game node from the options and sets it as main scene."""
	launch_new_game.emit(GetPlayers(), GetRules())
	
