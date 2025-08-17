extends Control

@export_multiline var winning_message:String = "Bravo NAME !\nTu gagnes avec SCORE points !"

signal launch_new_game

func SetupPanelText(winner_name:String, winner_score:int):
	var message:String = winning_message
	message = message.replace("NAME", winner_name.capitalize())
	message = message.replace("SCORE", str(winner_score))
	
	$VBoxContainer/RichTextLabel.text = message

func Launch(winner_name:String, winner_score:int):
	SetupPanelText(winner_name, winner_score)
	$Container/AnimationPlayer.play("fireworks")

func _on_replay_button_pressed() -> void:
	print("launch new game")
	launch_new_game.emit()


func _on_stats_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
