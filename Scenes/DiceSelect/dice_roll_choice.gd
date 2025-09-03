@tool
extends HBoxContainer

@export var nb_dices:int = 6
@export var button_group:Resource


func _ready() -> void:
	if not button_group:
		button_group = ButtonGroup.new()
	
	for d in get_children():
		d.button_group = button_group

func reset():
	for d in get_children():
		d.button_pressed = false

func SelectDice(value:int):
	#button_group.pressed.emit(get_child(value - 1))
	prints("SELECTING DICE", value)
	get_child(value - 1).button_pressed = true

func SetAccess(accessible:bool):
	for b in button_group.get_buttons():
		b.SetDisabled(not accessible)

		#prints(b.disabled, b.button_pressed)
