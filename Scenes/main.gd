extends Node

@onready var game_scene:PackedScene = load("res://Scenes/Game.tscn")


func _on_set_up_game_launch_new_game(players: Array, rules: Array) -> void:
	"""Create a new game node from the options and sets it as main scene."""
	
	var new_game:Game = game_scene.instantiate()
	new_game.name = 'Game'
	new_game.Setup(players, rules)
	new_game.process_mode = Node.PROCESS_MODE_PAUSABLE
	new_game.z_index = 0
	add_child(new_game)
	
	$Game.game_is_won.connect(_on_game_game_is_won)
	
	%SetUpGame.visible = false


func _on_game_game_is_won(winner_name:String, winner_score:int) -> void:
	%WinPanel.Launch(winner_name, winner_score)
	%WinPanel.visible = true
	$Game.visible = false
	get_tree().paused = true
	prints(PROCESS_MODE_INHERIT, PROCESS_MODE_PAUSABLE, PROCESS_MODE_ALWAYS)
	for c in get_children():
		prints(c.process_mode)

func _on_win_panel_launch_new_game() -> void:
	$Game.queue_free()
	
	%SetUpGame.visible = true
	%WinPanel.visible = false
	
	get_tree().paused = false
	
