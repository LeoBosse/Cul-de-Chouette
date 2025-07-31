extends Control

@onready var nb_players:int

@onready var player_names:Array

@onready var player_scores:Array[Array]

func Setup(player_names_list:Array):
	nb_players = len(player_names_list)
	$ScoreTable.columns = nb_players
	
	player_names = player_names_list
	player_scores.resize(nb_players)
	for i in range(nb_players):
		player_scores[i] = [0]
		AddEntryToScoreTable(player_names[i])
	for i in range(nb_players):
		AddEntryToScoreTable(str(player_scores[i][0]))
	
	print(player_scores)
	
func UpdateScore(new_round:bool, new_scores:Array):
	for i in range(nb_players):
			player_scores[i][-1] = new_scores[i]
			UpdateEntryToScoreTable(i, len(player_scores[i]), str(new_scores[i]))
			
	if new_round:
		print("NEW ROUND")
		for i in range(nb_players):
			player_scores[i].append(player_scores[i][-1])
			AddEntryToScoreTable(str(player_scores[i][-1]))
		
	print(player_scores)
	
	
func UpdateEntryToScoreTable(col:int, row:int, new_text:String):
	var id:int = nb_players * row + col
	#prints(col, row, id)
	$ScoreTable.get_child(id).text = new_text
	

func AddEntryToScoreTable(entry_text:String):
	var entry = Label.new()
	entry.set_anchors_preset(Control.PRESET_CENTER)
	entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	entry.text = entry_text
	$ScoreTable.add_child(entry)


func _on_close_button_pressed() -> void:
	visible = false
