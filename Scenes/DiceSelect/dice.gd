@tool
extends TextureButton
class_name DiceButton

signal emit_value(value)

@export_range(1, 6, 1) var value:int = 1:
	set(new_value):
		if new_value < 1 or new_value > 6:
			return
		value = new_value
		var new_texture_names:Dictionary = GetTextName()
		texture_normal = load(texture_normal_name)
		texture_pressed = load(texture_pressed_name)
		
var texture_normal_name:String:
	get():
		return "res://Scenes/DiceSelect/Textures/" + GetTextName()["normal"]
var texture_pressed_name:String:
	get():
		return "res://Scenes/DiceSelect/Textures/" + GetTextName()["pressed"]

func SetDisabled(disable:bool):
	disabled = disable
	if button_pressed and disabled:
		texture_normal = load(texture_pressed_name)
	else:
		texture_normal = load(texture_normal_name)

func _on_toggled(toggled_on) -> void:
	if toggled_on:
		emit_value.emit(value)
	
	#if toggled_on:
		#$NormalSprite.visible = false
		#$PressedSprite.visible = true
	#else:
		#$NormalSprite.visible = true
		#$PressedSprite.visible = false

func GetTextName() -> Dictionary:
	var names:Dictionary = {}
	names["normal"] = 'dice_' + str(value) + '_sprites.png'
	names["pressed"] = 'dice_' + str(value) + '_sprites_pressed.png'
	return names
