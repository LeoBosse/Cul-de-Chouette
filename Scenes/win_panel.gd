extends Control

@export_multiline var winning_message:String = "Bravo NAME !\nTu gagnes avec SCORE points !"

@onready var stats = $StatsContainer/GameStats
	#get():
		#if $StatsContainer.get_child_count() == 1:
			#return $StatsContainer.get_child(0)
		#return null

signal launch_new_game

func SetupPanelText():
	var message:String = winning_message
	var winner_name:String = stats.GetWinnerName()
	var winner_score:int = stats.GetWinnerScore()
	message = message.replace("NAME", winner_name.capitalize())
	message = message.replace("SCORE", str(winner_score))
	
	$VBoxContainer/RichTextLabel.text = message

func Launch(statistics):
	stats.Import(statistics)
	#stats = statistics
	#statistics.visible = true
	#statistics.reparent($StatsContainer)
	
	$StatsContainer.print_tree_pretty()
	
	SetupPanelText()
	$Container/AnimationPlayer.play("fireworks")

func _on_replay_button_pressed() -> void:
	print("launch new game")
	launch_new_game.emit()


func _on_stats_button_pressed() -> void:
	print("TEST")
	$StatsContainer.visible = true


func _on_close_stats_button_pressed() -> void:
	$StatsContainer.visible = false
