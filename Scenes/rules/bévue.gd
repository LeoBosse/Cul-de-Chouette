@tool
extends Control
class_name BevueTab

var nb_players:int

signal bevue(player:int)

func Setup(player_names:Array) -> void:
	var button:Button
	nb_players = len(player_names)
	for i in nb_players:
		button = %GridContainer/Button.duplicate()
		button.visible = true
		button.text = player_names[i]
		button.pressed.connect(_on_button_toggled.bind(i))
		%GridContainer.add_child(button)
	%GridContainer.columns = int(sqrt(nb_players))


func _on_button_toggled(player:int) -> void:
	bevue.emit(player)


func _on_lock_check_button_toggled(toggled_on: bool) -> void:
	for b in %GridContainer.get_children():
		b.disabled = toggled_on
