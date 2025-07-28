@tool
extends HBoxContainer

@export var nb_dices:int = 6
@export var button_group:Resource


func _ready() -> void:
	for d in get_children():
		d.button_group = button_group

func reset():
	for d in get_children():
		d.button_pressed = false
