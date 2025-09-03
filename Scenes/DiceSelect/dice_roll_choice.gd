@tool
extends HBoxContainer

@export var nb_dices:int = 6
@export var button_group:Resource

signal dice_selected(dice:DiceButton)

func _ready() -> void:
	if not button_group:
		button_group = ButtonGroup.new()
	
	for d in get_children():
		d.button_group = button_group

	button_group.pressed.connect(_on_dice_pressed)

func _on_dice_pressed(dice:DiceButton):
	dice_selected.emit(dice)
	

func reset():
	for d in get_children():
		d.button_pressed = false

func GetSelected() -> DiceButton:
	return button_group.get_pressed_button()

func SelectDice(value:int):
	#button_group.pressed.emit(get_child(value - 1))
	#prints("SELECTING DICE", value)
	get_child(value - 1).button_pressed = true

func SetAccess(accessible:bool):
	for b in button_group.get_buttons():
		b.SetDisabled(not accessible)

		#prints(b.disabled, b.button_pressed)
