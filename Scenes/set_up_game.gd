extends Control

@onready var game_scene:PackedScene = load("res://Scenes/Game.tscn")

@onready var nb_players:int = 1

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
	for i in range(1, nb_players):
		print("adding player")
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
	
func _on_create_game_button_pressed() -> void:
	"""Create a new game node from the options and sets it as main scene."""
	var new_game:Game = game_scene.instantiate()
	
	new_game.SetupPlayers(GetPlayers())
	
	get_tree().root.add_child(new_game)
	queue_free()
